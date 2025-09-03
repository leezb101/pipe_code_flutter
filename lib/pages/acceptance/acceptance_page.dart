/*
 * @Author: LeeZB
 * @Date: 2025-07-17 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-01 16:46:37
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import '../../models/common/common_user_vo.dart';
import '../../models/common/warehouse_vo.dart';
import '../../models/material/material_info_base.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../widgets/file_upload/file_upload_widget.dart';
import '../../bloc/acceptance/acceptance_bloc.dart';
import '../../bloc/acceptance/acceptance_event.dart';
import '../../bloc/acceptance/acceptance_state.dart';
import '../../models/acceptance/do_accept_vo.dart';
import '../../models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class AcceptancePage extends StatefulWidget {
  const AcceptancePage({
    super.key,
    this.materials,
    this.initialCodes,
    this.initialIsBatch,
  });

  final MaterialInfoForBusiness? materials;
  final List<String>? initialCodes;
  final bool? initialIsBatch;

  @override
  State<AcceptancePage> createState() => _AcceptancePageState();
}

class _AcceptancePageState extends State<AcceptancePage> {
  // 为每个上传组件创建一个Cubit
  late final FileUploadCubit _acceptancePhotosCubit;
  late final FileUploadCubit _inspectionReportsCubit;
  late final FileUploadCubit _acceptanceReportsCubit;

  // 仓库选择相关
  String _storageType = 'project'; // 'project' 或 'independent'
  int? _selectedWarehouseId;

  List<WarehouseVO> _warehouseList = [];

  // 用户列表相关
  List<CommonUserVO> _warehouseUsers = [];
  List<CommonUserVO> _supervisorUsers = [];
  List<CommonUserVO> _constructionUsers = [];

  // 推送选择状态
  final Map<String, bool?> _userPushStates = {};
  // 旧的本地列表与去重集合保留以便降级使用；主流程已切换到 Bloc 的 AcceptanceEditingState
  final Set<int> _materialIds = <int>{};
  late List<MaterialInfo> _currentMaterials;

  @override
  void initState() {
    super.initState();
    _acceptancePhotosCubit = FileUploadCubit();
    _inspectionReportsCubit = FileUploadCubit();
    _acceptanceReportsCubit = FileUploadCubit();

    // 初始进入（来自外部 initial 扫码页）时，将传入的 materials 视为已扫描集合，
    // 以便后续可以直接执行“扫码剔除”操作；若后续 append/remove 会继续增删。
    // 仅当当前集合还是空时才注入，避免重复。
    _currentMaterials = [
      ...(widget.materials?.normals ?? const <MaterialInfo>[]),
    ];
    for (final m in _currentMaterials) {
      _materialIds.add(m.baseInfo.materialId);
    }

    // 如从Standalone扫码跳转而来，带有codes，则先让bloc解析，再用编辑态初始化
    final codes = widget.initialCodes ?? const <String>[];
    if (codes.isNotEmpty) {
      context.read<AcceptanceBloc>().add(
        InitializeMaterialsFromCodes(
          codes: codes,
          isBatch: widget.initialIsBatch ?? (codes.length > 1),
        ),
      );
    }

    // 用传入 materials 作为编辑态初始值
    context.read<AcceptanceBloc>().add(
      InitializeEditingMaterials(initial: _currentMaterials),
    );

    // Load initial user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load warehouse list first
      context.read<AcceptanceBloc>().add(const LoadWarehouseList());

      // Get project ID from SessionBloc
      final sessionState = context.read<SessionBloc>().state;
      if (sessionState is SessionProjectEstablished) {
        final projectId = sessionState.currentUserRoleInfo.currentProjectId;
        context.read<AcceptanceBloc>().add(
          LoadAcceptanceUsers(
            projectId: projectId,
            roleType: 1, // Example role type
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _acceptancePhotosCubit.close();
    _inspectionReportsCubit.close();
    _acceptanceReportsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcceptanceBloc, AcceptanceState>(
      listener: (context, state) {
        if (state is AcceptanceUsersLoaded) {
          setState(() {
            _supervisorUsers = state.acceptUserInfo.supervisorUsers;
            _constructionUsers = state.acceptUserInfo.constructionUsers;
            // Initialize push states
            for (var user in _supervisorUsers) {
              _userPushStates['supervisor_${user.name}'] = user.messageTo;
            }
            for (var user in _constructionUsers) {
              _userPushStates['construction_${user.name}'] = user.messageTo;
            }
          });
        } else if (state is WarehouseListLoaded) {
          setState(() {
            _warehouseList = state.warehouseList;
          });
        } else if (state is WarehouseUsersLoaded) {
          setState(() {
            _warehouseUsers = state.warehouseUserInfo.warehouseUsers;
            // Initialize push states
            for (var user in _warehouseUsers) {
              _userPushStates['warehouse_${user.name}'] = user.messageTo;
            }
          });
        } else if (state is AcceptanceMaterialsResolved) {
          // 将解析结果作为编辑态初始值注入（用于 initialCodes 路径）
          context.read<AcceptanceBloc>().add(
            InitializeEditingMaterials(initial: state.materials),
          );
        } else if (state is AcceptanceEditingState) {
          // 编辑态下的反馈消息
          if (state.message != null && state.message!.isNotEmpty) {
            // 简单判断文案分别提示
            final msg = state.message!;
            if (msg.contains('新增') || msg.contains('追加')) {
              context.showSuccessToast(msg);
            } else if (msg.contains('剔除') || msg.contains('移除')) {
              context.showSuccessToast(msg);
            } else {
              context.showInfoToast(msg);
            }
            // 清理一次消息，避免后续无关状态变更时重复弹出
            context.read<AcceptanceBloc>().add(const ClearEditingMessage());
          }
        } else if (state is AcceptanceSubmitted) {
          // Toast弹窗提示并pop出去
          context.showSuccessToast('验收提交成功', isGlobal: true);
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('一管一码'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _handleViewRecords,
              child: const Text(
                '验收记录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: AppTheme.grey50,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMaterialsList(),
                    const SizedBox(height: 16),
                    _buildAttachmentSection(),
                    const SizedBox(height: 16),
                    _buildWarehouseSection(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    return UnifiedCard(
      title: '材料清单',
      icon: Icons.inventory,
      businessType: 'acceptance',
      child: BlocBuilder<AcceptanceBloc, AcceptanceState>(
        builder: (context, state) {
          final materials = state is AcceptanceEditingState
              ? state.currentMaterials
              : _currentMaterials;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...materials.map(_buildMaterialItem),
              const SizedBox(height: AppTheme.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: UnifiedButton(
                      text: '继续扫码',
                      type: UnifiedButtonType.outlined,
                      businessType: 'acceptance',
                      onPressed: _scanAppendMaterials,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: UnifiedButton(
                      text: '扫码剔除',
                      type: UnifiedButtonType.outlined,
                      businessType: 'acceptance',
                      foregroundColor: Colors.red,
                      borderColor: Colors.red,
                      onPressed: _scanRemoveMaterials,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMaterialItem(MaterialInfo material) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: MaterialListItem(
        materialName: material.baseInfo.prodNm ?? '无',
        materialId: material.baseInfo.materialCode ?? '无',
        quantity: 1,
        businessType: 'acceptance',
        icon: Icons.water_drop,
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return UnifiedCard(
      title: '附件上传',
      icon: Icons.attach_file,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<FileUploadCubit, List<FileUploadState>>(
            bloc: _acceptancePhotosCubit,
            builder: (context, states) {
              return ImageUploadWidget(
                title: '验收照片',
                states: states,
                maxImages: 6,
                onAdd: (files) => _acceptancePhotosCubit.addFiles(files),
                onRemove: (uniqueId) =>
                    _acceptancePhotosCubit.removeFile(uniqueId),
                onRetry: (uniqueId) =>
                    _acceptancePhotosCubit.retryUpload(uniqueId),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingXLarge),
          BlocBuilder<FileUploadCubit, List<FileUploadState>>(
            bloc: _inspectionReportsCubit,
            builder: (context, states) {
              return FileUploadWidget(
                title: '报验单',
                states: states,
                allowedExtensions: const ['pdf', 'doc', 'docx'],
                maxFiles: 3,
                onAdd: (files) => _inspectionReportsCubit.addFiles(files),
                onRemove: (uniqueId) =>
                    _inspectionReportsCubit.removeFile(uniqueId),
                onRetry: (uniqueId) =>
                    _inspectionReportsCubit.retryUpload(uniqueId),
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingXLarge),
          BlocBuilder<FileUploadCubit, List<FileUploadState>>(
            bloc: _acceptanceReportsCubit,
            builder: (context, states) {
              return FileUploadWidget(
                title: '验收报告',
                states: states,
                allowedExtensions: const ['pdf', 'doc', 'docx'],
                maxFiles: 3,
                onAdd: (files) => _acceptanceReportsCubit.addFiles(files),
                onRemove: (uniqueId) =>
                    _acceptanceReportsCubit.removeFile(uniqueId),
                onRetry: (uniqueId) =>
                    _acceptanceReportsCubit.retryUpload(uniqueId),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSection() {
    return UnifiedCard(
      title: '仓库管理',
      icon: Icons.warehouse,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStorageTypeSelection(),
          if (_storageType == 'independent') ...[
            const SizedBox(height: AppTheme.spacingLarge),
            _buildWarehouseSelection(),
          ],
          const SizedBox(height: AppTheme.spacingLarge),
          if (_storageType == 'independent')
            _buildUserSection('仓库负责人', _warehouseUsers, 'warehouse'),
          if (_storageType == 'independent')
            const SizedBox(height: AppTheme.spacingLarge),
          _buildUserSection('监理方负责人', _supervisorUsers, 'supervisor'),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildUserSection('建设方负责人', _constructionUsers, 'construction'),
        ],
      ),
    );
  }

  Widget _buildStorageTypeSelection() {
    return Row(
      children: [
        Row(
          children: [
            Radio<String>(
              value: 'project',
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                  // 切换回项目现场时清空仓库负责人列表
                  _warehouseUsers.clear();
                  // 清除相关的推送状态
                  _userPushStates.removeWhere(
                    (key, value) => key.startsWith('warehouse_'),
                  );
                });
              },
            ),
            const Text('项目现场', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(width: 32),
        Row(
          children: [
            Radio<String>(
              value: 'independent',
              groupValue: _storageType,
              onChanged: (value) {
                setState(() {
                  _storageType = value!;
                  // 切换到独立仓库时也清空仓库负责人列表（用户需要重新选择仓库）
                  _warehouseUsers.clear();
                  // 清除相关的推送状态
                  _userPushStates.removeWhere(
                    (key, value) => key.startsWith('warehouse_'),
                  );
                });

                // 如果已有选中的仓库，自动获取仓库人员
                if (_selectedWarehouseId != null) {
                  context.read<AcceptanceBloc>().add(
                    LoadWarehouseUsers(warehouseId: _selectedWarehouseId!),
                  );
                }
              },
            ),
            const Text('独立仓库', style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildWarehouseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择已有仓库：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedWarehouseId,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedWarehouseId = newValue!;
                });

                // 获取仓库用户
                if (newValue != null) {
                  context.read<AcceptanceBloc>().add(
                    LoadWarehouseUsers(warehouseId: newValue),
                  );
                }
              },
              items: _warehouseList.map<DropdownMenuItem<int>>((
                WarehouseVO warehouse,
              ) {
                return DropdownMenuItem<int>(
                  value: warehouse.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${warehouse.name} - ${warehouse.address}'),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserSection(
    String title,
    List<CommonUserVO> users,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title：',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text('暂无用户数据', style: TextStyle(color: Colors.grey)),
          )
        else
          ...users.map((user) => _buildUserItem(user, type)),
      ],
    );
  }

  Widget _buildUserItem(CommonUserVO user, String type) {
    final key = '${type}_${user.name}';
    final isSelected = _userPushStates[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    _userPushStates[key] = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Text('推送', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return UnifiedActionButtons(
      primaryButton: UnifiedButton(
        text: '提交报验',
        type: UnifiedButtonType.primary,
        businessType: 'acceptance',
        onPressed: _handleScanAcceptance,
      ),
      secondaryButton: UnifiedButton(
        text: '返回',
        type: UnifiedButtonType.outlined,
        businessType: 'acceptance',
        onPressed: _handleReturn,
      ),
      isFullWidth: true,
    );
  }

  void _handleViewRecords() {
    // Navigate to records page with acceptance tab selected
    context.go('/records?tab=accept');
  }

  void _handleScanAcceptance() {
    // 优先从编辑态取材；否则退回到本地集合
    final currentState = context.read<AcceptanceBloc>().state;
    final sourceMaterials = currentState is AcceptanceEditingState
        ? currentState.currentMaterials
        : _currentMaterials;
    final materialVOList = sourceMaterials
        .map(
          (e) => MaterialVO(
            materialId: e.baseInfo.materialId,
            materialName: e.baseInfo.prodNm ?? '',
          ),
        )
        .toList();

    // 获取选中的用户ID列表
    final selectedUserIds = _getSelectedUserIds();

    // 确定仓库类型：项目现场为false，独立仓库为true
    final realWarehouse = _storageType == 'independent';

    // 获取仓库ID，如果未选择则默认为0
    final warehouseId = _selectedWarehouseId ?? 0;

    // 从Cubit的state中收集所有附件。
    final allAttachments = <AttachmentVO>[];
    // 1. 验收照片
    allAttachments.addAll(
      _acceptancePhotosCubit.state
          .where(
            (s) => s.status == UploadStatus.success && s.uploadResult != null,
          )
          .map(
            (state) => AttachmentVO(
              type: 1, // 1 for image
              name: state.uploadResult!.fileName,
              url: state.uploadResult!.fileUrl,
              attachFormat: state.uploadResult!.fileType,
            ),
          ),
    );
    // 2. 报验单
    final String? sendAcceptUrl = _inspectionReportsCubit.state.isEmpty
        ? null
        : _inspectionReportsCubit.state
              .firstWhere(
                (s) =>
                    s.status == UploadStatus.success && s.uploadResult != null,
              )
              .uploadResult
              ?.fileUrl;
    // 3. 验收报告
    final String? acceptReportUrl = _acceptanceReportsCubit.state.isEmpty
        ? null
        : _acceptanceReportsCubit.state
              .firstWhere(
                (s) =>
                    s.status == UploadStatus.success && s.uploadResult != null,
              )
              .uploadResult
              ?.fileUrl;

    // 创建DoAcceptVO对象
    final doAcceptVO = DoAcceptVO(
      materialList: materialVOList,
      imageList: allAttachments,
      sendAcceptUrl: sendAcceptUrl,
      acceptReportUrl: acceptReportUrl,
      realWarehouse: realWarehouse,
      warehouseId: warehouseId,
      messageTo: selectedUserIds,
    );

    // 通过BLoC提交验收数据
    context.read<AcceptanceBloc>().add(SubmitAcceptance(request: doAcceptVO));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.purple[100],
        content: Text('正在提交验收数据...'),
      ),
    );
  }

  void _handleReturn() {
    context.pop();
    // Navigator.of(context).pop();
  }

  List<int> _getSelectedUserIds() {
    final selectedUserIds = <int>[];

    // 遍历推送状态，找到选中的用户
    _userPushStates.forEach((key, isSelected) {
      if (isSelected == true) {
        // 从key中解析出用户类型和用户名
        final parts = key.split('_');
        if (parts.length >= 2) {
          final userType =
              parts[0]; // 'supervisor', 'construction', 'warehouse'
          final userName = parts.sublist(1).join('_'); // 支持用户名包含下划线的情况

          // 根据用户类型在对应列表中查找用户ID
          CommonUserVO? user;
          switch (userType) {
            case 'supervisor':
              user = _supervisorUsers.firstWhere(
                (u) => u.name == userName,
                orElse: () =>
                    const CommonUserVO(userId: -1, name: '', phone: ''),
              );
              break;
            case 'construction':
              user = _constructionUsers.firstWhere(
                (u) => u.name == userName,
                orElse: () =>
                    const CommonUserVO(userId: -1, name: '', phone: ''),
              );
              break;
            case 'warehouse':
              user = _warehouseUsers.firstWhere(
                (u) => u.name == userName,
                orElse: () =>
                    const CommonUserVO(userId: -1, name: '', phone: ''),
              );
              break;
          }

          if (user != null && user.userId > 0) {
            selectedUserIds.add(user.userId);
          }
        }
      }
    });

    return selectedUserIds;
  }

  // 批量继续扫码追加材料：
  //  1. 通过扫码获取一组二维码（不做前端去重）
  //  2. 调用 scanBatchToQueryAll 获取完整物料实体
  //  3. 基于 materialId 去重追加
  Future<void> _scanAppendMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    // 不再依赖 currentCodes 做前端排重，传空数组让 normalize 全部视为新增
    final currentCodes = <String>[];
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: currentCodes,
      batch: true,
      context: const {
        'source': 'acceptancePage_append',
        'entry': 'embedded',
        'operation': 'append',
      },
      title: '继续扫码',
    );
    final config = flow.buildConfig(request);
    final raw = await context.push<List<dynamic>>('/qr-scan', extra: config);
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.addedCodes.isEmpty) return;
    // Delegate code resolution to bloc
    context.read<AcceptanceBloc>().add(
      AppendEditingMaterialsByCodes(codes: res.addedCodes),
    );
  }

  // 扫码剔除：
  //  1. 扫到一组待移除二维码
  //  2. 调用 scanBatchToQueryAll 获取对应 materialId 集合
  //  3. 依据 materialId 从 _currentMaterials 中剔除
  Future<void> _scanRemoveMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      // 不再依赖前端已有码集合过滤，传空表示全部交给后端解析
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'acceptancePage_remove',
        'entry': 'embedded',
        'operation': 'remove',
      },
      title: '扫码剔除',
    );
    final config = flow.buildConfig(request);
    final raw = await context.push<List<dynamic>>('/qr-scan', extra: config);
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.removedCodes.isEmpty) return;
    context.read<AcceptanceBloc>().add(
      RemoveEditingMaterialsByCodes(codes: res.removedCodes),
    );
  }

  // 已移除高亮及匹配辅助逻辑，直接基于 _currentMaterials 操作。
}
