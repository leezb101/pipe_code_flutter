import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_bloc.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_event.dart';
import 'package:pipe_code_flutter/bloc/cut/cut_state.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/repositories/interfaces/cut_repository.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart'
    show QrScanOperation; // only enum
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/widgets/speech_input_widget.dart';

class CutPage extends StatelessWidget {
  const CutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CutBloc(cutRepository: getIt<CutRepository>()),
        ),
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
  final TextEditingController _descriptionController = TextEditingController();
  final Map<int, TextEditingController> _lengthControllers = {};
  final Map<int, FocusNode> _lengthFocusNodes = {};

  // 为每个上传点创建独立的Cubit
  late final FileUploadCubit _originalMaterialPhotoCubit;
  final Map<int, FileUploadCubit> _newMaterialPhotoCubits = {};

  @override
  void initState() {
    super.initState();
    _originalMaterialPhotoCubit = FileUploadCubit();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _originalMaterialPhotoCubit.close();
    for (var controller in _lengthControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _lengthFocusNodes.values) {
      focusNode.dispose();
    }
    for (var cubit in _newMaterialPhotoCubits.values) {
      cubit.close();
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
            _showTipDialog(state.tipMessage as String);
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
              BlocProvider.value(
                value: _originalMaterialPhotoCubit,
                child: BlocConsumer<FileUploadCubit, List<FileUploadState>>(
                  listener: (context, states) {
                    final successState = states.isNotEmpty
                        ? states.firstWhere(
                            (s) => s.status == UploadStatus.success,
                            orElse: () =>
                                FileUploadState(file: File(''), uniqueId: ''),
                          )
                        : null;
                    if (successState != null &&
                        successState.uploadResult != null) {
                      context.read<CutBloc>().add(
                        CutOriginalPhotoUpdated(
                          successState.uploadResult!.filePath,
                        ),
                      );
                    }
                  },
                  builder: (context, states) {
                    return ImageUploadWidget(
                      title: '原耗材照片',
                      watermarkText: '截管前原材',
                      includeTimeWatermark: true,
                      includeLocationWatermark: true,
                      maxImages: 1,
                      states: states,
                      onAdd: (files) =>
                          _originalMaterialPhotoCubit.addFiles(files),
                      onRemove: (uniqueId) =>
                          _originalMaterialPhotoCubit.removeFile(uniqueId),
                      onRetry: (uniqueId) =>
                          _originalMaterialPhotoCubit.retryUpload(uniqueId),
                    );
                  },
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
    // 为新耗材项动态获取或创建Cubit
    final cubit = _newMaterialPhotoCubits.putIfAbsent(
      index,
      () => FileUploadCubit(),
    );

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
              onPressed: () {
                // 删除时也清理对应的Cubit
                _newMaterialPhotoCubits.remove(index)?.close();
                // 预清理对应的长度输入资源，避免在下一次重建前产生泄漏
                _lengthControllers.remove(index)?.dispose();
                _lengthFocusNodes.remove(index)?.dispose();
                context.read<CutBloc>().add(CutNewItemDeleted(index));
              },
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
          focusNode: _lengthFocusNodes[index],
          decoration: const InputDecoration(
            labelText: '管节长 (mm)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
        BlocProvider.value(
          value: cubit,
          child: BlocConsumer<FileUploadCubit, List<FileUploadState>>(
            listener: (context, states) {
              final successState = states.isNotEmpty
                  ? states.firstWhere(
                      (s) => s.status == UploadStatus.success,
                      orElse: () =>
                          FileUploadState(file: File(''), uniqueId: ''),
                    )
                  : null;
              if (successState != null && successState.uploadResult != null) {
                context.read<CutBloc>().add(
                  CutNewItemPhotoUpdated(
                    index: index,
                    photoPath: successState.uploadResult!.filePath,
                  ),
                );
              }
            },
            builder: (context, states) {
              return ImageUploadWidget(
                title: '截管后照片',
                maxImages: 1,
                watermarkText: '截管后新材',
                includeTimeWatermark: true,
                includeLocationWatermark: true,
                states: states,
                onAdd: (files) => cubit.addFiles(files),
                onRemove: (uniqueId) => cubit.removeFile(uniqueId),
                onRetry: (uniqueId) => cubit.retryUpload(uniqueId),
              );
            },
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
        child: TextField(
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
        // child: SpeechInputWidget(
        //   controller: _descriptionController,
        //   decoration: const InputDecoration(
        //     labelText: '业务描述',
        //     hintText: '请输入本次截管业务的描述信息',
        //     border: OutlineInputBorder(),
        //   ),
        //   maxLines: 3,
        //   onChanged: (value) =>
        //       context.read<CutBloc>().add(CutDescriptionUpdated(value)),
        //   onVoiceRecordingPath: (value) {
        //     context.read<CutBloc>().add(CutDescriptionVoiceUpdated([value]));
        //   },
        // ),
      ),
    );
  }

  // Placeholder for action buttons
  Widget _buildActionButtons(BuildContext context, CutState state) {
    return ElevatedButton(
      onPressed: state.status == CutStatus.submitting
          ? null
          : () {
              // 检查所有照片是否上传完毕
              final originalPhotoState = _originalMaterialPhotoCubit.state;
              final allNewPhotosStates = _newMaterialPhotoCubits.values
                  .expand((cubit) => cubit.state)
                  .toList();

              final allStates = [...originalPhotoState, ...allNewPhotosStates];

              final isUploading = allStates.any(
                (s) => s.status == UploadStatus.uploading,
              );
              final hasFailure = allStates.any(
                (s) => s.status == UploadStatus.failure,
              );

              if (isUploading) {
                context.showInfoToast('部分照片仍在上传中，请稍候...');
                return;
              }

              if (hasFailure) {
                context.showErrorToast('有照片上传失败，请重试后再提交。');
                return;
              }

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

  void _scanOriginalMaterial(BuildContext context) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(
      context,
      listen: false,
    );
    final request = QrScanFlowRequest(
      operation: QrScanOperation.initial,
      currentCodes: const [],
      batch: false,
      title: '原耗材扫码',
      context: const {'source': 'cutPage_original'},
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final res = flow.normalize(request, raw);
    if (!mounted) return;
    if (res.addedCodes.isNotEmpty) {
      // 只取第一个（单码模式）
      context.read<MaterialHandleCubit>().getMaterialInfoFromQr(
        res.addedCodes.first,
      );
    }
  }

  void _scanNewMaterials(BuildContext context) async {
    final bloc = context.read<CutBloc>();
    final existingCodes = bloc.state.newCutItems.map((e) => e.qrCode).toList();
    final flow = RepositoryProvider.of<QrScanFlowService>(
      context,
      listen: false,
    );
    final request = QrScanFlowRequest(
      operation: QrScanOperation.append,
      currentCodes: existingCodes,
      batch: true,
      title: '新耗材扫码',
      context: const {'source': 'cutPage_newMaterials'},
      skipValidation: true,
    );
    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final res = flow.normalize(request, raw);
    if (!mounted) return;
    if (res.addedCodes.isNotEmpty) {
      bloc.add(CutNewMaterialsScanned(res.addedCodes));
    } else if (res.duplicates.isNotEmpty) {
      // 提示全部重复被过滤
      context.showInfoToast('重复耗材已过滤');
    }
  }

  Widget _buildInfoDetails(MaterialInfoForBusiness info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            info.normals[0].baseInfo.prodNm ?? '未知材料',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        _buildInfoRow('制造厂家:', info.normals[0].baseInfo.mfgNm ?? 'N/A'),
        _buildInfoRow('产品编号:', info.normals[0].baseInfo.materialCode ?? 'N/A'),
        _buildInfoRow('规格型号:', info.normals[0].baseInfo.spec ?? 'N/A'),
        _buildInfoRow(
          '管节长:',
          '${info.normals.first.extendedFields['len']?.toString() ?? 'N/A'}mm',
        ),
        _buildInfoRow(
          '生产日期:',
          info.normals.first.extendedFields['produceDate']?.toString() ?? 'N/A',
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

  void _updateLengthControllers(List<NewCutMaterialItem> items) {
    final newControllers = <int, TextEditingController>{};
    final newFocusNodes = <int, FocusNode>{};
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final existingController = _lengthControllers[i];
      final existingFocusNode = _lengthFocusNodes[i];
      final focusNode = existingFocusNode ?? FocusNode();
      newFocusNodes[i] = focusNode;
      if (existingController != null) {
        newControllers[i] = existingController;
        // 避免在输入框聚焦时重设文本导致光标跳转
        final desired = _formatLengthText(item.length);
        if (!focusNode.hasFocus && existingController.text != desired) {
          existingController.text = desired;
        }
      } else {
        newControllers[i] = TextEditingController(
          text: _formatLengthText(item.length),
        );
      }
    }
    // Dispose old, unused controllers
    for (var key in _lengthControllers.keys) {
      if (!newControllers.containsKey(key)) {
        _lengthControllers[key]?.dispose();
      }
    }
    // Dispose old, unused focus nodes
    for (var key in _lengthFocusNodes.keys) {
      if (!newFocusNodes.containsKey(key)) {
        _lengthFocusNodes[key]?.dispose();
      }
    }
    _lengthControllers.clear();
    _lengthControllers.addAll(newControllers);
    _lengthFocusNodes
      ..clear()
      ..addAll(newFocusNodes);
  }

  // 仅用于显示：将长度格式化为纯数字字符串（四舍五入到整数毫米）
  String _formatLengthText(double? len) {
    if (len == null || len.isNaN || !len.isFinite) return '';
    return len.toStringAsFixed(0);
  }
}
