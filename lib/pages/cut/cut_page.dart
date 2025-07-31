import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_bloc.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_event.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_state.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class CutPage extends StatelessWidget {
  const CutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CutBloc()),
        // MaterialHandleCubit is used for QR scan results
        BlocProvider(create: (context) => MaterialHandleCubit()),
      ],
      child: BlocListener<MaterialHandleCubit, MaterialHandleState>(
        listener: (context, materialState) {
          if (materialState is MaterialHandleScanSuccess) {
            // When original material is scanned, pass it to the CutBloc
            context.read<CutBloc>().add(
              CutOriginalMaterialScanned(materialState.materialInfo),
            );
            context.showSuccessToast('原耗材信息获取成功');
          } else if (materialState is MaterialHandleScanFailure) {
            context.showErrorToast(materialState.error);
          }
        },
        child: const CutView(),
      ),
    );
  }
}

class CutView extends StatefulWidget {
  const CutView({super.key});

  @override
  State<CutView> createState() => _CutViewState();
}

class _CutViewState extends State<CutView> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  // A map to hold controllers for each new item's length
  final Map<int, TextEditingController> _lengthControllers = {};

  @override
  void dispose() {
    _descriptionController.dispose();
    for (var controller in _lengthControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一管一码-截管'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<CutBloc, CutState>(
        listenWhen: (previous, current) {
          return current.status == CutStatus.failure ||
              current.status == CutStatus.success ||
              current.status == CutStatus.tip;
        },
        listener: (context, state) {
          if (state.status == CutStatus.success) {
            context.showSuccessToast('截管成功', isGlobal: true);
            context.pop();
          } else if (state.status == CutStatus.failure &&
              state.errorMessage != null) {
            context.showErrorToast(state.errorMessage!);
          } else if (state.status == CutStatus.tip &&
              state.tipMessage != null) {
            _showTipDialog(state.tipMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == CutStatus.submitting) {
            return const common.LoadingWidget(message: '正在提交...');
          }
          // The main UI is built here
          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, CutState state) {
    // Update text controllers based on state
    _updateLengthControllers(state.newCutItems);
    if (_descriptionController.text != (state.cutDescription ?? '')) {
      _descriptionController.text = state.cutDescription ?? '';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section for original material
          _buildOriginalMaterialSection(context, state),
          const SizedBox(height: 16),

          // Section for new materials, only visible after original is scanned
          if (state.originalMaterialInfo != null) ...[
            _buildNewMaterialSection(context, state),
            const SizedBox(height: 16),
            _buildDescriptionCard(context),
            const SizedBox(height: 32),
            _buildActionButtons(context, state),
          ],
        ],
      ),
    );
  }

  // Placeholder for Tip Dialog
  void _showTipDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Placeholder for Original Material Section
  Widget _buildOriginalMaterialSection(BuildContext context, CutState state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => _scanOriginalMaterial(context),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('原耗材扫码'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            if (state.originalMaterialInfo != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              _buildInfoDetails(state.originalMaterialInfo!),
              const SizedBox(height: 16),
              _buildPhotoPicker(
                context: context,
                title: '原耗材照片',
                photoPath: state.originalMaterialPhotoPath,
                onTakePhoto: () => _takePhoto(
                  context,
                  (path) => context.read<CutBloc>().add(
                    CutOriginalPhotoUpdated(path),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Placeholder for New Material Section
  Widget _buildNewMaterialSection(BuildContext context, CutState state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _scanNewMaterials(context),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('新耗材扫码'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            if (state.newCutItems.isNotEmpty) const Divider(),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.newCutItems.length,
              itemBuilder: (context, index) {
                final item = state.newCutItems[index];
                return _buildNewItemCard(context, item, index);
              },
              separatorBuilder: (context, index) => const Divider(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for a single new item card
  Widget _buildNewItemCard(
    BuildContext context,
    NewCutMaterialItem item,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.materialName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () =>
                  context.read<CutBloc>().add(CutNewItemDeleted(index)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '二维码: ${item.qrCode}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _lengthControllers[index],
          decoration: const InputDecoration(
            labelText: '管节长 (m)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            final length = double.tryParse(value);
            if (length != null) {
              context.read<CutBloc>().add(
                CutNewItemLengthUpdated(index: index, length: length),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _buildPhotoPicker(
          context: context,
          title: '截管后照片',
          photoPath: item.photoPath,
          onTakePhoto: () => _takePhoto(
            context,
            (path) => context.read<CutBloc>().add(
              CutNewItemPhotoUpdated(index: index, photoPath: path),
            ),
          ),
        ),
      ],
    );
  }

  // Placeholder for description card
  Widget _buildDescriptionCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '业务描述',
            hintText: '请输入本次截管业务的描述信息',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) =>
              context.read<CutBloc>().add(CutDescriptionUpdated(value)),
        ),
      ),
    );
  }

  // Placeholder for action buttons
  Widget _buildActionButtons(BuildContext context, CutState state) {
    return ElevatedButton(
      onPressed: state.status == CutStatus.submitting
          ? null
          : () {
              context.read<CutBloc>().add(CutSubmitted());
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: const Text('提交'),
    );
  }

  // --- Helper Methods ---

  void _scanOriginalMaterial(BuildContext context) {
    final config = QrScanConfig(
      scanType: QrScanType.pipeCopy,
      title: '原耗材扫码',
      scanMode: QrScanMode.single,
    );
    // We now await the result from the scan page.
    context.pushNamed('qr-scan', extra: config).then((result) {
      // The result comes from QrScanPage popping with the scanned codes.
      if (result != null && result is List<QrScanResult> && result.isNotEmpty) {
        final qrCode = result.first.code;
        // With the raw QR code, we now ask the MaterialHandleCubit to fetch the data.
        // The BlocListener<MaterialHandleCubit> will then handle the success/failure state.
        context.read<MaterialHandleCubit>().getMaterialInfoFromQr(qrCode);
      }
    });
  }

  void _scanNewMaterials(BuildContext context) {
    final config = QrScanConfig(
      scanType: QrScanType.raw, // No specific business logic, just get strings
      title: '新耗材扫码',
      scanMode: QrScanMode.batch,
    );
    context.pushNamed('qr-scan', extra: config).then((result) {
      if (result != null && result is List<QrScanResult> && result.isNotEmpty) {
        final qrCodes = result.map((r) => r.code).toList();
        context.read<CutBloc>().add(CutNewMaterialsScanned(qrCodes));
      }
    });
  }

  Widget _buildInfoDetails(MaterialInfoForBusiness info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            info.normals[0].prodNm ?? '未知材料',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        _buildInfoRow('制造厂家:', info.normals[0].mfgNm ?? 'N/A'),
        _buildInfoRow('产品编号:', info.normals[0].materialCode ?? 'N/A'),
        _buildInfoRow('规格型号:', info.normals[0].spec ?? 'N/A'),
        _buildInfoRow(
          '管节长:',
          '${(info.normals[0] as MaterialInfo).extendedFields['len'] ?? 'N/A'}',
        ),
        _buildInfoRow(
          '生产日期:',
          (info.normals[0] as MaterialInfo).extendedFields['produceDate'] ??
              'N/A',
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker({
    required BuildContext context,
    required String title,
    required String? photoPath,
    required VoidCallback onTakePhoto,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (photoPath != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Image.file(
              File(photoPath),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        OutlinedButton.icon(
          onPressed: onTakePhoto,
          icon: const Icon(Icons.camera_alt),
          label: Text(photoPath == null ? '拍照上传' : '重新拍照'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
          ),
        ),
      ],
    );
  }

  Future<void> _takePhoto(
    BuildContext context,
    Function(String) onPhotoTaken,
  ) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (photo != null) {
        onPhotoTaken(photo.path);
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorToast('拍照失败: $e');
      }
    }
  }

  void _updateLengthControllers(List<NewCutMaterialItem> items) {
    final newControllers = <int, TextEditingController>{};
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final existingController = _lengthControllers[i];
      if (existingController != null) {
        newControllers[i] = existingController;
        if (existingController.text != (item.length?.toString() ?? '')) {
          existingController.text = item.length?.toString() ?? '';
        }
      } else {
        newControllers[i] = TextEditingController(
          text: item.length?.toString() ?? '',
        );
      }
    }
    // Dispose old, unused controllers
    for (var key in _lengthControllers.keys) {
      if (!newControllers.containsKey(key)) {
        _lengthControllers[key]?.dispose();
      }
    }
    _lengthControllers.clear();
    _lengthControllers.addAll(newControllers);
  }
}
