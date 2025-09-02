/*
 * @Author: LeeZB
 * @Date: 2025-07-24 19:50:22
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 16:09:04
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_bloc.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_event.dart';
import 'package:pipe_code_flutter/bloc/signout/signout_state.dart';
import 'package:pipe_code_flutter/bloc/user/user_bloc.dart';
import 'package:pipe_code_flutter/bloc/user/user_state.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/common/common_user_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/signout/do_signout_request_vo.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/utils/go_router_popuntil.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation;

import '../../models/material/material_info_base.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/constants/app_theme.dart';

class SignoutPage extends StatefulWidget {
  final MaterialInfoForBusiness? materials;
  final List<String>? initialCodes;
  final bool? initialIsBatch;

  const SignoutPage({
    super.key,
    this.materials,
    this.initialCodes,
    this.initialIsBatch,
  });

  @override
  State<SignoutPage> createState() => _SignoutPageState();
}

class _SignoutPageState extends State<SignoutPage> {
  late final FileUploadCubit _imageUploadCubit;
  final Map<String, bool?> _userPushStates = {};
  // 本地集合用于降级展示；主材料集合以 SignoutEditingState 为准
  late final List<MaterialInfo> _initialMaterials;

  @override
  void initState() {
    super.initState();
    _imageUploadCubit = FileUploadCubit();
    // 初始化本地材料集合
    _initialMaterials = [
      ...(widget.materials?.normals ?? const <MaterialInfo>[]),
    ];

    // 若来自 standalone 扫码，先解析 codes
    final codes = widget.initialCodes ?? const <String>[];
    if (codes.isNotEmpty) {
      context.read<SignoutBloc>().add(
        InitializeMaterialsFromCodes(
          codes: codes,
          isBatch: widget.initialIsBatch ?? (codes.length > 1),
        ),
      );
    }

    // 用传入 materials 初始化编辑态（便于扫码剔除）
    if (_initialMaterials.isNotEmpty) {
      context.read<SignoutBloc>().add(
        InitializeEditingMaterials(initial: _initialMaterials),
      );
      // 预加载一次仓库信息
      context.read<SignoutBloc>().add(
        LoadWarehouseInfo(
          materialId: _initialMaterials.first.baseInfo.materialId,
        ),
      );
    }
  }

  @override
  void dispose() {
    _imageUploadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignoutBloc, SignoutState>(
      listener: (context, state) {
        if (state is SignoutReady) {
          if (state.warehouseInfoError != null) {
            context.showErrorToast(state.warehouseInfoError!);
          }
          if (state.warehouseUsersError != null) {
            context.showErrorToast(state.warehouseUsersError!);
          }
          if (state.submitError != null && state.submitError!.isNotEmpty) {
            context.showErrorToast(state.submitError!);
          }
        } else if (state is SignoutEditingState) {
          // 展示编辑态的反馈消息
          if (state.message != null && state.message!.isNotEmpty) {
            final msg = state.message!;
            if (msg.contains('新增') || msg.contains('追加')) {
              context.showSuccessToast(msg);
            } else if (msg.contains('剔除') || msg.contains('移除')) {
              context.showSuccessToast(msg);
            } else {
              context.showInfoToast(msg);
            }
            context.read<SignoutBloc>().add(const ClearEditingMessage());
          }
          if (state.warehouseInfoError != null) {
            context.showErrorToast(state.warehouseInfoError!);
          }
          if (state.warehouseUsersError != null) {
            context.showErrorToast(state.warehouseUsersError!);
          }
          if (state.submitError != null && state.submitError!.isNotEmpty) {
            context.showErrorToast(state.submitError!);
          }
        } else if (state is SignoutDetailError) {
          context.showErrorToast(state.message);
        } else if (state is SignoutSubmitted) {
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
          backgroundColor: AppTheme.getBusinessColor('signout'),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _handleViewRecords,
              child: const Text(
                '出库记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  children: [
                    _buildMaterialsList(),
                    const SizedBox(height: AppTheme.spacingLarge),
                    _buildPhotosSection(),
                    const SizedBox(height: AppTheme.spacingLarge),
                    BlocBuilder<SignoutBloc, SignoutState>(
                      builder: (context, state) {
                        if (state is SignoutEditingState) {
                          // Bridge editing state into a lightweight SignoutReady-like object for rendering
                          final ready = SignoutReady(
                            warehouseInfo: state.warehouseInfo,
                            warehouseInfoError: state.warehouseInfoError,
                            isWarehouseInfoLoading:
                                state.isWarehouseInfoLoading,
                            isWarehouseUsersLoading:
                                state.isWarehouseUsersLoading,
                            warehouseUsers: state.warehouseUsers,
                            warehouseUsersError: state.warehouseUsersError,
                          );
                          return _buildWarehouseSection(ready);
                        } else if (state is SignoutReady) {
                          return _buildWarehouseSection(state);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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
      businessType: 'signout',
      child: BlocBuilder<SignoutBloc, SignoutState>(
        builder: (context, state) {
          final materials = state is SignoutEditingState
              ? state.currentMaterials
              : _initialMaterials;
          return Column(
            children: [
              ...materials.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < materials.length - 1
                        ? AppTheme.spacingMedium
                        : 0,
                  ),
                  child: _buildMaterialItem(entry.value),
                ),
              ),
              SizedBox(height: AppTheme.spacingMedium),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _scanAppendMaterials,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMedium,
                        ),
                        side: BorderSide(
                          color: AppTheme.getBusinessColor('signout'),
                        ),
                        foregroundColor: AppTheme.getBusinessColor('signout'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                      ),
                      child: const Text('继续扫码'),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _scanRemoveMaterials,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppTheme.spacingMedium,
                        ),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                      ),
                      child: const Text('扫码剔除'),
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
    return MaterialListItem(
      materialName: material.baseInfo.prodNm ?? '',
      materialId: material.baseInfo.materialId.toString(),
      quantity: 1,
      businessType: 'signout',
    );
  }

  Widget _buildPhotosSection() {
    return UnifiedCard(
      title: '现场照片',
      icon: Icons.photo_camera,
      businessType: 'signout',
      child: BlocBuilder<FileUploadCubit, List<FileUploadState>>(
        bloc: _imageUploadCubit,
        builder: (context, states) {
          return ImageUploadWidget(
            states: states,
            onAdd: (files) => _imageUploadCubit.addFiles(files),
            onRemove: (uniqueId) => _imageUploadCubit.removeFile(uniqueId),
            onRetry: (uniqueId) => _imageUploadCubit.retryUpload(uniqueId),
            maxImages: 9,
          );
        },
      ),
    );
  }

  Widget _buildWarehouseSection(SignoutReady state) {
    return UnifiedCard(
      title: '仓库信息',
      icon: Icons.warehouse,
      businessType: 'signout',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarehouseInfo(state),
          SizedBox(height: AppTheme.spacingLarge),
          if (state.isWarehouseUsersLoading)
            _buildWarehouseUsersSkeleton()
          else if (state.warehouseUsers != null)
            _buildWarehouseUsers(state.warehouseUsers!.warehouseUsers),
          SizedBox(height: AppTheme.spacingLarge),
          _buildInstallationUser(context),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo(SignoutReady state) {
    if (state.isWarehouseInfoLoading) {
      return Container(
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: AppTheme.getBusinessColor('signout').withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.getBusinessColor('signout').withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeletonBox(
              width: 80,
              height: 16,
              color: AppTheme.getBusinessColor('signout').withOpacity(0.2),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            _skeletonBox(
              width: 220,
              height: 16,
              color: AppTheme.getBusinessColor('signout').withOpacity(0.2),
            ),
          ],
        ),
      );
    }

    if (state.warehouseInfo == null) {
      return Container(
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
            SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Text(
                '尚未获取到仓库信息，将在成功解析首个耗材后自动获取。',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    return InfoRow(
      label: '发出仓库',
      value: state.warehouseInfo?.name ?? '',
      backgroundColor: AppTheme.getBusinessColor('signout').withOpacity(0.1),
      borderRadius: AppTheme.radiusMedium,
    );
  }

  Widget _buildWarehouseUsers(List<CommonUserVO>? users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '仓库负责人：',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (users != null && users.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text(
              '暂无仓库负责人数据',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else if (users != null)
          ...users.map((user) => _buildUserItem(user, 'warehouse'))
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Text(
              '暂无仓库负责人数据',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildInstallationUser(BuildContext context) {
    final userstate = context.read<UserBloc>().state;
    String? userName;
    if (userstate is UserLoaded) {
      userName = userstate.wxLoginVO.name;
    } else {
      userName = '未知';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出库安装负责人：',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildWarehouseUsersSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(width: 120, height: 12),
                    const SizedBox(height: 6),
                    _skeletonBox(width: 180, height: 10),
                  ],
                ),
              ),
              _skeletonBox(width: 50, height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _skeletonBox({
    double width = double.infinity,
    double height = 14,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BlocBuilder<SignoutBloc, SignoutState>(
          builder: (context, state) {
            final isSubmitting =
                (state is SignoutEditingState && state.isSubmitting) ||
                (state is SignoutSubmitting);
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getBusinessColor('signout'),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.spacingLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppTheme.spacingSmall),
                              const Text(
                                '提交中…',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            '提交',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleReturn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.spacingLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: const Text(
                      '返回',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleViewRecords() {
    context.go('/records?tab=signout');
  }

  void _handleSubmit() {
    final uploadStates = _imageUploadCubit.state;
    final isUploading = uploadStates.any(
      (s) => s.status == UploadStatus.uploading,
    );
    if (isUploading) {
      context.showInfoToast('照片仍在上传中，请稍候...');
      return;
    }

    final hasFailures = uploadStates.any(
      (s) => s.status == UploadStatus.failure,
    );
    if (hasFailures) {
      context.showErrorToast('有图片上传失败，请重试或删除。');
      return;
    }

    final photoAttachments = uploadStates
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
        )
        .toList();

    // 读取当前编辑态材料
    final signoutState = context.read<SignoutBloc>().state;
    final editingMaterials = signoutState is SignoutEditingState
        ? signoutState.currentMaterials
        : _initialMaterials;
    if (editingMaterials.isEmpty) {
      context.showInfoToast('请先扫码选择要出库的物料');
      return;
    }

    final selectedUserIds = _getSelectedUserIds();

    final materialList = editingMaterials
        .map(
          (m) => MaterialVO(
            materialId: m.baseInfo.materialId,
            materialName: m.baseInfo.prodNm ?? '',
            num: 1,
          ),
        )
        .toList();

    final request = DoSignoutRequestVo(
      materialList: materialList,
      imageList: photoAttachments,
      messageTo: selectedUserIds,
    );

    context.read<SignoutBloc>().add(SubmitSignout(request: request));
    context.showInfoToast('正在提交出库数据...');
  }

  void _handleReturn() {
    context.pop();
  }

  List<int> _getSelectedUserIds() {
    final selectedUserIds = <int>[];
    final st = context.read<SignoutBloc>().state;
    // unify access to warehouse users list from either editing or ready state
    List<CommonUserVO>? warehouseUsers;
    if (st is SignoutEditingState) {
      warehouseUsers = st.warehouseUsers?.warehouseUsers;
    } else if (st is SignoutReady) {
      warehouseUsers = st.warehouseUsers?.warehouseUsers;
    }

    _userPushStates.forEach((key, isSelected) {
      if (isSelected == true) {
        final parts = key.split('_');
        if (parts.length >= 2) {
          final userType = parts[0];
          final userName = parts.sublist(1).join('_');

          CommonUserVO? user;
          if (userType == 'warehouse' && warehouseUsers != null) {
            user = warehouseUsers.firstWhere(
              (u) => u.name == userName,
              orElse: () => const CommonUserVO(userId: -1, name: '', phone: ''),
            );
          }

          if (user != null && user.userId > 0) {
            selectedUserIds.add(user.userId);
          }
        }
      }
    });

    return selectedUserIds;
  }

  // 继续扫码：解析新增码并交给 Bloc 追加
  Future<void> _scanAppendMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'signoutPage_append',
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
    context.read<SignoutBloc>().add(
      AppendEditingMaterialsByCodes(codes: res.addedCodes),
    );
  }

  // 扫码剔除：解析移除码后从编辑态集合中剔除对应 materialId
  Future<void> _scanRemoveMaterials() async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'signoutPage_remove',
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
    context.read<SignoutBloc>().add(
      RemoveEditingMaterialsByCodes(codes: res.removedCodes),
    );
  }
}
