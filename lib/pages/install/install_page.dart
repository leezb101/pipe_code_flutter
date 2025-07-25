import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import 'package:pipe_code_flutter/repositories/install_repository.dart';
import '../../bloc/install/install_bloc.dart';
import '../../bloc/install/install_event.dart';
import '../../bloc/install/install_state.dart';
import '../../models/install/do_install_vo.dart';
import '../../models/acceptance/material_vo.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';

class InstallPage extends StatelessWidget {
  final String? signOutId;

  const InstallPage({super.key, this.signOutId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaterialHandleCubit, MaterialHandleState>(
      listener: (context, materialHandleState) {
        if (materialHandleState is MaterialHandleScanSuccess) {
          // 扫描成功，物料信息交给InstallBloc进行添加
          context.read<InstallBloc>().add(
            AppendScannedMaterial(
              materialInfo: materialHandleState.materialInfo,
            ),
          );
          // 给出一个即时反馈
          context.showSuccessToast('扫到二维码信息，正在处理...');
        }
      },
      child: InstallView(signOutId: signOutId),
    );
  }
}

class InstallView extends StatefulWidget {
  final String? signOutId;

  const InstallView({super.key, this.signOutId});

  @override
  State<InstallView> createState() => _InstallViewState();
}

class _InstallViewState extends State<InstallView> {
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // 存储每个材料的照片和桩号
  final Map<int, List<XFile>> _materialPhotos = {};
  final Map<int, String> _materialStakeNumbers = {};
  final Map<int, TextEditingController> _stakeNumberControllers = {};

  // 质量验收报告
  String? _qualityReportUrl;

  @override
  void dispose() {
    // 清理控制器
    for (var controller in _stakeNumberControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一管一码'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 导航到安装记录页面
            },
            child: const Text('安装记录', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: BlocConsumer<InstallBloc, InstallState>(
        buildWhen: (previous, current) => current is! InstallSuccess,
        listenWhen: (previous, current) {
          // 提交成功时触发
          if (current is InstallSuccess) return true;
          // 出现提示用户错误时触发
          if (current is InstallFailure) return true;
          // 有新的扫码消息触发
          if (current is InstallReady && current.materialScanMessage != null) {
            // 避免重复弹出相同的消息
            if (previous is InstallReady &&
                previous.materialScanMessage == current.materialScanMessage) {
              return false;
            }
            return true;
          }
          return false;
        },
        listener: (context, state) {
          if (state is InstallSuccess) {
            context.showSuccessToast('安装提交成功', isGlobal: true);
            context.pop();
          } else if (state is InstallFailure) {
            context.showErrorToast(state.error);
            if (_isSubmitting) {
              setState(() {
                _isSubmitting = false;
              });
            }
          } else if (state is InstallReady &&
              state.materialScanMessage != null) {
            context.showInfoToast(state.materialScanMessage!);
          }
        },
        builder: (context, state) {
          if (state is InstallReady) {
            return _buildContent(context, state);
          }
          if (state is InstallLoading) {
            return const common.LoadingWidget(message: "加载中...");
          }
          if (state is InstallFailure) {
            return common.ErrorWidget(message: state.error, onRetry: () {});
          }
          return const Center(child: Text('未知状态'));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, InstallReady state) {
    final scannedMaterials = state.materialInfos?.normals ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (scannedMaterials.isNotEmpty) ...[
            _buildMaterialsList(scannedMaterials),
            const SizedBox(height: 16),
          ],
          _buildQualityReportSection(),
          const SizedBox(height: 16),
          _buildScanButton(context),
          const SizedBox(height: 32),
          _buildActionButtons(
            context,
            scannedMaterials
                .map(
                  (m) => MaterialVO(
                    materialId: m.materialId,
                    materialName: m.prodNm ?? '未知材料',
                    num: 1,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(List<MaterialInfoBase> materials) {
    return Column(
      children: materials
          .map(
            (m) => MaterialVO(
              materialId: m.materialId,
              materialName: m.prodNm ?? '未知材料',
              num: 1,
            ),
          )
          .map((material) => _buildMaterialItem(material))
          .toList(),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    final materialId = material.materialId;
    final photos = _materialPhotos[materialId] ?? [];

    // 确保控制器存在
    if (!_stakeNumberControllers.containsKey(materialId)) {
      _stakeNumberControllers[materialId] = TextEditingController();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 材料信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    material.materialName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${material.num}个',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 安装照片部分
            const Text(
              '安装照片',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // 第一张照片
                _buildPhotoSlot(materialId, 0, photos),
                const SizedBox(width: 12),
                // 第二张照片
                _buildPhotoSlot(materialId, 1, photos),
                const Spacer(),
                // 拍照按钮
                OutlinedButton(
                  onPressed: () => _takePhoto(materialId),
                  child: const Text('拍照'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 桩号输入
            Row(
              children: [
                const Text(
                  '桩号:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stakeNumberControllers[materialId],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      _materialStakeNumbers[materialId] = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(int materialId, int photoIndex, List<XFile> photos) {
    final hasPhoto = photos.length > photoIndex;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: hasPhoto
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(photos[photoIndex].path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: IconButton(
                    onPressed: () => _removePhoto(materialId, photoIndex),
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
            )
          : const Icon(Icons.camera_alt, color: Colors.grey, size: 32),
    );
  }

  Widget _buildQualityReportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _qualityReportUrl != null ? 'XXX安装质量验收报告.pdf' : '安装质量验收报告:',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                OutlinedButton(
                  onPressed: _uploadQualityReport,
                  child: const Text('上传附件'),
                ),
              ],
            ),
          ],
        ),
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
          '扫码安装',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, List<MaterialVO> materials) {
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
            onPressed: _canSubmit(materials)
                ? () => _submitInstall(context, materials)
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
                : const Text('提交'),
          ),
        ),
      ],
    );
  }

  void _navigateToQrScan(BuildContext context) {
    final config = QrScanConfig(scanType: QrScanType.install, title: '扫码安装');

    context.pushNamed('qr-scan', extra: config).then((result) {
      if (mounted &&
          result != null &&
          result is List<QrScanResult> &&
          result.first.code.isNotEmpty) {
        final qrCode = result.first.code;
        context.read<MaterialHandleCubit>().getMaterialInfoFromQr(qrCode);
      }
    });
  }

  Future<void> _takePhoto(int materialId) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        setState(() {
          _materialPhotos[materialId] = (_materialPhotos[materialId] ?? [])
            ..add(photo);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('拍照失败: $e');
      }
    }
  }

  void _removePhoto(int materialId, int photoIndex) {
    setState(() {
      final photos = _materialPhotos[materialId];
      if (photos != null && photoIndex < photos.length) {
        photos.removeAt(photoIndex);
      }
    });
  }

  void _uploadQualityReport() {
    // TODO: 实现文件上传逻辑
    setState(() {
      _qualityReportUrl = 'dummy_report_url.pdf';
    });
    if (mounted) {
      context.showSuccessToast('质量验收报告上传成功');
    }
  }

  bool _canSubmit(List<MaterialVO> materials) {
    if (materials.isEmpty || _isSubmitting) return false;

    // 检查每个材料是否都有两张照片和桩号
    for (final material in materials) {
      final materialId = material.materialId;
      final photos = _materialPhotos[materialId] ?? [];
      final stakeNumber = _materialStakeNumbers[materialId] ?? '';

      if (photos.length < 2 || stakeNumber.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  void _submitInstall(BuildContext context, List<MaterialVO> materials) {
    if (!_canSubmit(materials)) return;

    setState(() => _isSubmitting = true);

    // 构建所有照片附件
    final List<AttachmentVO> allAttachments = [];

    for (final material in materials) {
      final materialId = material.materialId;
      final photos = _materialPhotos[materialId] ?? [];

      for (int i = 0; i < photos.length; i++) {
        allAttachments.add(
          AttachmentVO(
            type: 1,
            name: 'install_photo_${materialId}_${i + 1}.jpg',
            url: photos[i].path,
            attachFormat: 1, // Image type
          ),
        );
      }
    }

    final request = DoInstallVo(
      materialList: materials,
      imageList: allAttachments,
      installQualityUrl: _qualityReportUrl,
      onlyInstall: true,
      signOutId: widget.signOutId != null
          ? int.tryParse(widget.signOutId!)
          : null,
    );

    context.read<InstallBloc>().add(DoInstall(request: request));
  }
}
