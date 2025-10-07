// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import '../../bloc/install/install_bloc.dart';
import '../../bloc/install/install_event.dart';
import '../../bloc/install/install_state.dart';
import '../../models/install/do_install_vo.dart';
import '../../models/acceptance/material_vo.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../widgets/common_state_widgets.dart' as common;
import '../../utils/toast_utils.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';
import 'package:pipe_code_flutter/widgets/file_upload/file_upload_widget.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';

class InstallPage extends StatelessWidget {
  final String? signOutId;

  const InstallPage({super.key, this.signOutId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstallBloc>(
      create: (context) => InstallBloc(installRepository: getIt()),
      child: _InstallPageView(signOutId: signOutId),
    );
  }
}

class _InstallPageView extends StatelessWidget {
  final String? signOutId;

  const _InstallPageView({required this.signOutId});

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
  bool _canSubmitNow = false; // reactive flag for submit button

  // 为每个上传点创建独立的Cubit
  final Map<int, FileUploadCubit> _materialPhotoCubits = {};
  late final FileUploadCubit _qualityReportCubit;

  // 订阅管理
  final Map<int, StreamSubscription<List<FileUploadState>>> _materialPhotoSubs =
      {};
  StreamSubscription<List<FileUploadState>>? _qualityReportSub;

  // 桩号管理
  final Map<int, String> _materialStakeNumbers = {};
  final Map<int, TextEditingController> _stakeNumberControllers = {};

  @override
  void initState() {
    super.initState();
    _qualityReportCubit = FileUploadCubit();
    // 监听质量报告上传状态变化，实时刷新提交可用性
    _qualityReportSub = _qualityReportCubit.stream.listen(
      (_) => _recomputeCanSubmit(),
    );
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
    // 取消订阅
    for (var sub in _materialPhotoSubs.values) {
      sub.cancel();
    }
    _qualityReportSub?.cancel();
    _qualityReportCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一管一码'),
        backgroundColor: AppTheme.getBusinessColor('install'),
        foregroundColor: Colors.white,
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       // TODO: 导航到安装记录页面
        //     },
        //     child: const Text('安装记录', style: TextStyle(color: Colors.white)),
        //   ),
        // ],
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
            // 确保物料列表变化后，提交按钮能及时刷新
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _recomputeCanSubmit(),
            );
            return _buildContent(context, state);
          }
          if (state is InstallLoading) {
            return const common.LoadingWidget(message: "加载中...");
          }
          if (state is InstallFailure) {
            return common.ErrorWidget(
              message: state.error,
              onRetry: () {
                // 重置提交中标志，并恢复到提交前的界面态
                if (_isSubmitting) {
                  setState(() => _isSubmitting = false);
                }
                context.read<InstallBloc>().add(const RestorePreviousReady());
              },
            );
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
          const SizedBox(height: 16),
          _buildScanButton(context, scannedMaterials),
          // const SizedBox(height: 16),
          // _buildQualityReportSection(),
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
    final photoCubit = _getOrCreatePhotoCubit(materialId);

    // 确保控制器存在
    if (!_stakeNumberControllers.containsKey(materialId)) {
      _stakeNumberControllers[materialId] = TextEditingController();
    }

    return UnifiedCard(
      businessType: 'install',
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 材料信息
          MaterialListItem(
            materialName: material.materialName,
            primaryText: material.materialCode ?? '无',
            batchCode: material.batchCode ?? '无',
            quantity: material.num,
            status: material.status,
            statusName: material.statusName,
            businessType: 'install',
            icon: Icons.build,
            showQuantityBadge: true,
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
                  watermarkText: '安装',
                  includeTimeWatermark: true,
                  includeLocationWatermark: true,
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
          InfoRow(
            label: '桩号',
            value: _materialStakeNumbers[materialId] ?? '请输入桩号',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _stakeNumberControllers[materialId],
            decoration: const InputDecoration(
              hintText: '请输入桩号',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (value) {
              _materialStakeNumbers[materialId] = value;
              _recomputeCanSubmit();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQualityReportSection() {
    return UnifiedCard(
      title: '质量验收报告',
      icon: Icons.description,
      businessType: 'install',
      child: BlocProvider.value(
        value: _qualityReportCubit,
        child: BlocBuilder<FileUploadCubit, List<FileUploadState>>(
          builder: (context, states) {
            return FileUploadWidget(
              title: '',
              maxFiles: 1,
              states: states,
              onAdd: (files) => _qualityReportCubit.addFiles(files),
              onRemove: (uniqueId) => _qualityReportCubit.removeFile(uniqueId),
              onRetry: (uniqueId) => _qualityReportCubit.retryUpload(uniqueId),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScanButton(
    BuildContext context,
    List<MaterialInfo> scannedMaterials,
  ) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(scannedMaterials.isEmpty ? '开始扫码添加' : '继续扫码添加'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppTheme.getBusinessColor('install'),
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
    // 使用响应式标志控制按钮，同时考虑正在提交的态
    final canSubmit = _canSubmitNow && !_isSubmitting;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: canSubmit
              ? AppTheme.getBusinessColor('install')
              : Colors.grey,
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
    final config = QrScanConfig(title: '扫码安装');

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

  // 仅基于业务条件判断（不考虑_isSubmitting），供响应式计算与提交前校验复用
  bool _meetsSubmitRequirements(List<MaterialVO> materials) {
    if (materials.isEmpty) return false;

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
    // final reportStates = _qualityReportCubit.state;
    // if (reportStates.isEmpty ||
    //     reportStates.any((s) => s.status != UploadStatus.success)) {
    //   return false;
    // }

    return true;
  }

  // 重新计算是否可提交，并在变更时刷新UI
  void _recomputeCanSubmit() {
    // 从当前Bloc状态获取最新的物料列表
    final state = context.read<InstallBloc>().state;
    List<MaterialVO> materials = [];
    if (state is InstallReady) {
      final scannedMaterials = state.materialInfos?.normals ?? [];
      materials = scannedMaterials
          .map(
            (m) => MaterialVO(
              materialId: m.baseInfo.materialId,
              materialName: m.baseInfo.prodNm ?? '未知材料',
              num: 1,
            ),
          )
          .toList();
    }
    final next = _meetsSubmitRequirements(materials);
    if (next != _canSubmitNow) {
      setState(() {
        _canSubmitNow = next;
      });
    }
  }

  // 获取或创建照片上传Cubit，并绑定订阅
  FileUploadCubit _getOrCreatePhotoCubit(int materialId) {
    final existing = _materialPhotoCubits[materialId];
    if (existing != null) {
      // 确保有订阅
      _materialPhotoSubs[materialId] ??= existing.stream.listen(
        (_) => _recomputeCanSubmit(),
      );
      return existing;
    }
    final cubit = FileUploadCubit();
    _materialPhotoCubits[materialId] = cubit;
    _materialPhotoSubs[materialId]?.cancel();
    _materialPhotoSubs[materialId] = cubit.stream.listen(
      (_) => _recomputeCanSubmit(),
    );
    return cubit;
  }

  void _submitInstall(BuildContext context, List<MaterialVO> materials) {
    // 增加上传状态检查
    final allPhotoCubits = _materialPhotoCubits.values.toList();
    // final allCubits = [...allPhotoCubits, _qualityReportCubit];
    final allCubits = [...allPhotoCubits];
    final isUploading = allCubits
        .expand((cubit) => cubit.state)
        .any((s) => s.status == UploadStatus.uploading);

    if (isUploading) {
      context.showInfoToast('文件仍在上传中，请稍候...');
      return;
    }

    if (!_meetsSubmitRequirements(materials)) {
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
            ? photoStates[0].uploadResult?.filePath
            : null,
        installImageUrl2: photoStates.length > 1
            ? photoStates[1].uploadResult?.filePath
            : null,
      );
    }).toList();

    // 获取质量验收报告的URL
    // final reportResult = _qualityReportCubit.state.first.uploadResult;

    final request = DoInstallVo(
      materialList: updatedMaterials,
      imageList: const [], // 照片信息已在materialList中
      // installQualityUrl: reportResult?.filePath,
      signOutId: widget.signOutId != null
          ? int.tryParse(widget.signOutId!)
          : null,
      onlyInstall: widget.signOutId != null,
    );

    context.read<InstallBloc>().add(DoInstall(request: request));
  }
}
