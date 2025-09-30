import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/repositories/interfaces/dispatch_repository.dart';
import 'package:pipe_code_flutter/services/api/interfaces/common_query_api_service.dart';
import '../../bloc/dispatch/dispatch_bloc.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../models/dispatch/dispatch_detail_vo.dart';
import '../../models/acceptance/material_vo.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../models/dispatch/do_dispatch_sign_in_vo.dart';
import '../../models/common/common_user_vo.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/records/record_type.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';
// 移除逐个扫码 Cubit 依赖，改用批量扫码流程
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';

class DispatchAfterSigninPage extends StatelessWidget {
  final int dispatchId;
  const DispatchAfterSigninPage({super.key, required this.dispatchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DispatchBloc>(
      create: (context) => DispatchBloc(
        dispatchRepository: getIt<DispatchRepository>(),
        commonQueryApiService: getIt<CommonQueryApiService>(),
      ),
      child: _DispatchAfterSigninPageView(dispatchId: dispatchId),
    );
  }
}

class _DispatchAfterSigninPageView extends StatelessWidget {
  final int dispatchId;
  const _DispatchAfterSigninPageView({required this.dispatchId});

  @override
  Widget build(BuildContext context) {
    // 直接返回视图，扫码交互走 QrScanFlowService
    return DispatchAfterSigninView(dispatchId: dispatchId);
  }
}

class DispatchAfterSigninView extends StatefulWidget {
  final int dispatchId;
  const DispatchAfterSigninView({super.key, required this.dispatchId});

  @override
  State<DispatchAfterSigninView> createState() =>
      _DispatchAfterSigninViewState();
}

class _DispatchAfterSigninViewState extends State<DispatchAfterSigninView> {
  late final FileUploadCubit _fileUploadCubit;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fileUploadCubit = FileUploadCubit();
    context.read<DispatchBloc>().add(LoadDispatchDetail(widget.dispatchId));
  }

  @override
  void dispose() {
    _fileUploadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileUploadCubit>.value(
      value: _fileUploadCubit,
      child: Scaffold(
        appBar: AppBar(
          title: _buildAppBarTitle(),
          backgroundColor: AppTheme.getBusinessColor('dispatch'),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        backgroundColor: AppTheme.grey50,
        body: BlocConsumer<DispatchBloc, DispatchState>(
          // 当状态是DispatchSignedIn时，不用重建UI，因为listener会处理pop，避免未知状态闪烁
          buildWhen: (previous, current) =>
              current.status != DispatchStatus.signInSuccess,
          listenWhen: (previous, current) {
            // 提交成功时触发
            if (current.status == DispatchStatus.signInSuccess) return true;
            // 出现提示用户错误时出发
            if (current.status == DispatchStatus.failure) return true;
            // 有新的匹配消息触发
            if (current.matchMessage != null) {
              // 避免重复弹出相同的消息
              if (previous.matchMessage == current.matchMessage) {
                return false;
              }
              return true;
            }
            return false;
          },
          listener: (context, state) {
            if (state.status == DispatchStatus.signInSuccess) {
              context.showSuccessToast('调拨后入库成功', isGlobal: true);
              context.pop();
              // 触发记录列表刷新
              context.read<RecordsBloc>().add(
                RefreshRecords(recordType: RecordType.todo),
              );
              context.read<RecordsBloc>().add(
                RefreshRecords(recordType: RecordType.dispatch),
              );
            }
            // 将扫码的错误处理统一放在listener中，而不是在UI中到处判断
            else if (state.status == DispatchStatus.failure) {
              context.showErrorToast(state.errorMessage ?? '操作失败');

              if (_isSubmitting) {
                setState(() {
                  _isSubmitting = false;
                });
              }
            } else if (state.matchMessage != null) {
              context.showInfoToast(state.matchMessage!);
            }
          },
          builder: (context, state) {
            // builder现在只关心UI的构建
            if (state.status == DispatchStatus.success &&
                state.dispatchDetail != null) {
              return _buildContent(
                context,
                state.dispatchDetail!,
                state.matchedMaterials,
              );
            }
            if (state.status == DispatchStatus.loading) {
              return const common.LoadingWidget(message: "加载中...");
            }
            // 如果是错误状态，显示一个通用的错误页
            if (state.status == DispatchStatus.failure) {
              return common.ErrorWidget(
                message: state.errorMessage ?? '加载失败',
                onRetry: () {
                  context.read<DispatchBloc>().add(
                    LoadDispatchDetail(widget.dispatchId),
                  );
                },
              );
            }

            return const Center(child: Text('未知状态'));
          },
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return BlocBuilder<DispatchBloc, DispatchState>(
      buildWhen: (previous, current) =>
          current.status == DispatchStatus.success ||
          current.status == DispatchStatus.loading ||
          current.status == DispatchStatus.failure,
      builder: (context, state) {
        if (state.status == DispatchStatus.success &&
            state.dispatchDetail != null) {
          final matched = state.matchedMaterials.length;
          final total = state.dispatchDetail!.materialList.length;
          return Text(
            '调拨后入库 ($matched/$total)',
            style: TextStyle(color: Colors.white),
          );
        }
        return Text('调拨后入库', style: TextStyle(color: Colors.white));
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMaterialsList(
            context,
            dispatchInfo.materialList,
            matchedMaterials,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildScanButtons(context),
          const SizedBox(height: AppTheme.spacingLarge),
          BlocBuilder<FileUploadCubit, List<FileUploadState>>(
            builder: (context, states) {
              return ImageUploadWidget(
                title: '入库照片',
                requiredPhotoCount: 2,
                watermarkText: '调拨后入库',
                includeTimeWatermark: true,
                includeLocationWatermark: true,
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
          _buildWarehouseInfo(dispatchInfo),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildUserInfo(dispatchInfo),
          const SizedBox(height: AppTheme.spacingXXLarge),
          // 监听上传状态变化，确保按钮可用性立即刷新
          BlocBuilder<FileUploadCubit, List<FileUploadState>>(
            builder: (context, uploadStates) => _buildActionButtons(
              context,
              dispatchInfo,
              matchedMaterials,
              uploadStates,
            ),
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
      businessType: 'dispatch',
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
      businessType: 'dispatch',
      trailing: Icon(
        isScanned ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isScanned ? AppTheme.getBusinessColor('dispatch') : Colors.grey,
        size: 32,
      ),
    );
  }

  Widget _buildScanButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _scanAppendMaterials(context),
            icon: Icon(Icons.qr_code_scanner),
            label: Text('扫码入库'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('dispatch'),
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
            onPressed: () => _scanRemoveMaterials(context),
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

  Widget _buildWarehouseInfo(DispatchDetailVo dispatchInfo) {
    return UnifiedCard(
      title: '仓库',
      icon: Icons.warehouse,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: '接收仓库', value: dispatchInfo.toWarehouseName ?? '未知仓库'),
        ],
      ),
    );
  }

  Widget _buildUserInfo(DispatchDetailVo dispatchInfo) {
    return UnifiedCard(
      title: '负责人信息',
      icon: Icons.person,
      businessType: 'dispatch',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dispatchInfo.fromWarehouseUsers.isNotEmpty)
            _buildUserSection('发出方负责人', dispatchInfo.fromWarehouseUsers),
          if (dispatchInfo.fromWarehouseUsers.isNotEmpty &&
              dispatchInfo.toWarehouseUsers.isNotEmpty)
            SizedBox(height: AppTheme.spacingMedium),
          if (dispatchInfo.toWarehouseUsers.isNotEmpty)
            _buildUserSection('接收方负责人', dispatchInfo.toWarehouseUsers),
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
            color: AppTheme.getBusinessColor('dispatch'),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppTheme.spacingSmall),
        ...users.map(
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
                    color: AppTheme.getBusinessColor('dispatch'),
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
    List<FileUploadState> uploadStates,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
              side: BorderSide(color: AppTheme.getBusinessColor('dispatch')),
              foregroundColor: AppTheme.getBusinessColor('dispatch'),
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
            onPressed: _canSubmit(dispatchInfo, matchedMaterials, uploadStates)
                ? () => _submitSignin(context, dispatchInfo, matchedMaterials)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getBusinessColor('dispatch'),
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

  Future<void> _scanAppendMaterials(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'dispatchAfterSignin_append',
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
    if (res.addedCodes.isEmpty || !context.mounted) return;
    context.read<DispatchBloc>().add(
      AppendSigninMatchedByCodes(res.addedCodes),
    );
  }

  Future<void> _scanRemoveMaterials(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.remove,
      currentCodes: const <String>[],
      batch: true,
      context: const {
        'source': 'dispatchAfterSignin_remove',
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
    if (res.removedCodes.isEmpty || !context.mounted) return;
    context.read<DispatchBloc>().add(
      RemoveSigninMatchedByCodes(res.removedCodes),
    );
  }

  bool _canSubmit(
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
    List<FileUploadState> uploadStates,
  ) {
    // 按 materialId 严格匹配，避免仅比长度导致误判
    final expectedIds = dispatchInfo.materialList
        .map((m) => m.materialId)
        .toSet();
    final matchedIds = matchedMaterials.map((m) => m.materialId).toSet();
    final allMaterialScanned =
        expectedIds.length == matchedIds.length &&
        matchedIds.containsAll(expectedIds);

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
    DispatchDetailVo dispatchInfo,
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
    if (!_canSubmit(dispatchInfo, matchedMaterials, uploadStates)) return;

    setState(() => _isSubmitting = true);

    final photoAttachments = uploadStates
        .where(
          (s) => s.status == UploadStatus.success && s.uploadResult != null,
        )
        .map((state) {
          return AttachmentVO(
            type: 1,
            name: state.uploadResult!.fileName,
            url: state.uploadResult!.filePath,
            attachFormat: state.uploadResult!.fileType,
          );
        })
        .toList();

    final request = DoDispatchSignInVo(
      dispatchId: widget.dispatchId,
      materialList: matchedMaterials.toList(),
      imageList: photoAttachments,
    );

    context.read<DispatchBloc>().add(SubmitDispatchSignIn(request));
  }
}
