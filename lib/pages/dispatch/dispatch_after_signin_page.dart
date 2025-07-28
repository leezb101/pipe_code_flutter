import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
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
  final List<XFile> _warehousePhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

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
          _buildWarehousePhotos(),
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

  Widget _buildWarehousePhotos() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '入库照片',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' (至少2张)',
                  style: TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_warehousePhotos.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _warehousePhotos.asMap().entries.map((entry) {
                  final index = entry.key;
                  final photo = entry.value;
                  return _buildPhotoPreview(photo, index);
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('拍照'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview(XFile photo, int index) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(photo.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: IconButton(
            onPressed: () => _removePhoto(index),
            icon: const Icon(Icons.close),
            iconSize: 16,
            style: IconButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(24, 24),
            ),
          ),
        ),
      ],
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
    // 导航到扫码逻辑保持不变，但返回结果后处理方式不同
    final config = QrScanConfig(
      scanType: QrScanType.materialInbound,
      title: '扫码入库',
    );

    context.pushNamed('qr-scan', extra: config).then((result) {
      if (!context.mounted) return;
      if (result != null &&
          result is List<QrScanResult> &&
          result.first.code.isNotEmpty) {
        final qrCode = result.first.code;
        materialCubit.getMaterialInfoFromQr(qrCode);
      }
    });
  }

  bool _canSubmit(
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    final allMaterialScanned =
        matchedMaterials.length == dispatchInfo.materialList.length;
    final hasEnoughPhotos = _warehousePhotos.length >= 2;
    return allMaterialScanned && hasEnoughPhotos && !_isSubmitting;
  }

  Future<void> _takePhoto() async {
    final context = this.context;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _warehousePhotos.add(photo);
        });
      }
    } catch (e) {
      if (context.mounted) context.showErrorToast('拍照失败: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _warehousePhotos.removeAt(index);
    });
  }

  void _submitSignin(
    BuildContext context,
    DispatchDetailVo dispatchInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    if (!_canSubmit(dispatchInfo, matchedMaterials)) return;

    setState(() => _isSubmitting = true);

    final photoAttachments = _warehousePhotos.asMap().entries.map((entry) {
      return AttachmentVO(
        type: 1,
        name: 'warehouse_photo_${entry.key + 1}.jpg',
        url: entry.value.path,
        attachFormat: 1, // Image type
      );
    }).toList();

    final request = DoDispatchSignInVo(
      dispatchId: widget.dispatchId,
      materialList: matchedMaterials.toList(),
      imageList: photoAttachments,
    );

    context.read<DispatchBloc>().add(SubmitDispatchSignIn(request));
  }
}
