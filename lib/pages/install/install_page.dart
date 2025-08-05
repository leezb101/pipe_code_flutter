// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
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
import 'package:pipe_code_flutter/widgets/file_upload/file_upload_widget.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';

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
  bool _isSubmitting = false;

  // 为每个上传点创建独立的Cubit
  final Map<int, FileUploadCubit> _materialPhotoCubits = {};
  late final FileUploadCubit _qualityReportCubit;

  // 桩号管理
  final Map<int, String> _materialStakeNumbers = {};
  final Map<int, TextEditingController> _stakeNumberControllers = {};

  @override
  void initState() {
    super.initState();
    _qualityReportCubit = FileUploadCubit();
  }

  @override
  void dispose() {
    // 清理控制器和Cubits
    for (var controller in _stakeNumberControllers.values) {
      controller.dispose();
    }
    for (var cubit in _materialPhotoCubits.values) {
      cubit.close();
    }
    _qualityReportCubit.close();
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
                    materialId: m.baseInfo.materialId,
                    materialName: m.baseInfo.prodNm ?? '未知材料',
                    num: 1,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(List<MaterialInfo> materials) {
    return Column(
      children: materials
          .map(
            (m) => MaterialVO(
              materialId: m.baseInfo.materialId,
              materialName: m.baseInfo.prodNm ?? '未知材料',
              num: 1,
            ),
          )
          .map((material) => _buildMaterialItem(material))
          .toList(),
    );
  }

  Widget _buildMaterialItem(MaterialVO material) {
    final materialId = material.materialId;
    // 为这个物料动态获取或创建一个Cubit
    final photoCubit = _materialPhotoCubits.putIfAbsent(
      materialId,
      () => FileUploadCubit(),
    );

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
            BlocProvider.value(
              value: photoCubit,
              child: BlocBuilder<FileUploadCubit, List<FileUploadState>>(
                builder: (context, states) {
                  return ImageUploadWidget(
                    title: '安装照片',
                    maxImages: 2,
                    requiredPhotoCount: 2,
                    states: states,
                    onAdd: (files) => photoCubit.addFiles(files),
                    onRemove: (uniqueId) => photoCubit.removeFile(uniqueId),
                    onRetry: (uniqueId) => photoCubit.retryUpload(uniqueId),
                  );
                },
              ),
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
                      hintText: '请输入桩号',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _materialStakeNumbers[materialId] = value;
                      });
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

  Widget _buildQualityReportSection() {
    return BlocProvider.value(
      value: _qualityReportCubit,
      child: BlocBuilder<FileUploadCubit, List<FileUploadState>>(
        builder: (context, states) {
          return FileUploadWidget(
            title: '质量验收报告',
            maxFiles: 1,
            states: states,
            onAdd: (files) => _qualityReportCubit.addFiles(files),
            onRemove: (uniqueId) => _qualityReportCubit.removeFile(uniqueId),
            onRetry: (uniqueId) => _qualityReportCubit.retryUpload(uniqueId),
          );
        },
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('继续扫码添加'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () => _navigateToQrScan(context),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, List<MaterialVO> materials) {
    final canSubmit = _canSubmit(materials);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: canSubmit ? Colors.green : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: canSubmit ? () => _submitInstall(context, materials) : null,
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Text(
                '提交',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _navigateToQrScan(BuildContext context) {
    final materialCubit = context.read<MaterialHandleCubit>();
    final config = QrScanConfig(scanType: QrScanType.install, title: '扫码安装');

    context.pushNamed('qr-scan', extra: config).then((result) {
      if (mounted &&
          result != null &&
          result is List<QrScanResult> &&
          result.first.code.isNotEmpty) {
        final qrCode = result.first.code;
        materialCubit.getMaterialInfoFromQr(qrCode);
      }
    });
  }

  bool _canSubmit(List<MaterialVO> materials) {
    if (materials.isEmpty || _isSubmitting) return false;

    // 检查每个材料的照片和桩号
    for (final material in materials) {
      final materialId = material.materialId;
      final photoCubit = _materialPhotoCubits[materialId];
      if (photoCubit == null) return false; // Cubit还未创建

      final photoStates = photoCubit.state;
      final stakeNumber = _materialStakeNumbers[materialId] ?? '';

      if (photoStates.length < 2 || stakeNumber.trim().isEmpty) {
        return false;
      }
      if (photoStates.any((s) => s.status != UploadStatus.success)) {
        return false; // 有照片未上传成功
      }
    }

    // 检查质量验收报告
    final reportStates = _qualityReportCubit.state;
    if (reportStates.isEmpty ||
        reportStates.any((s) => s.status != UploadStatus.success)) {
      return false;
    }

    return true;
  }

  void _submitInstall(BuildContext context, List<MaterialVO> materials) {
    // 增加上传状态检查
    final allPhotoCubits = _materialPhotoCubits.values.toList();
    final allCubits = [...allPhotoCubits, _qualityReportCubit];
    final isUploading = allCubits
        .expand((cubit) => cubit.state)
        .any((s) => s.status == UploadStatus.uploading);

    if (isUploading) {
      context.showInfoToast('文件仍在上传中，请稍候...');
      return;
    }

    if (!_canSubmit(materials)) {
      context.showErrorToast('请确保所有材料都已上传2张照片、填写了桩号，并上传了质量验收报告');
      return;
    }

    setState(() => _isSubmitting = true);

    // 构建包含桩号和照片URL的材料列表
    final List<MaterialVO> updatedMaterials = materials.map((material) {
      final materialId = material.materialId;
      final photoStates = _materialPhotoCubits[materialId]!.state;
      final stakeNumber = _materialStakeNumbers[materialId] ?? '';

      return material.copyWith(
        installPileNo: stakeNumber,
        installImageUrl1: photoStates.isNotEmpty
            ? photoStates[0].uploadResult?.fileUrl
            : null,
        installImageUrl2: photoStates.length > 1
            ? photoStates[1].uploadResult?.fileUrl
            : null,
      );
    }).toList();

    // 获取质量验收报告的URL
    final reportResult = _qualityReportCubit.state.first.uploadResult;

    final request = DoInstallVo(
      materialList: updatedMaterials,
      imageList: const [], // 照片信息已在materialList中
      installQualityUrl: reportResult?.fileUrl,
      signOutId: widget.signOutId != null
          ? int.tryParse(widget.signOutId!)
          : null,
      onlyInstall: widget.signOutId != null,
    );

    context.read<InstallBloc>().add(DoInstall(request: request));
  }
}
