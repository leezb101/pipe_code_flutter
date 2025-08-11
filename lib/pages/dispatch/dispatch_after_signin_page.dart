import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/dispatch/dispatch_bloc.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../models/dispatch/dispatch_detail_vo.dart';
import '../../models/acceptance/material_vo.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../models/dispatch/do_dispatch_sign_in_vo.dart';
import '../../models/common/common_user_vo.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../models/records/record_type.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';

class DispatchAfterSigninPage extends StatelessWidget {
  final int dispatchId;
  const DispatchAfterSigninPage({super.key, required this.dispatchId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialHandleCubit, MaterialHandleState>(
      listener: (context, materialHandleState) {
        if (materialHandleState is MaterialHandleScanSuccess) {
          // 扫描成功，物料信息交给DispatchBloc进行匹配
          context.read<DispatchBloc>().add(
            MatchScannedMaterial(
              scannedMaterial: materialHandleState.materialInfo,
            ),
          );
          // 给出一个即时反馈
          context.showSuccessToast('扫到二维码信息，正在匹配...');
        }
      },
      child: DispatchAfterSigninView(dispatchId: dispatchId),
    );
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
  }

  @override
  void dispose() {
    _fileUploadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('调拨后入库')),
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
    );
  }

  Widget _buildContent(
    BuildContext context,
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMaterialsList(
            context,
            dispatchInfo.materialList,
            matchedMaterials,
          ),
          const SizedBox(height: 16),
          _buildScanButton(context),
          const SizedBox(height: 16),
          BlocProvider.value(
            value: _fileUploadCubit,
            child: BlocBuilder<FileUploadCubit, List<FileUploadState>>(
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
          ),
          const SizedBox(height: 16),
          _buildWarehouseInfo(dispatchInfo),
          const SizedBox(height: 16),
          _buildUserInfo(dispatchInfo),
          const SizedBox(height: 32),
          _buildActionButtons(context, dispatchInfo, matchedMaterials),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(
    BuildContext context,
    List<MaterialVO> materials,
    Set<MaterialVO> matchedMaterials,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '物料清单',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...materials.map(
              (material) => _buildMaterialItem(material, matchedMaterials),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(
    MaterialVO material,
    Set<MaterialVO> matchedMaterials,
  ) {
    final isScanned = matchedMaterials.contains(material);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.materialName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${material.num}个',
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isScanned ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isScanned ? Colors.green : Colors.grey,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToQrScan(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          '扫码入库',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildWarehouseInfo(DispatchDetailVo dispatchInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '仓库',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('接收仓库:', dispatchInfo.toWarehouseName ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(DispatchDetailVo dispatchInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSection('发出方负责人', dispatchInfo.fromWarehouseUsers),
            const SizedBox(height: 8),
            _buildUserSection('接收方负责人', dispatchInfo.toWarehouseUsers),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildUserSection(String title, List<CommonUserVO> users) {
    if (users.isEmpty) return const SizedBox.shrink();

    final user = users.first;
    return Row(
      children: [
        Text(
          '$title:',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${user.name} - ${user.phone}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('返回'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _canSubmit(dispatchInfo, matchedMaterials)
                ? () => _submitSignin(context, dispatchInfo, matchedMaterials)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('确认'),
          ),
        ),
      ],
    );
  }

  void _navigateToQrScan(BuildContext context) {
    final materialCubit = context.read<MaterialHandleCubit>();
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: const [], // 这里无需去重，由后端匹配
      scanType: QrScanType.materialInbound,
      batch: false,
      context: const {'source': 'dispatchAfterSignin'},
      title: '扫码入库',
    );
    final config = flow.buildConfig(request);
    context.push<List<dynamic>>('/qr-scan', extra: config).then((raw) {
      if (!mounted) return;
      final res = flow.normalize(request, raw);
      for (final code in res.addedCodes) {
        materialCubit.getMaterialInfoFromQr(code);
      }
    });
  }

  bool _canSubmit(
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    final allMaterialScanned =
        matchedMaterials.length == dispatchInfo.materialList.length;
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
    if (!_canSubmit(dispatchInfo, matchedMaterials)) return;

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

    final request = DoDispatchSignInVo(
      dispatchId: widget.dispatchId,
      materialList: matchedMaterials.toList(),
      imageList: photoAttachments,
    );

    context.read<DispatchBloc>().add(SubmitDispatchSignIn(request));
  }
}
