import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/session/session_bloc.dart';
import 'package:pipe_code_flutter/bloc/session/session_state.dart';
import 'package:pipe_code_flutter/models/common/material_status_enum.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/utils/tracing_context_x.dart';
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
import 'package:pipe_code_flutter/widgets/material/material_detail_display.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';

class AcceptancePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AcceptanceBloc(
        getIt<AcceptanceRepository>(),
        getIt<MaterialHandleRepository>(),
      ),
      child: _AcceptancePageView(
        materials: materials,
        initialCodes: initialCodes,
        initialIsBatch: initialIsBatch,
      ),
    );
  }
}

class _AcceptancePageView extends StatefulWidget {
  const _AcceptancePageView({
    this.materials,
    this.initialCodes,
    this.initialIsBatch,
  });

  final MaterialInfoForBusiness? materials;
  final List<String>? initialCodes;
  final bool? initialIsBatch;

  @override
  State<_AcceptancePageView> createState() => _AcceptancePageViewState();
}

class _AcceptancePageViewState extends State<_AcceptancePageView> {
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

  // 标记是否已经加载了用户数据，避免重复加载
  bool _hasLoadedUsers = false;
  // 标记是否已经加载了仓库列表，避免重复加载
  bool _hasLoadedWarehouses = false;
  // 标记是否已经显示了采购方验证警告对话框，避免重复显示
  bool _hasShownPurchaserWarning = false;

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
      // 获取当前项目采购方名称和供材类型
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sessionState = context.read<SessionBloc>().state;
        String? projectPurNm;
        ProjectSupplyType? supplyType;
        if (sessionState is SessionProjectEstablished) {
          projectPurNm = sessionState.projectPurNm;
          supplyType =
              sessionState.currentUserRoleInfo.currentProjectSupplyType;
        }

        context.read<AcceptanceBloc>().add(
          InitializeMaterialsFromCodes(
            codes: codes,
            isBatch: widget.initialIsBatch ?? true,
            projectPurNm: projectPurNm,
            supplyType: supplyType,
            tracingContext: context.createActionContext('初始化验收材料'),
          ),
        );
      });
    }

    // 用传入 materials 作为编辑态初始值
    // context.read<AcceptanceBloc>().add(
    //   InitializeEditingMaterials(initial: _currentMaterials),
    // );

    // Load initial user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // LoadWarehouseList 和 LoadAcceptanceUsers 将在 materialList 状态稳定后通过 BlocListener 触发
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

          // 用户数据加载完成后，串行加载仓库列表
          _loadWarehousesIfNeeded(context);
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
        } else if (state is AcceptanceMaterialsLoading) {
          // 首次加载时不需要特殊处理，UI会自动显示加载状态
        } else if (state is AcceptanceMaterialsResolved) {
          // 将解析结果作为编辑态初始值注入（用于 initialCodes 路径）
          // 获取当前项目采购方名称和供材类型
          final sessionState = context.read<SessionBloc>().state;
          String? projectPurNm;
          ProjectSupplyType? supplyType;
          if (sessionState is SessionProjectEstablished) {
            projectPurNm = sessionState.projectPurNm;
            supplyType =
                sessionState.currentUserRoleInfo.currentProjectSupplyType;
          }

          context.read<AcceptanceBloc>().add(
            InitializeEditingMaterials(
              initial: state.materials,
              projectPurNm: projectPurNm,
              supplyType: supplyType,
            ),
          );

          // 在 materialList 初始化完成后，只触发加载用户数据
          // 仓库列表将在用户数据加载完成后串行加载
          _loadUsersIfNeeded(context);
        } else if (state is AcceptanceMaterialInfoResolved) {
          // 处理完整的材料信息（包括errors）
          final sessionState = context.read<SessionBloc>().state;
          String? projectPurNm;
          ProjectSupplyType? supplyType;
          if (sessionState is SessionProjectEstablished) {
            projectPurNm = sessionState.projectPurNm;
            supplyType =
                sessionState.currentUserRoleInfo.currentProjectSupplyType;
          }

          context.read<AcceptanceBloc>().add(
            InitializeEditingMaterials(
              initial: state.materials,
              initialErrors: state.errors, // 传递错误材料数据
              projectPurNm: projectPurNm,
              supplyType: supplyType,
            ),
          );

          // 在 materialList 初始化完成后，只触发加载用户数据
          // 仓库列表将在用户数据加载完成后串行加载
          _loadUsersIfNeeded(context);
        } else if (state is AcceptanceError) {
          // 只提示错误，不清空或变更当前编辑中的待提交信息
          context.showErrorToast('验收失败: ${state.message}');
        } else if (state is AcceptanceEditingState) {
          // 显示采购方验证警告对话框
          if (state.showPurchaserValidationWarning &&
              !_hasShownPurchaserWarning) {
            _hasShownPurchaserWarning = true; // 标记已显示，防止重复弹窗
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showPurchaserValidationWarning(
                context,
                state.purchaserMismatchMaterials,
              );
            });
          }

          // 当警告状态重置时，也重置显示标志
          if (!state.showPurchaserValidationWarning &&
              _hasShownPurchaserWarning) {
            _hasShownPurchaserWarning = false;
          }

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
          } else {
            // 如果没有消息，说明是初始化状态，只触发加载用户数据
            // 仓库列表将在用户数据加载完成后串行加载
            _loadUsersIfNeeded(context);
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
          // actions: [
          //   TextButton(
          //     onPressed: _handleViewRecords,
          //     child: const Text(
          //       '验收记录',
          //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          //     ),
          //   ),
          //   const SizedBox(width: 8),
          // ],
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
          // 处理首次加载材料的情况
          if (state is AcceptanceMaterialsLoading) {
            return _buildInitialLoadingIndicator(state.message);
          }

          final materials = state is AcceptanceEditingState
              ? state.currentMaterials
              : _currentMaterials;

          final errorMaterials = state is AcceptanceEditingState
              ? state.errorMaterials
              : <dynamic>[];

          // 检查是否正在追加材料
          final isAppendLoading =
              state is AcceptanceEditingState && state.isLoadingAppendMaterials;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 正常材料列表
              ...materials.map(_buildMaterialItem),

              // 如果正在追加材料，在材料列表下方显示加载指示器
              if (isAppendLoading) _buildAppendLoadingIndicator(),

              // 错误材料展示区域
              if (errorMaterials.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                ErrorMaterialSection(
                  errors: errorMaterials,
                  title: '验收异常材料',
                  onErrorItemTap: _handleErrorMaterialTap,
                  collapsible: true,
                  initialExpanded: true,
                ),
              ],

              const SizedBox(height: AppTheme.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: UnifiedButton(
                      text: '继续扫码',
                      type: UnifiedButtonType.outlined,
                      businessType: 'acceptance',
                      onPressed: isAppendLoading
                          ? null
                          : _scanAppendMaterials, // 加载时禁用按钮
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
                      onPressed: isAppendLoading
                          ? null
                          : _scanRemoveMaterials, // 加载时禁用按钮
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
        onTap: () => _showMaterialDetail(context, material),
        materialName: material.baseInfo.prodNm ?? '无',
        primaryText: material.baseInfo.materialCode ?? '无',
        batchCode: material.baseInfo.batchCode ?? '无',
        materialId: material.baseInfo.materialCode ?? '无',
        status: material.baseInfo.status,
        statusName: material.baseInfo.statusName,
        validStatus: MaterialStatusEnum.init,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3.0),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.orange[600]),
            textAlign: TextAlign.center,
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
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
          SizedBox(width: 12),
          Text(
            '正在获取物料信息...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showMaterialDetail(BuildContext context, MaterialInfo material) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          material.baseInfo.prodNm ?? '材料详情',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // 内容区域
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MaterialDetailDisplay(
                      material: material,
                      isCompact: true,
                      showProjectInfo: false,
                      showCopyAction: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
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
                    LoadWarehouseUsers(
                      warehouseId: _selectedWarehouseId!,
                      tracingContext: context.createActionContext('加载仓库用户'),
                    ),
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
                  context.read<AcceptanceBloc>().add(
                    LoadWarehouseUsers(
                      warehouseId: newValue,
                      tracingContext: context.createActionContext('切换仓库并加载用户'),
                    ),
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
              const Text('短信通知', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<AcceptanceBloc, AcceptanceState>(
      builder: (context, state) {
        // 检查是否有异常材料
        final hasErrorMaterials =
            state is AcceptanceEditingState && state.errorMaterials.isNotEmpty;

        return UnifiedActionButtons(
          primaryButton: UnifiedButton(
            text: hasErrorMaterials ? '存在异常材料' : '提交报验',
            type: UnifiedButtonType.primary,
            businessType: 'acceptance',
            onPressed: hasErrorMaterials ? null : _handleScanAcceptance,
          ),
          secondaryButton: UnifiedButton(
            text: '返回',
            type: UnifiedButtonType.outlined,
            businessType: 'acceptance',
            onPressed: _handleReturn,
          ),
          isFullWidth: true,
        );
      },
    );
  }

  void _handleErrorMaterialTap(dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('异常材料详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(
              label: '二维码',
              value: _getErrorField(error, 'qrCode') ?? '无',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '厂家编码',
              value: _getErrorField(error, 'code') ?? '无',
              icon: Icons.business,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '厂家名称',
              value: _getErrorField(error, 'name') ?? '无',
              icon: Icons.factory,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '错误信息',
              value: _getErrorField(error, 'msg') ?? '无',
              icon: Icons.error_outline,
              valueStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleReportError(error);
            },
            child: const Text('报告问题'),
          ),
        ],
      ),
    );
  }

  String? _getErrorField(dynamic error, String field) {
    if (error is Map<String, dynamic>) {
      return error[field]?.toString();
    }
    try {
      switch (field) {
        case 'qrCode':
          return (error as dynamic).qrCode?.toString();
        case 'code':
          return (error as dynamic).code?.toString();
        case 'name':
          return (error as dynamic).name?.toString();
        case 'msg':
          return (error as dynamic).msg?.toString();
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _showErrorMaterialWarning(
    int normalCount,
    int errorCount,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 24),
            const SizedBox(width: 8),
            const Text('无法提交验收', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '检测到 $errorCount 个异常材料无法进行验收提交：',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.errorColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '异常材料说明：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('• 异常材料缺少必要的验收信息'),
                  const Text('• 请联系相关人员处理异常材料'),
                  const Text('• 处理完成后重新扫描进行验收'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '正常材料数量：$normalCount 个',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  void _handleReportError(dynamic error) {
    // 报告错误材料问题的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('问题报告已提交'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _handleScanAcceptance() async {
    // 优先从编辑态取材；否则退回到本地集合
    final currentState = context.read<AcceptanceBloc>().state;
    final sourceMaterials = currentState is AcceptanceEditingState
        ? currentState.currentMaterials
        : _currentMaterials;

    final errorMaterials = currentState is AcceptanceEditingState
        ? currentState.errorMaterials
        : <dynamic>[];

    // 检查是否有错误材料，如果有则显示警告对话框并阻止提交
    if (errorMaterials.isNotEmpty) {
      await _showErrorMaterialWarning(
        sourceMaterials.length,
        errorMaterials.length,
      );
      return; // 有异常材料时直接返回，不执行提交
    }

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
              url: state.uploadResult!.filePath,
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
              ?.filePath;
    // 3. 验收报告
    final String? acceptReportUrl = _acceptanceReportsCubit.state.isEmpty
        ? null
        : _acceptanceReportsCubit.state
              .firstWhere(
                (s) =>
                    s.status == UploadStatus.success && s.uploadResult != null,
              )
              .uploadResult
              ?.filePath;

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
    context.read<AcceptanceBloc>().add(
      SubmitAcceptance(
        request: doAcceptVO,
        tracingContext: context.createActionContext('提交验收申请'),
      ),
    );

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
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.addedCodes.isEmpty) return;

    // 获取当前项目采购方名称和供材类型
    final sessionState = context.read<SessionBloc>().state;
    String? projectPurNm;
    ProjectSupplyType? supplyType;
    if (sessionState is SessionProjectEstablished) {
      projectPurNm = sessionState.projectPurNm;
      supplyType = sessionState.currentUserRoleInfo.currentProjectSupplyType;
    }

    // Delegate code resolution to bloc
    context.read<AcceptanceBloc>().add(
      AppendEditingMaterialsByCodes(
        codes: res.addedCodes,
        projectPurNm: projectPurNm,
        supplyType: supplyType,
        tracingContext: context.createActionContext('追加验收材料'),
      ),
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
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    if (!mounted) return;
    final res = flow.normalize(request, raw);
    if (res.removedCodes.isEmpty) return;
    context.read<AcceptanceBloc>().add(
      RemoveEditingMaterialsByCodes(
        codes: res.removedCodes,
        tracingContext: context.createActionContext('剔除验收材料'),
      ),
    );
  }

  // 在 materialList 状态稳定后触发加载用户数据，避免重复加载
  void _loadUsersIfNeeded(BuildContext context) {
    if (_hasLoadedUsers) return;

    _hasLoadedUsers = true;

    // Get project ID from SessionBloc
    final sessionState = context.read<SessionBloc>().state;
    if (sessionState is SessionProjectEstablished) {
      final projectId = sessionState.currentUserRoleInfo.currentProjectId;
      context.read<AcceptanceBloc>().add(
        LoadAcceptanceUsers(
          projectId: projectId,
          roleType: 1, // Example role type
          tracingContext: context.createActionContext('加载验收用户'),
        ),
      );
    }
  }

  // 在 materialList 状态稳定后触发加载仓库列表，避免重复加载
  void _loadWarehousesIfNeeded(BuildContext context) {
    if (_hasLoadedWarehouses) return;

    _hasLoadedWarehouses = true;
    context.read<AcceptanceBloc>().add(
      LoadWarehouseList(tracingContext: context.createActionContext('加载仓库列表')),
    );
  }

  // 已移除高亮及匹配辅助逻辑，直接基于 _currentMaterials 操作。

  /// 显示采购方验证警告对话框
  void _showPurchaserValidationWarning(
    BuildContext context,
    List<String> mismatchMaterials,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // 不允许点击外部关闭
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              const Text('采购方验证警告', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '检测到以下材料的采购方与当前项目采购方不匹配：',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mismatchMaterials.map((material) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $material',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '请确认是否继续进行验收操作。',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 取消操作，退出当前验收页面
                context.pop();
              },
              child: const Text('取消操作', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 确认继续，清除警告状态
                context.read<AcceptanceBloc>().add(
                  const ConfirmPurchaserValidationWarning(),
                );
              },
              child: const Text('仍然继续'),
            ),
          ],
        );
      },
    );
  }
}
