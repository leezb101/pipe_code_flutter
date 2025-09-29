/*
 * @Author: LeeZB
 * @Date: 2025-09-29 
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_event.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/services/location_service.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import '../../models/common/warehouse_vo.dart';
import '../../models/material/material_info_base.dart';
import '../../widgets/file_upload/image_upload_widget.dart';
import '../../widgets/file_upload/file_upload_widget.dart';
import '../../cubits/jsf_acceptance/jsf_acceptance_cubit.dart';
import '../../cubits/jsf_acceptance/jsf_acceptance_event.dart';
import '../../cubits/jsf_acceptance/jsf_acceptance_state.dart';
import '../../models/acceptance/jsf_accept_vo.dart';
import '../../models/acceptance/jsf_material_vo.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation;
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/widgets/material/material_detail_display.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';

class JsfAcceptancePage extends StatelessWidget {
  const JsfAcceptancePage({
    super.key,
    this.materials,
    this.initialCodes,
    this.initialIsBatch,
  });

  final MaterialInfoForBusiness? materials;
  final List<String>? initialCodes;
  final bool? initialIsBatch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => JsfAcceptanceCubit(
        acceptanceRepository: getIt<AcceptanceRepository>(),
        materialHandleRepository: getIt<MaterialHandleRepository>(),
      ),
      child: _JsfAcceptancePageView(
        materials: materials,
        initialCodes: initialCodes,
        initialIsBatch: initialIsBatch,
      ),
    );
  }
}

class _JsfAcceptancePageView extends StatefulWidget {
  const _JsfAcceptancePageView({
    this.materials,
    this.initialCodes,
    this.initialIsBatch,
  });

  final MaterialInfoForBusiness? materials;
  final List<String>? initialCodes;
  final bool? initialIsBatch;

  @override
  State<_JsfAcceptancePageView> createState() => _JsfAcceptancePageViewState();
}

class _JsfAcceptancePageViewState extends State<_JsfAcceptancePageView> {
  // 为每个上传组件创建一个Cubit
  late final FileUploadCubit _acceptancePhotosCubit;
  late final FileUploadCubit _inspectionReportsCubit;
  late final FileUploadCubit _acceptanceReportsCubit;

  // 仓库选择相关
  String _storageType = 'project'; // 'project' 或 'independent'
  int? _selectedWarehouseId;

  List<WarehouseVO> _warehouseList = [];

  // 标记是否已经加载了仓库列表，避免重复加载
  bool _hasLoadedWarehouses = false;

  @override
  void initState() {
    super.initState();
    _acceptancePhotosCubit = FileUploadCubit();
    _inspectionReportsCubit = FileUploadCubit();
    _acceptanceReportsCubit = FileUploadCubit();

    // 用传入 materials 作为编辑态初始值
    final initialMaterials = [
      ...(widget.materials?.normals ?? const <MaterialInfo>[]),
    ];

    if (initialMaterials.isNotEmpty) {
      context.read<JsfAcceptanceCubit>().handleEvent(
        InitializeJsfMaterials(materials: initialMaterials),
      );
    }

    // 如从Standalone扫码跳转而来，带有codes，则先让cubit解析
    final codes = widget.initialCodes ?? const <String>[];
    if (codes.isNotEmpty) {
      context.read<JsfAcceptanceCubit>().handleEvent(
        InitializeJsfMaterialsFromCodes(
          codes: codes,
          isBatch: widget.initialIsBatch ?? true,
        ),
      );
    }

    // Load initial warehouse data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // LoadWarehouseList 将在 materialList 状态稳定后通过 BlocListener 触发
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
    return BlocListener<JsfAcceptanceCubit, JsfAcceptanceState>(
      listener: (context, state) {
        if (state is JsfAcceptanceEditingState) {
          // 当编辑状态稳定时，加载仓库列表
          _loadWarehousesIfNeeded(context);

          // 处理消息显示
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
            // 清除消息
            context.read<JsfAcceptanceCubit>().handleEvent(
              const ClearJsfMessage(),
            );
          }
        } else if (state is JsfAcceptanceSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('验收提交成功'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is JsfAcceptanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is JsfAcceptanceWarehouseLoaded) {
          setState(() {
            _warehouseList = state.warehouseList;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('建设方验收'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          color: Colors.grey[50],
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMaterialsList(),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildAttachmentSection(),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildWarehouseSection(),
                      const SizedBox(height: AppTheme.spacingMedium),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    return UnifiedCard(
      title: '材料清单',
      icon: Icons.inventory,
      businessType: 'jsf_acceptance',
      child: BlocBuilder<JsfAcceptanceCubit, JsfAcceptanceState>(
        builder: (context, state) {
          if (state is JsfAcceptanceMaterialsLoading) {
            return _buildInitialLoadingIndicator('正在加载材料信息...');
          } else if (state is JsfAcceptanceEditingState) {
            if (state.currentMaterials.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: const Center(
                  child: Text(
                    '暂无材料，请点击扫码添加',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              );
            }

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.currentMaterials.length,
                  itemBuilder: (context, index) {
                    return _buildMaterialItem(state.currentMaterials[index]);
                  },
                ),
                if (state.isLoadingAppendMaterials)
                  _buildAppendLoadingIndicator(),
                const SizedBox(height: AppTheme.spacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: UnifiedButton(
                        text: '继续扫码',
                        onPressed: _scanAppendMaterials,
                        type: UnifiedButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: UnifiedButton(
                        text: '扫码剔除',
                        onPressed: _scanRemoveMaterials,
                        type: UnifiedButtonType.outlined,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else if (state is JsfAcceptanceError) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.red[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(24),
              child: const Center(
                child: Text(
                  '请点击扫码开始',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMaterialItem(MaterialInfo material) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: MaterialListItem(
        onTap: () => _showMaterialDetail(context, material),
        materialName: material.baseInfo.prodNm ?? '无',
        materialId: material.baseInfo.materialCode ?? '无',
        quantity: 1,
        businessType: 'acceptance',
        icon: Icons.water_drop,
      ),
    );
  }

  // 首次加载材料时的全屏加载指示器
  Widget _buildInitialLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 追加材料时在列表底部的加载指示器
  Widget _buildAppendLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            '正在获取物料信息...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showMaterialDetail(BuildContext context, MaterialInfo material) {
    showDialog(
      context: context,
      builder: (context) {
        return MaterialDetailDisplay(material: material);
      },
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
                enableWatermark: true,
                watermarkText: '验收',
                includeTimeWatermark: true,
                includeLocationWatermark: true,
                states: states,
                maxImages: 2,
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
                maxFiles: 2,
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
                maxFiles: 2,
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
      businessType: 'jsf_acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStorageTypeSelection(),
          if (_storageType == 'independent') ...[
            const SizedBox(height: AppTheme.spacingMedium),
            _buildWarehouseSelection(),
          ],
        ],
      ),
    );
  }

  Widget _buildStorageTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _storageType = 'project';
                _selectedWarehouseId = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _storageType == 'project'
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: _storageType == 'project'
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _storageType == 'project'
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Text('项目现场'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _storageType = 'independent';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _storageType == 'independent'
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: _storageType == 'independent'
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warehouse,
                    color: _storageType == 'independent'
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Text('独立仓库'),
                ],
              ),
            ),
          ),
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
              isExpanded: true,
              // 允许下拉项根据内容自适应高度（多行展示）
              itemHeight: null,
              // 限制下拉菜单的最大高度，避免过长遮挡
              menuMaxHeight: 400,
              // 选中项在收起状态下的自定义展示，单行省略号
              selectedItemBuilder: (BuildContext context) {
                return _warehouseList.map<Widget>((warehouse) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${warehouse.name} - ${warehouse.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('请选择仓库', overflow: TextOverflow.ellipsis),
              ),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedWarehouseId = newValue!;
                });

                // 获取仓库用户
                if (newValue != null) {
                  context.read<JsfAcceptanceCubit>().handleEvent(
                    LoadJsfWarehouseUsers(warehouseId: newValue),
                  );
                }
              },
              items: List<DropdownMenuItem<int>>.generate(
                _warehouseList.length,
                (index) {
                  final warehouse = _warehouseList[index];
                  final isLast = index == _warehouseList.length - 1;
                  return DropdownMenuItem<int>(
                    value: warehouse.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            '${warehouse.name} - ${warehouse.address}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[300],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return UnifiedActionButtons(
      primaryButton: UnifiedButton(
        text: '提交验收',
        icon: Icons.check_circle,
        onPressed: _handleSubmitAcceptance,
      ),
      secondaryButton: UnifiedButton(
        text: '返回',
        icon: Icons.arrow_back,
        onPressed: _handleReturn,
      ),
      isFullWidth: true,
    );
  }

  void _handleSubmitAcceptance() {
    // 优先从编辑态取材；否则无材料则提示
    final currentState = context.read<JsfAcceptanceCubit>().state;
    if (currentState is! JsfAcceptanceEditingState ||
        currentState.currentMaterials.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先扫码添加材料')));
      return;
    }

    // 获取当前项目ID
    final sessionState = context.read<SessionBloc>().state;
    int? projectId;
    if (sessionState is SessionProjectEstablished) {
      projectId = sessionState.currentProject.projectId;
    }

    if (projectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('无法获取项目信息')));
      return;
    }

    final sourceMaterials = currentState.currentMaterials;
    final materialVOList = sourceMaterials
        .map(
          (material) => JsfMaterialVO(
            materialId: material.baseInfo.materialId,
            materialName: material.baseInfo.prodNm ?? '',
            num: 1,
            projectId: projectId!,
          ),
        )
        .toList();

    // 确定仓库类型：项目现场为false，独立仓库为true
    final realWarehouse = _storageType == 'independent';

    // 获取仓库ID，如果未选择则默认为0
    final warehouseId = _selectedWarehouseId ?? 0;

    // 从Cubit的state中收集所有附件。
    final allAttachments = <AttachmentVO>[];
    // 1. 验收照片
    allAttachments.addAll(
      _acceptancePhotosCubit.state
          .where((item) => item.status == UploadStatus.success)
          .map(
            (item) => AttachmentVO(
              type: 0, // 图片类型
              name: item.uploadResult?.fileName ?? '',
              url: item.uploadResult?.filePath ?? '',
              attachFormat: 'image',
            ),
          ),
    );
    // 2. 报验单
    final String? sendAcceptUrl = _inspectionReportsCubit.state.isEmpty
        ? null
        : _inspectionReportsCubit.state
              .firstWhere(
                (item) => item.status == UploadStatus.success,
                orElse: () => _inspectionReportsCubit.state.first,
              )
              .uploadResult
              ?.filePath;
    // 3. 验收报告
    final String? acceptReportUrl = _acceptanceReportsCubit.state.isEmpty
        ? null
        : _acceptanceReportsCubit.state
              .firstWhere(
                (item) => item.status == UploadStatus.success,
                orElse: () => _acceptanceReportsCubit.state.first,
              )
              .uploadResult
              ?.filePath;

    // 获取位置信息
    String? lng, lat;
    LocationService.getCurrentLocation().then((location) {
      if (location != null) {
        lng = location.longitude.toString();
        lat = location.latitude.toString();
      }
    });

    // 创建JsfAcceptVO对象
    final jsfAcceptVO = JsfAcceptVO(
      lng: lng,
      lat: lat,
      materialList: materialVOList,
      imageList: allAttachments,
      sendAcceptUrl: sendAcceptUrl,
      acceptReportUrl: acceptReportUrl,
      realWarehouse: realWarehouse,
      warehouseId: warehouseId,
      messageTo: const [], // 建设方验收不需要推送给其他人
      // returnData 暂时为空，根据业务需求后续可扩展
    );

    // 通过Cubit提交验收数据
    context.read<JsfAcceptanceCubit>().handleEvent(
      SubmitJsfAcceptance(request: jsfAcceptVO),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.blue,
        content: Text('正在提交验收数据...'),
      ),
    );
  }

  void _handleReturn() {
    context.pop();
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
        'source': 'jsfAcceptancePage_append',
        'entry': 'embedded',
        'operation': 'append',
      },
      title: '继续扫码',
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.addedCodes.isEmpty) return;
    // Delegate code resolution to cubit
    context.read<JsfAcceptanceCubit>().handleEvent(
      AppendJsfMaterialsByCodes(codes: res.addedCodes),
    );
  }

  // 扫码剔除：
  //  1. 扫到一组待移除二维码
  //  2. 调用 scanBatchToQueryAll 获取对应 materialId 集合
  //  3. 依据 materialId 从材料列表中剔除
  Future<void> _scanRemoveMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      // 不再依赖前端已有码集合过滤，传空表示全部交给后端解析
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'jsfAcceptancePage_remove',
        'entry': 'embedded',
        'operation': 'remove',
      },
      title: '扫码剔除',
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.removedCodes.isEmpty) return;
    context.read<JsfAcceptanceCubit>().handleEvent(
      RemoveJsfMaterialsByCodes(codes: res.removedCodes),
    );
  }

  // 在 materialList 状态稳定后触发加载仓库列表，避免重复加载
  void _loadWarehousesIfNeeded(BuildContext context) {
    if (_hasLoadedWarehouses) return;

    _hasLoadedWarehouses = true;
    context.read<JsfAcceptanceCubit>().handleEvent(
      const LoadJsfWarehouseList(),
    );
  }
}
