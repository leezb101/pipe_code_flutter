import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/acceptance/acceptance_bloc.dart';
import '../../bloc/acceptance/acceptance_event.dart';
import '../../bloc/acceptance/acceptance_state.dart';
import '../../models/acceptance/acceptance_info_vo.dart';
import '../../models/acceptance/material_vo.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../models/acceptance/do_accept_sign_in_vo.dart';
import '../../models/common/common_user_vo.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';

class AcceptanceAfterSigninPage extends StatefulWidget {
  final int acceptanceId;

  const AcceptanceAfterSigninPage({super.key, required this.acceptanceId});

  @override
  State<AcceptanceAfterSigninPage> createState() =>
      _AcceptanceAfterSigninPageState();
}

class _AcceptanceAfterSigninPageState extends State<AcceptanceAfterSigninPage> {
  Map<int, bool> _scannedMaterials = {};
  final List<XFile> _warehousePhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAcceptanceDetail();
  }

  void _loadAcceptanceDetail() {
    context.read<AcceptanceBloc>().add(
      LoadAcceptanceDetail(acceptanceId: widget.acceptanceId),
    );
  }

  void _initializeScannedMaterials(List<MaterialVO> materials) {
    _scannedMaterials = {
      for (var material in materials) material.materialId: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('验收后入库'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AcceptanceBloc, AcceptanceState>(
        listener: (context, state) {
          if (state is AcceptanceError) {
            context.showErrorToast(state.message);
          } else if (state is MaterialScanError) {
            context.showErrorToast(state.message);
          } else if (state is AcceptanceSignedIn) {
            context.showSuccessToast('入库成功');
            context.pop();
          } else if (state is MaterialScanned && state.materialId != null) {
            setState(() {
              _scannedMaterials[state.materialId!] = true;
            });
            context.showSuccessToast('物料匹配成功');
          }
        },
        builder: (context, state) {
          if (state is AcceptanceLoading) {
            return const common.LoadingWidget();
          }

          if (state is AcceptanceError) {
            return common.ErrorWidget(
              message: state.message,
              onRetry: _loadAcceptanceDetail,
            );
          }

          // Handle states that contain AcceptanceDetail data
          AcceptanceInfoVO? acceptanceInfo;
          
          if (state is AcceptanceDetailLoaded) {
            acceptanceInfo = state.acceptanceInfo;
          } else if (state is MaterialScanned && state.acceptanceInfo != null) {
            acceptanceInfo = state.acceptanceInfo;
          } else if (state is MaterialScanError && state.acceptanceInfo != null) {
            acceptanceInfo = state.acceptanceInfo;
          }

          if (acceptanceInfo != null) {
            if (_scannedMaterials.isEmpty) {
              _initializeScannedMaterials(acceptanceInfo.materialList);
            }
            return _buildContent(acceptanceInfo);
          }

          return const Center(child: Text('暂无数据'));
        },
      ),
    );
  }

  Widget _buildContent(AcceptanceInfoVO acceptanceInfo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMaterialsList(acceptanceInfo.materialList),
          const SizedBox(height: 16),
          _buildScanButton(),
          const SizedBox(height: 16),
          _buildWarehousePhotos(),
          const SizedBox(height: 16),
          _buildWarehouseInfo(acceptanceInfo),
          const SizedBox(height: 16),
          _buildUserInfo(acceptanceInfo),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(List<MaterialVO> materials) {
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
            ...materials.map((material) => _buildMaterialItem(material)),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    final isScanned = _scannedMaterials[material.materialId] ?? false;

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

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _navigateToQrScan,
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

  Widget _buildWarehouseInfo(AcceptanceInfoVO acceptanceInfo) {
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
            _buildInfoRow('', acceptanceInfo.warehouseTypeDescription),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(AcceptanceInfoVO acceptanceInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSection('监理方负责人', acceptanceInfo.supervisorUsers),
            const SizedBox(height: 8),
            _buildUserSection('建设方负责人', acceptanceInfo.constructionUsers),
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

  Widget _buildActionButtons() {
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
            onPressed: _canSubmit() ? _submitSignin : null,
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

  bool _canSubmit() {
    final allMaterialsScanned = _scannedMaterials.values.every(
      (scanned) => scanned,
    );
    final hasEnoughPhotos = _warehousePhotos.length >= 2;
    return allMaterialsScanned && hasEnoughPhotos && !_isSubmitting;
  }

  void _navigateToQrScan() {
    final config = QrScanConfig(
      scanType: QrScanType.materialInbound,
      scanMode: QrScanMode.single,
      title: '扫码识别物料',
    );

    context.push('/qr-scan', extra: config).then((result) {
      if (result != null && result is List && result.isNotEmpty) {
        final scannedCode = result.first.code;
        _processScanResult(scannedCode);
      }
    });
  }

  void _processScanResult(String scannedCode) {
    context.read<AcceptanceBloc>().add(
      ScanMaterialForSignin(scannedCode: scannedCode),
    );
  }

  Future<void> _takePhoto() async {
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
      context.showErrorToast('拍照失败: $e');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _warehousePhotos.removeAt(index);
    });
  }

  void _submitSignin() {
    final state = context.read<AcceptanceBloc>().state;
    
    // Get acceptance info from various state types
    AcceptanceInfoVO? acceptanceInfo;
    if (state is AcceptanceDetailLoaded) {
      acceptanceInfo = state.acceptanceInfo;
    } else if (state is MaterialScanned && state.acceptanceInfo != null) {
      acceptanceInfo = state.acceptanceInfo;
    } else if (state is MaterialScanError && state.acceptanceInfo != null) {
      acceptanceInfo = state.acceptanceInfo;
    }
    
    if (acceptanceInfo == null) return;

    setState(() {
      _isSubmitting = true;
    });

    // Convert photos to AttachmentVO format
    final photoAttachments = _warehousePhotos.asMap().entries.map((entry) {
      final index = entry.key;
      final photo = entry.value;
      return AttachmentVO(
        type: 1,
        name: 'warehouse_photo_${index + 1}.jpg',
        url: photo.path,
        attachFormat: 1, // Image type
      );
    }).toList();

    final request = DoAcceptSignInVO(
      acceptId: widget.acceptanceId,
      materialList: acceptanceInfo.materialList,
      imageList: photoAttachments,
    );

    context.read<AcceptanceBloc>().add(DoAcceptanceSignIn(request: request));
  }
}
