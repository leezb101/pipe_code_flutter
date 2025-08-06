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
import '../../utils/go_router_popuntil.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';

class AcceptancePage extends StatefulWidget {
  const AcceptancePage({super.key, required this.materials});

  final MaterialInfoForBusiness materials;

  @override
  State<AcceptancePage> createState() => _AcceptancePageState();
}

class _AcceptancePageState extends State<AcceptancePage> {
  // 静态常量 BoxShadow，避免重复创建
  static const BoxShadow _acceptancePageBoxShadow = BoxShadow(
    color: Color(0x1A000000), // 0.1 opacity black
    blurRadius: 8,
    offset: Offset(0, -2),
  );

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

  @override
  void initState() {
    super.initState();
    _acceptancePhotosCubit = FileUploadCubit();
    _inspectionReportsCubit = FileUploadCubit();
    _acceptanceReportsCubit = FileUploadCubit();

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
        } else if (state is WarehouseUsersLoaded) {
          setState(() {
            _warehouseUsers = state.warehouseUserInfo.warehouseUsers;
            // Initialize push states
            for (var user in _warehouseUsers) {
              _userPushStates['warehouse_${user.name}'] = user.messageTo;
            }
          });
        } else if (state is WarehouseListLoaded) {
          setState(() {
            _warehouseList = state.warehouseList;
            // Set default selection to first warehouse if available
            if (_warehouseList.isNotEmpty) {
              _selectedWarehouseId = _warehouseList.first.id;

              // 如果当前是独立仓库模式，自动获取默认仓库的人员
              if (_storageType == 'independent') {
                context.read<AcceptanceBloc>().add(
                  LoadWarehouseUsers(warehouseId: _warehouseList.first.id),
                );
              }
            }
          });
        } else if (state is AcceptanceError) {
          context.showErrorToast(state.message);
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AcceptanceSubmitted) {
          // 通过GoRouter返回MainPage
          context.showSuccessToast('提交成功，即将返回', isGlobal: true);
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              GoRouter.of(context).popUntil(
                predicate: (route) {
                  return route.name == '/';
                },
              );
            }
          });
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
        backgroundColor: Colors.grey[50],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, size: 24, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '材料清单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.materials.normals.map(
              (material) => _buildMaterialItem(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialInfo material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.water_drop, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.baseInfo.prodNm ?? '无',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  material.baseInfo.materialCode ?? '无',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '1个',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildWarehouseSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warehouse, size: 24, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  '仓库管理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStorageTypeSelection(),
            if (_storageType == 'independent') ...[
              const SizedBox(height: 20),
              _buildWarehouseSelection(),
            ],
            const SizedBox(height: 20),
            if (_storageType == 'independent')
              _buildUserSection('仓库负责人', _warehouseUsers, 'warehouse'),
            if (_storageType == 'independent') const SizedBox(height: 20),
            _buildUserSection('监理方负责人', _supervisorUsers, 'supervisor'),
            const SizedBox(height: 20),
            _buildUserSection('建设方负责人', _constructionUsers, 'construction'),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [_acceptancePageBoxShadow],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleScanAcceptance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '提交报验',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSupplementReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '补录返告',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleProcessReturn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '处理退库',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleConfirmAcceptance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      '验收确认',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '返回',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleViewRecords() {
    // Navigate to records page with acceptance tab selected
    context.go('/records?tab=accept');
  }

  void _handleScanAcceptance() {
    final materialVOList = widget.materials.normals
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
    allAttachments.addAll(
      _inspectionReportsCubit.state
          .where(
            (s) => s.status == UploadStatus.success && s.uploadResult != null,
          )
          .map(
            (state) => AttachmentVO(
              type: 2, // 2 for inspection report file
              name: state.uploadResult!.fileName,
              url: state.uploadResult!.fileUrl,
              attachFormat: state.uploadResult!.fileType,
            ),
          ),
    );
    // 3. 验收报告
    allAttachments.addAll(
      _acceptanceReportsCubit.state
          .where(
            (s) => s.status == UploadStatus.success && s.uploadResult != null,
          )
          .map(
            (state) => AttachmentVO(
              type: 3, // 3 for acceptance report file
              name: state.uploadResult!.fileName,
              url: state.uploadResult!.fileUrl,
              attachFormat: state.uploadResult!.fileType,
            ),
          ),
    );

    // 创建DoAcceptVO对象
    final doAcceptVO = DoAcceptVO(
      materialList: materialVOList,
      imageList: allAttachments,
      realWarehouse: realWarehouse,
      warehouseId: warehouseId,
      messageTo: selectedUserIds,
    );

    // 通过BLoC提交验收数据
    context.read<AcceptanceBloc>().add(SubmitAcceptance(request: doAcceptVO));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('正在提交验收数据...')));
  }

  void _handleSupplementReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('补录返告功能')));
  }

  void _handleProcessReturn() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('处理退库功能')));
  }

  void _handleConfirmAcceptance() {
    // Collect selected user IDs for push notifications
    _userPushStates.forEach((key, value) {
      if (value != null && value) {
        // In real implementation, map user names to IDs
      }
    });

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text('验收确认成功')));
    context.showSuccessToast('验收确认成功');
    // Navigator.of(context).pop();
    // 使用GoRouter返回到主页面
    // context.pop();
    _handleReturn();
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
}
