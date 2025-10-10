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
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/user/current_user_on_project_role_info.dart';
import 'package:pipe_code_flutter/services/location_service.dart';
import 'package:pipe_code_flutter/constants/app_theme.dart';
import '../../models/common/warehouse_vo.dart';
import '../../models/common/common_user_vo.dart';
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
import 'package:pipe_code_flutter/widgets/unified/unified_components.dart';
import 'package:pipe_code_flutter/widgets/material/material_detail_display.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';

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
    return RepositoryProvider<JsfAcceptanceCubit>(
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

  // Cubit instance
  late final JsfAcceptanceCubit _controller;

  // 仓库选择相关
  String _storageType = 'project'; // 'project' 或 'independent'
  int? _selectedWarehouseId;

  List<WarehouseVO> _warehouseList = [];

  // 用户列表相关
  List<CommonUserVO> _warehouseUsers = [];

  // 推送选择状态
  final Map<String, bool?> _userPushStates = {};

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

    // Initialize controller
    _controller = RepositoryProvider.of<JsfAcceptanceCubit>(context);

    // // 用传入 materials 作为编辑态初始值
    // final initialMaterials = [
    //   ...(widget.materials?.normals ?? const <MaterialInfo>[]),
    // ];

    // if (initialMaterials.isNotEmpty) {
    //   _controller.handleEvent(
    //     InitializeJsfMaterials(materials: initialMaterials),
    //   );
    // }

    // 如从Standalone扫码跳转而来，带有codes，则先让cubit解析
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

        _controller.handleEvent(
          InitializeJsfMaterialsFromCodes(
            codes: codes,
            isBatch: widget.initialIsBatch ?? true,
          ),
          projectPurNm: projectPurNm,
          supplyType: supplyType,
        );
      });
    }
  }

  @override
  void dispose() {
    _acceptancePhotosCubit.close();
    _inspectionReportsCubit.close();
    _acceptanceReportsCubit.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JsfAcceptanceState>(
      stream: _controller.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const JsfAcceptanceState();

        // 处理状态变化
        _handleStateChange(context, state);

        return Scaffold(
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChange(BuildContext context, JsfAcceptanceState state) {
    // 当编辑状态稳定时，加载仓库列表
    if (state.materials.isNotEmpty) {
      _loadWarehousesIfNeeded(context);

      // 处理消息显示
      if (state.message != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showInfoToast(state.message!);
          _controller.handleEvent(const ClearJsfMessage());
        });
      }
    }

    // 显示采购方验证警告对话框
    if (state.showPurchaserValidationWarning && !_hasShownPurchaserWarning) {
      _hasShownPurchaserWarning = true; // 标记已显示，防止重复弹窗
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPurchaserValidationWarning(
          context,
          state.purchaserMismatchMaterials,
        );
      });
    }

    // 当警告状态重置时，也重置显示标志
    if (!state.showPurchaserValidationWarning && _hasShownPurchaserWarning) {
      _hasShownPurchaserWarning = false;
    }

    if (state.isSubmitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showSuccessToast('验收提交成功');
        context.pop();
      });
    }

    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.showErrorToast(state.errorMessage!);
      });
    }

    // 更新仓库列表
    if (state.warehouseList.isNotEmpty &&
        state.warehouseList != _warehouseList) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _warehouseList = state.warehouseList;
        });
      });
    }

    // 更新仓库用户列表
    if (state.warehouseUsers.isNotEmpty &&
        state.warehouseUsers != _warehouseUsers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _warehouseUsers = state.warehouseUsers;
          // 初始化推送状态
          for (var user in _warehouseUsers) {
            _userPushStates['warehouse_${user.name}'] = user.messageTo;
          }
        });
      });
    }
  }

  Widget _buildMaterialsList() {
    return UnifiedCard(
      title: '材料清单',
      icon: Icons.inventory,
      businessType: 'jsf_acceptance',
      child: StreamBuilder<JsfAcceptanceState>(
        stream: _controller.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const JsfAcceptanceState();

          if (state.isLoadingMaterials) {
            return _buildInitialLoadingIndicator('正在加载材料信息...');
          } else if (state.materials.isNotEmpty) {
            return Column(
              children: [
                // 正常材料列表
                ...state.materials.map(
                  (material) => _buildMaterialItem(material),
                ),

                // 错误材料区域
                if (state.errorMaterials.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ErrorMaterialSection(
                    errors: state.errorMaterials,
                    onErrorItemTap: _handleErrorMaterialTap,
                  ),
                ],

                // 追加材料加载指示器
                if (state.isLoadingAppendMaterials)
                  _buildAppendLoadingIndicator(),
              ],
            );
          } else if (state.errorMessage != null) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text(
                      '请先扫码添加材料',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                // 操作按钮
                const SizedBox(height: 16),
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
                    const SizedBox(width: 16),
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
          }
        },
      ),
    );
  }

  Widget _buildMaterialItem(MaterialInfo material) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MaterialListItem(
        onTap: () => _showMaterialDetail(context, material),
        materialName: material.baseInfo.prodNm ?? '无',
        primaryText: material.baseInfo.materialCode ?? '无',
        batchCode: material.baseInfo.batchCode ?? '无',
        materialId: material.baseInfo.materialCode ?? '无',
        status: material.baseInfo.status,
        statusName: material.baseInfo.statusName,
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
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            '正在追加材料信息...',
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
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getBusinessColor(
                      'acceptance',
                    ).withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.getBusinessColor('acceptance'),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '材料详情',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                // 内容区域
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: MaterialDetailDisplay(material: material),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 处理错误材料点击事件
  void _handleErrorMaterialTap(dynamic errorMaterial) {
    // 简单显示错误材料信息
    String errorInfo = '';
    try {
      if (errorMaterial is Map<String, dynamic>) {
        errorInfo =
            errorMaterial['errorMessage']?.toString() ??
            errorMaterial['error_message']?.toString() ??
            '异常材料信息';
      } else {
        errorInfo = '异常材料信息';
      }
    } catch (e) {
      errorInfo = '异常材料信息';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('异常材料详情'),
        content: Text(errorInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
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
                enableWatermark: true,
                watermarkText: '验收',
                includeTimeWatermark: true,
                includeLocationWatermark: true,
                states: states,
                maxImages: 10,
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
                title: '报验单(图片或pdf)',
                states: states,
                allowedExtensions: const ['pdf', 'jpg', 'png', 'heic'],
                maxFiles: 5,
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
                allowedExtensions: const ['pdf', 'jpg', 'png', 'heic'],
                maxFiles: 5,
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
            const SizedBox(height: 16),
            _buildWarehouseSelection(),
          ],
          if (_storageType == 'independent' && _warehouseUsers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildUserSection('仓库负责人', _warehouseUsers, 'warehouse'),
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
                // 切换回项目现场时清空仓库人员列表
                _warehouseUsers.clear();
                // 清除相关的推送状态
                _userPushStates.removeWhere(
                  (key, value) => key.startsWith('warehouse_'),
                );
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _storageType == 'project'
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey[50],
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
                    _storageType == 'project'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _storageType == 'project'
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('项目现场'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _storageType = 'independent';
              });
              _controller.handleEvent(const LoadJsfWarehouseList());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _storageType == 'independent'
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey[50],
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
                    _storageType == 'independent'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _storageType == 'independent'
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 20,
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
                  _selectedWarehouseId = newValue;
                  // 清空旧的仓库人员数据和推送状态
                  _warehouseUsers.clear();
                  _userPushStates.removeWhere(
                    (key, value) => key.startsWith('warehouse_'),
                  );
                });

                // 获取仓库用户
                if (newValue != null) {
                  _controller.handleEvent(
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                warehouse.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (warehouse.address.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  warehouse.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200],
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

  void _handleSubmitAcceptance() async {
    // 优先从编辑态取材；否则无材料则提示
    final currentState = _controller.currentState;
    if (currentState.materials.isEmpty) {
      context.showErrorToast('请先扫码添加材料');
      return;
    }

    // 检查是否有错误材料，如有则显示确认对话框
    if (currentState.errorMaterials.isNotEmpty) {
      final shouldContinue = await _showErrorMaterialSubmitConfirmation(
        currentState.errorMaterials.length,
      );
      if (!shouldContinue) {
        return; // 用户取消提交
      }
    }

    // 获取当前项目ID
    final sessionState = context.read<SessionBloc>().state;
    int? projectId;
    if (sessionState is SessionProjectEstablished) {
      projectId = sessionState.currentProject.projectId;
    }

    if (projectId == null) {
      context.showErrorToast('无法获取项目信息');
      return;
    }

    final sourceMaterials = currentState.materials;
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
              type: 1, // 1 for image
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
                (item) =>
                    item.status == UploadStatus.success &&
                    item.uploadResult != null,
                orElse: () => _inspectionReportsCubit.state.first,
              )
              .uploadResult
              ?.filePath;
    // 3. 验收报告
    final String? acceptReportUrl = _acceptanceReportsCubit.state.isEmpty
        ? null
        : _acceptanceReportsCubit.state
              .firstWhere(
                (item) =>
                    item.status == UploadStatus.success &&
                    item.uploadResult != null,
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

    // 获取选中的用户ID列表
    final selectedUserIds = _getSelectedUserIds();

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
      messageTo: selectedUserIds,
      // returnData 暂时为空，根据业务需求后续可扩展
    );

    // 通过Controller提交验收数据
    _controller.handleEvent(SubmitJsfAcceptance(request: jsfAcceptVO));

    context.showInfoToast('正在提交验收数据...');
  }

  void _handleReturn() {
    context.pop();
  }

  List<int> _getSelectedUserIds() {
    final selectedUserIds = <int>[];

    // 遍历推送状态，找到选中的用户
    _userPushStates.forEach((key, isSelected) {
      if (isSelected == true) {
        // 从key中解析出用户类型和用户名
        final parts = key.split('_');
        if (parts.length >= 2) {
          final userType = parts[0]; // 'warehouse'
          final userName = parts.sublist(1).join('_'); // 支持用户名包含下划线的情况

          // 根据用户类型在对应列表中查找用户ID
          CommonUserVO? user;
          switch (userType) {
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

  // 批量继续扫码追加材料
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

    // 获取当前项目采购方名称和供材类型
    final sessionState = context.read<SessionBloc>().state;
    String? projectPurNm;
    ProjectSupplyType? supplyType;
    if (sessionState is SessionProjectEstablished) {
      projectPurNm = sessionState.projectPurNm;
      supplyType = sessionState.currentUserRoleInfo.currentProjectSupplyType;
    }

    // Delegate code resolution to controller
    _controller.handleEvent(
      AppendJsfMaterialsByCodes(codes: res.addedCodes),
      projectPurNm: projectPurNm,
      supplyType: supplyType,
    );
  }

  // 扫码剔除
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
    _controller.handleEvent(RemoveJsfMaterialsByCodes(codes: res.removedCodes));
  }

  // 在 materialList 状态稳定后触发加载仓库列表，避免重复加载
  void _loadWarehousesIfNeeded(BuildContext context) {
    if (_hasLoadedWarehouses) return;

    _hasLoadedWarehouses = true;
    _controller.handleEvent(const LoadJsfWarehouseList());
  }

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
              Icon(Icons.warning, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              const Text('采购方验证警告'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '检测到以下材料不属于当前建设方采购的材料，继续验收操作可能出错：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mismatchMaterials
                        .map(
                          (material) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    material,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '请确认是否继续验收操作？',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                context.pop(); // 退出当前页面
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('取消操作'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
                _controller.handleEvent(
                  const ConfirmPurchaserValidationWarning(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('仍然继续'),
            ),
          ],
        );
      },
    );
  }

  /// 显示错误材料提交确认对话框
  Future<bool> _showErrorMaterialSubmitConfirmation(int errorCount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SubmitConfirmationDialog(
        normalCount: _controller.currentState.materials.length,
        errorCount: errorCount,
        title: '建设方验收提交确认',
        businessType: 'jsf_acceptance',
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
    return result == true;
  }
}
