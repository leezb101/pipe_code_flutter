import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import 'package:pipe_code_flutter/repositories/acceptance_repository.dart';
import 'package:pipe_code_flutter/repositories/material_handle_repository.dart';
import '../../bloc/acceptance/acceptance_bloc.dart';
import '../../bloc/acceptance/acceptance_event.dart';
import '../../bloc/acceptance/acceptance_state.dart';
import '../../bloc/records/records_bloc.dart';
import '../../bloc/records/records_event.dart';
import '../../models/acceptance/acceptance_info_vo.dart';
import '../../models/acceptance/material_vo.dart';
import '../../models/acceptance/attachment_vo.dart';
import '../../models/acceptance/do_accept_sign_in_vo.dart';
import '../../models/common/common_user_vo.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../models/records/record_type.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';

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
    // return MultiBlocProvider(
    //   providers: [
    //     BlocProvider(
    //       create: (context) => AcceptanceBloc(
    //         context.read<AcceptanceRepository>(),
    //         context.read<MaterialHandleRepository>(),
    //       )..add(LoadAcceptanceDetail(acceptanceId: acceptanceId)),
    //     ),
    //     BlocProvider(create: (context) => MaterialHandleCubit()),
    //   ],
    // 新增使用BlocListener监听MaterialHandleCubit的结果，并触发业务bloc事件,
    // child:
    return BlocListener<MaterialHandleCubit, MaterialHandleState>(
      listener: (context, materialHandleState) {
        if (materialHandleState is MaterialHandleScanSuccess) {
          // 扫描成功，物料信息交给AcceptanceBloc进行匹配
          context.read<AcceptanceBloc>().add(
            MatchScannedMaterial(
              scannedMaterial: materialHandleState.materialInfo,
            ),
          );
          // 给出一个即时反馈
          context.showSuccessToast('扫到二维码信息，正在匹配...');
        }
      },
      child: AcceptanceAfterSigninView(acceptanceId: acceptanceId),
    );
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
  final List<XFile> _warehousePhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('验收后入库')),
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
            context.showSuccessToast('验收后入库成功', isGlobal: true);
            context.pop();
            // 触发记录列表刷新
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.todo),
            );
            context.read<RecordsBloc>().add(
              RefreshRecords(recordType: RecordType.accept),
            );
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

  Widget _buildContent(
    BuildContext context,
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    final allMaterials = acceptanceInfo.materialList;
    final allMatched = matchedMaterials.length == allMaterials.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMaterialsList(
            context,
            acceptanceInfo.materialList,
            matchedMaterials,
          ),
          const SizedBox(height: 16),
          _buildScanButton(context),
          const SizedBox(height: 16),
          _buildWarehousePhotos(),
          const SizedBox(height: 16),
          _buildWarehouseInfo(acceptanceInfo),
          const SizedBox(height: 16),
          _buildUserInfo(acceptanceInfo),
          const SizedBox(height: 32),
          _buildActionButtons(context, acceptanceInfo, matchedMaterials),
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
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('返回'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _canSubmit(acceptanceInfo, matchedMaterials)
                ? () => _submitSignin(context, acceptanceInfo, matchedMaterials)
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
    // 导航到扫码逻辑保持不变，但返回结果后处理方式不同
    final config = QrScanConfig(
      scanType: QrScanType.materialInbound,
      title: '扫码入库',
    );

    context.pushNamed('qr-scan', extra: config).then((result) {
      if (result != null &&
          result is List<QrScanResult> &&
          result.first.code.isNotEmpty) {
        final qrCode = result.first.code;
        context.read<MaterialHandleCubit>().getMaterialInfoFromQr(qrCode);
      }
    });
  }

  bool _canSubmit(
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    final allMaterialScanned =
        matchedMaterials.length == acceptanceInfo.materialList.length;
    final hasEnoughPhotos = _warehousePhotos.length >= 2;
    return allMaterialScanned && hasEnoughPhotos && !_isSubmitting;
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

  void _submitSignin(
    BuildContext context,
    AcceptanceInfoVO acceptanceInfo,
    Set<MaterialVO> matchedMaterials,
  ) {
    if (!_canSubmit(acceptanceInfo, matchedMaterials)) return;

    setState(() => _isSubmitting = true);

    final photoAttachments = _warehousePhotos.asMap().entries.map((entry) {
      return AttachmentVO(
        type: 1,
        name: 'warehouse_photo_${entry.key + 1}.jpg',
        url: entry.value.path,
        attachFormat: 1, // Image type
      );
    }).toList();

    final request = DoAcceptSignInVO(
      acceptId: widget.acceptanceId,
      materialList: matchedMaterials.toList(),
      imageList: photoAttachments,
    );

    context.read<AcceptanceBloc>().add(DoAcceptanceSignIn(request: request));
  }
}
