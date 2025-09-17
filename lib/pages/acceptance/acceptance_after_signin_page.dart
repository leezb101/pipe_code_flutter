import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// Removed legacy QrScanResult import after migrating to QrScanFlowService
import '../../bloc/acceptance/acceptance_bloc.dart';
import '../../bloc/acceptance/acceptance_event.dart';
import '../../bloc/acceptance/acceptance_state.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../models/acceptance/acceptance_info_vo.dart';
import '../../models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation;
import '../../models/acceptance/attachment_vo.dart';
import '../../models/acceptance/do_accept_sign_in_vo.dart';
import '../../models/common/common_user_vo.dart';
// Removed direct dependency on QrScanConfig; using QrScanFlowService abstraction
import '../../models/records/record_type.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';
// MaterialHandleCubit no longer used here; bloc handles batch code resolution
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

class AcceptanceAfterSigninPage extends StatelessWidget {
  final int acceptanceId;
  const AcceptanceAfterSigninPage({super.key, required this.acceptanceId});

  // Map<int, bool> _scannedMaterials = {};
  // final List<XFile> _warehousePhotos = [];
  // final ImagePicker _picker = ImagePicker();
  // bool _isSubmitting = false;

  // void _initializeScannedMaterials(List<MaterialVO> materials) {
  //   _scannedMaterials = {
  //     for (var material in materials) material.materialId: false,
  //   };
  // }

  @override
  Widget build(BuildContext context) {
    // 页面直接负责导航与分发 Append/Remove 事件，仓库解析交给 AcceptanceBloc
    return AcceptanceAfterSigninView(acceptanceId: acceptanceId);
  }
}

class AcceptanceAfterSigninView extends StatefulWidget {
  final int acceptanceId;
  const AcceptanceAfterSigninView({super.key, required this.acceptanceId});

  @override
  State<AcceptanceAfterSigninView> createState() =>
      _AcceptanceAfterSigninViewState();
}

class _AcceptanceAfterSigninViewState extends State<AcceptanceAfterSigninView> {
  late final FileUploadCubit _fileUploadCubit;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fileUploadCubit = FileUploadCubit();
  }

  @override
  void dispose() {
    _fileUploadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _buildAppBarTitle()),
      backgroundColor: AppTheme.grey50,
      body: BlocConsumer<AcceptanceBloc, AcceptanceState>(
        // 当状态是AcceptanceSignedIn时，不用重建UI，因为listener会处理pop，避免未知状态闪烁
        buildWhen: (previous, current) => current is! AcceptanceSignedIn,
        listenWhen: (previous, current) {
          // 提交成功时触发
          if (current is AcceptanceSignedIn) return true;
          // 出现提示用户错误时出发
          if (current is AcceptanceError) return true;
          // 有新的匹配消息触发
          if (current is AcceptanceDetailLoaded &&
              current.matchMessage != null) {
            // 避免重复弹出相同的消息
            if (previous is AcceptanceDetailLoaded &&
                previous.matchMessage == current.matchMessage) {
              return false;
            }
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state is AcceptanceSignedIn) {
            // 触发记录列表刷新
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.todo),
            );
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.accept),
            );
            context.showSuccessToast('验收后入库成功', isGlobal: true);
            context.pop();
          }
          // 将扫码的错误处理统一放在listener中，而不是在UI中到处判断
          else if (state is AcceptanceError) {
            context.showErrorToast(state.message);

            if (_isSubmitting) {
              setState(() {
                _isSubmitting = false;
              });
            }
          } else if (state is AcceptanceDetailLoaded &&
              state.matchMessage != null) {
            context.showInfoToast(state.matchMessage!);
          }
        },
        builder: (context, state) {
          // builder现在只关心UI的构建
          if (state is AcceptanceDetailLoaded) {
            return _buildContent(
              context,
              state.acceptanceInfo,
              state.matchedMaterials,
            );
          }
          if (state is AcceptanceLoading) {
            return const common.LoadingWidget(message: "加载中...");
          }
          // 如果是错误状态，但不是从AcceptanceDetailLoaded派生的，显示一个通用的错误页
          if (state is AcceptanceError) {
            return common.ErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<AcceptanceBloc>().add(
                  LoadAcceptanceDetail(acceptanceId: widget.acceptanceId),
                );
              },
            );
          }

          return const Center(child: Text('未知状态'));
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return BlocBuilder<AcceptanceBloc, AcceptanceState>(
      buildWhen: (previous, current) =>
          current is AcceptanceDetailLoaded ||
          current is AcceptanceLoading ||
          current is AcceptanceError,
      builder: (context, state) {
        if (state is AcceptanceDetailLoaded) {
          final matched = state.matchedMaterials.length;
          final total = state.acceptanceInfo.materialList.length;
          return Text('验收后入库 ($matched/$total)');
        }
        return const Text('验收后入库');
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMaterialsList(
            context,
            acceptanceInfo.materialList,
            matchedMaterials,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildScanButtons(context),
          const SizedBox(height: AppTheme.spacingLarge),
          BlocBuilder<FileUploadCubit, List<FileUploadState>>(
            bloc: _fileUploadCubit,
            builder: (context, states) {
              return ImageUploadWidget(
                title: '入库照片',
                requiredPhotoCount: 2,
                states: states,
                onAdd: (files) {
                  _fileUploadCubit.addFiles(files);
                },
                onRemove: (uniqueId) {
                  _fileUploadCubit.removeFile(uniqueId);
                },
                onRetry: (uniqueId) {
                  _fileUploadCubit.retryUpload(uniqueId);
                },
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildWarehouseInfo(acceptanceInfo),
          const SizedBox(height: 16),
          _buildUserInfo(acceptanceInfo),
          const SizedBox(height: 32),
          // 同时监听验收详情状态与上传状态，确保按钮可用性及时更新
          BlocBuilder<AcceptanceBloc, AcceptanceState>(
            buildWhen: (prev, curr) => curr is AcceptanceDetailLoaded,
            builder: (context, accState) {
              final info = accState is AcceptanceDetailLoaded
                  ? accState.acceptanceInfo
                  : acceptanceInfo;
              final matched = accState is AcceptanceDetailLoaded
                  ? accState.matchedMaterials
                  : matchedMaterials;
              return BlocBuilder<FileUploadCubit, List<FileUploadState>>(
                bloc: _fileUploadCubit,
                builder: (context, _) {
                  return _buildActionButtons(context, info, matched);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(
    BuildContext context,
    List<MaterialVO> materials,
    Set<MaterialVO> matchedMaterials,
  ) {
    return UnifiedCard(
      title: '物料清单',
      icon: Icons.inventory,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: materials
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < materials.length - 1
                      ? AppTheme.spacingMedium
                      : 0,
                ),
                child: _buildMaterialItem(entry.value, matchedMaterials),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMaterialItem(
    MaterialVO material,
    Set<MaterialVO> matchedMaterials,
  ) {
    final isScanned = matchedMaterials.contains(material);

    return MaterialListItem(
      materialName: material.materialName,
      quantity: material.num,
      businessType: 'acceptance',
      trailing: Icon(
        isScanned ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isScanned
            ? AppTheme.getBusinessColor('acceptance')
            : Colors.grey,
        size: 32,
      ),
    );
  }

  Widget _buildScanButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _navigateToQrScanAppend(context),
            icon: Icon(Icons.qr_code_scanner),
            label: Text('扫码入库'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('acceptance'),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToQrScanRemove(context),
            icon: Icon(Icons.remove_circle_outline),
            label: Text('扫码剔除'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              side: BorderSide(color: Colors.red.shade300),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseInfo(AcceptanceInfoVO acceptanceInfo) {
    return UnifiedCard(
      title: '仓库',
      icon: Icons.warehouse,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: '', value: acceptanceInfo.warehouseTypeDescription),
        ],
      ),
    );
  }

  Widget _buildUserInfo(AcceptanceInfoVO acceptanceInfo) {
    return UnifiedCard(
      title: '负责人信息',
      icon: Icons.person,
      businessType: 'acceptance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (acceptanceInfo.supervisorUsers.isNotEmpty)
            _buildUserSection('监理方负责人', acceptanceInfo.supervisorUsers),
          if (acceptanceInfo.supervisorUsers.isNotEmpty &&
              acceptanceInfo.constructionUsers.isNotEmpty)
            SizedBox(height: AppTheme.spacingMedium),
          if (acceptanceInfo.constructionUsers.isNotEmpty)
            _buildUserSection('建设方负责人', acceptanceInfo.constructionUsers),
        ],
      ),
    );
  }

  Widget _buildUserSection(String title, List<CommonUserVO> users) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.getBusinessColor('acceptance'),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacingSmall),
        ...users
            .map(
              (user) => Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${user.name} - ${user.phone}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: user.realHandler == true
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (user.realHandler == true)
                      Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.getBusinessColor('acceptance'),
                        size: 16,
                      ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              side: BorderSide(color: AppTheme.getBusinessColor('acceptance')),
              foregroundColor: AppTheme.getBusinessColor('acceptance'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: Text('返回'),
          ),
        ),
        SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: ElevatedButton(
            onPressed: _canSubmit(acceptanceInfo, matchedMaterials)
                ? () => _submitSignin(context, acceptanceInfo, matchedMaterials)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('acceptance'),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('确认'),
          ),
        ),
      ],
    );
  }

  void _navigateToQrScanAppend(BuildContext context) {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: const [], // 页面不保留码级缓存，这里为空即可
      batch: true, // 批量扫码
      context: const {'source': 'acceptanceAfterSignin'},
      title: '扫码入库',
    );
    final config = flow.buildConfig(request);
    context.pushNamed<List<dynamic>>('qr-scan', extra: config).then((raw) {
      if (!mounted) return;
      final res = flow.normalize(request, raw);
      if (res.addedCodes.isEmpty) return;
      // 交给业务bloc批量解析并匹配
      context.read<AcceptanceBloc>().add(
        AppendMaterialsByCodes(codes: res.addedCodes),
      );
    });
  }

  void _navigateToQrScanRemove(BuildContext context) {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      currentCodes: const [], // 不基于现有码过滤，由业务层基于 materialId 处理
      batch: true,
      context: const {'source': 'acceptanceAfterSignin'},
      title: '扫码剔除',
    );
    final config = flow.buildConfig(request);
    context.pushNamed<List<dynamic>>('qr-scan', extra: config).then((raw) {
      if (!mounted) return;
      final res = flow.normalize(request, raw);
      if (res.removedCodes.isEmpty) return;
      // 交给业务bloc批量解析并剔除
      context.read<AcceptanceBloc>().add(
        RemoveMaterialsByCodes(codes: res.removedCodes),
      );
    });
  }

  bool _canSubmit(
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    // 严谨校验：按 materialId 一一匹配
    final expectedIds = acceptanceInfo.materialList
        .map((m) => m.materialId)
        .toSet();
    final matchedIds = matchedMaterials.map((m) => m.materialId).toSet();
    final allMaterialScanned =
        expectedIds.length == matchedIds.length &&
        matchedIds.containsAll(expectedIds);
    final uploadStates = _fileUploadCubit.state;
    final hasEnoughPhotos = uploadStates.length >= 2;
    final allPhotosUploaded = uploadStates.every(
      (s) => s.status == UploadStatus.success,
    );
    return allMaterialScanned &&
        hasEnoughPhotos &&
        allPhotosUploaded &&
        !_isSubmitting;
  }

  void _submitSignin(
    BuildContext context,
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    final uploadStates = _fileUploadCubit.state;
    final isUploading = uploadStates.any(
      (s) => s.status == UploadStatus.uploading,
    );
    if (isUploading) {
      context.showInfoToast('照片仍在上传中，请稍候...');
      return;
    }
    if (!mounted) return;
    if (!_canSubmit(acceptanceInfo, matchedMaterials)) return;

    setState(() => _isSubmitting = true);

    final photoAttachments = uploadStates
        .where(
          (s) => s.status == UploadStatus.success && s.uploadResult != null,
        )
        .map((state) {
          return AttachmentVO(
            type: 1,
            name: state.uploadResult!.fileName,
            url: state.uploadResult!.fileUrl,
            attachFormat: state.uploadResult!.fileType,
          );
        })
        .toList();

    final request = DoAcceptSignInVO(
      acceptId: widget.acceptanceId,
      materialList: matchedMaterials.toList(),
      imageList: photoAttachments,
    );

    context.read<AcceptanceBloc>().add(DoAcceptanceSignIn(request: request));
  }
}
