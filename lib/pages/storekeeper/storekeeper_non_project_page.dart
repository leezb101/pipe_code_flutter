/*
 * @Author: LeeZB
 * @Date: 2025-08-23 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 15:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/bloc/storekeeper_non_project/storekeeper_non_project_bloc.dart';
import 'package:pipe_code_flutter/bloc/storekeeper_non_project/storekeeper_non_project_event.dart';
import 'package:pipe_code_flutter/bloc/storekeeper_non_project/storekeeper_non_project_state.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_cubit.dart';
import 'package:pipe_code_flutter/cubits/file_upload/file_upload_state.dart';
import 'package:pipe_code_flutter/services/qr_scan_flow/qr_scan_flow_service.dart';
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';

class StorekeeperNonProjectPage extends StatefulWidget {
  const StorekeeperNonProjectPage({super.key});

  @override
  State<StorekeeperNonProjectPage> createState() =>
      _StorekeeperNonProjectPageState();
}

class _StorekeeperNonProjectPageState extends State<StorekeeperNonProjectPage> {
  // 静态常量 BoxShadow，避免重复创建
  static const BoxShadow _pageBoxShadow = BoxShadow(
    color: Color(0x1A000000), // 0.1 opacity black
    blurRadius: 8,
    offset: Offset(0, -2),
  );

  // 文件上传组件
  late final FileUploadCubit _imageUploadCubit;

  // 表单控制器
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageUploadCubit = FileUploadCubit();

    // 初始加载仓库列表
    context.read<StorekeeperNonProjectBloc>().add(LoadWarehouses());
  }

  @override
  void dispose() {
    _imageUploadCubit.close();
    _descriptionController.dispose();
    super.dispose();
  }

  // 提交入库方法
  void _submitEntry() {
    final uploadStates = _imageUploadCubit.state;
    final isUploading = uploadStates.any(
      (s) => s.status == UploadStatus.uploading,
    );
    if (isUploading) {
      ToastUtils.showInfo(context, '照片仍在上传中，请稍候...');
      return;
    }

    final hasFailures = uploadStates.any(
      (s) => s.status == UploadStatus.failure,
    );
    if (hasFailures) {
      ToastUtils.showError(context, '有图片上传失败，请重试或删除。');
      return;
    }

    final photoUrls = uploadStates
        .where(
          (s) => s.status == UploadStatus.success && s.uploadResult != null,
        )
        .map((state) => state.uploadResult!.filePath)
        .toList();

    // 更新bloc中的照片列表
    // TODO: 实现bloc中的UpdatePhotos事件以保存照片URL到状态中
    // context.read<StorekeeperNonProjectBloc>().add(UpdatePhotos(photoUrls));

    // 准备提交时检查照片
    if (photoUrls.isNotEmpty) {
      // 有照片已上传，将在提交时一并处理
    }

    // 触发提交 - 携带照片URL信息
    context.read<StorekeeperNonProjectBloc>().add(SubmitEntry());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StorekeeperNonProjectBloc, StorekeeperNonProjectState>(
      listener: (context, state) {
        // 处理一次性错误消息
        if (state.errorMessage?.isNotEmpty == true) {
          ToastUtils.showError(context, state.errorMessage!);
          // 清除错误消息
          context.read<StorekeeperNonProjectBloc>().add(ClearErrorMessage());
        }

        // 处理成功提交
        if (state.status == StorekeeperNonProjectStatus.submitSuccess) {
          ToastUtils.showSuccess(context, '非项目入库提交成功！');
          context.pop(); // 返回上一页
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context),
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildWarehouseSection(state),
                      const SizedBox(height: 16),
                      _buildMaterialsSection(state),
                      const SizedBox(height: 16),
                      _buildImageUploadSection(),
                      const SizedBox(height: 16),
                      _buildDescriptionSection(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(state),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        '非项目入库',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildWarehouseSection(StorekeeperNonProjectState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warehouse, size: 24, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  '选择仓库',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.status == StorekeeperNonProjectStatus.loadingWarehouses)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.warehouses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '暂无可用仓库',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              DropdownButtonFormField<int>(
                value: state.selectedWarehouse?.id,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '请选择仓库',
                ),
                items: state.warehouses.map((warehouse) {
                  return DropdownMenuItem<int>(
                    value: warehouse.id,
                    child: Text(warehouse.name ?? '未命名仓库'),
                  );
                }).toList(),
                onChanged: (warehouseId) {
                  if (warehouseId != null) {
                    final warehouse = state.warehouses.firstWhere(
                      (w) => w.id == warehouseId,
                    );
                    context.read<StorekeeperNonProjectBloc>().add(
                      SelectWarehouse(warehouse),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(StorekeeperNonProjectState state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, size: 24, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '物料清单',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${state.materials.length} 项',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.materials.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '请扫码添加物料',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ...state.materials.map(_buildMaterialItem),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _scanMaterials(QrScanOperation.append),
                          icon: const Icon(Icons.add),
                          label: const Text('继续扫码'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _scanMaterials(QrScanOperation.remove),
                          icon: const Icon(Icons.remove),
                          label: const Text('扫码剔除'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (state.materials.isEmpty)
              const SizedBox(height: 16)
            else
              const SizedBox.shrink(),
            if (state.materials.isEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _scanMaterials(QrScanOperation.initial),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('开始扫码'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(MaterialInfo material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  material.baseInfo.prodNm ?? '未知物料',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  material.baseInfo.materialCode ?? '',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (material.baseInfo.spec?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              '规格: ${material.baseInfo.spec}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          if (material.baseInfo.weight?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              '重量: ${material.baseInfo.weight}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_camera, size: 24, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  '上传图片',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 使用ImageUploadWidget替代简化版本
            BlocBuilder<FileUploadCubit, List<FileUploadState>>(
              bloc: _imageUploadCubit,
              builder: (context, states) {
                return ImageUploadWidget(
                  title: '照片',
                  maxImages: 6,
                  states: states,
                  watermarkText: '非项目入库',
                  includeTimeWatermark: true,
                  includeLocationWatermark: true,
                  onAdd: (files) {
                    _imageUploadCubit.addFiles(files);
                  },
                  onRemove: (uniqueId) {
                    _imageUploadCubit.removeFile(uniqueId);
                  },
                  onRetry: (uniqueId) {
                    _imageUploadCubit.retryUpload(uniqueId);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, size: 24, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  '备注描述',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请输入入库备注（可选）',
              ),
              onChanged: (value) {
                context.read<StorekeeperNonProjectBloc>().add(
                  UpdateDescription(value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(StorekeeperNonProjectState state) {
    final canSubmit =
        state.selectedWarehouse != null &&
        state.materials.isNotEmpty &&
        state.status != StorekeeperNonProjectStatus.submitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [_pageBoxShadow],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    state.status == StorekeeperNonProjectStatus.submitting
                    ? null
                    : () {
                        context.read<StorekeeperNonProjectBloc>().add(
                          ResetState(),
                        );
                      },
                child: const Text('重置'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed:
                    canSubmit &&
                        state.status != StorekeeperNonProjectStatus.submitting
                    ? _submitEntry
                    : null,
                child: state.status == StorekeeperNonProjectStatus.submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('提交入库'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 扫码方法 - 使用QrScanFlowService
  Future<void> _scanMaterials(QrScanOperation operation) async {
    final flow = RepositoryProvider.of<QrScanFlowService>(context);
    final currentState = context.read<StorekeeperNonProjectBloc>().state;
    final currentCodes = currentState.materials
        .map((material) => material.baseInfo.materialCode ?? '')
        .where((code) => code.isNotEmpty)
        .toList();

    final request = QrScanFlowRequest(
      operation: operation,
      currentCodes: currentCodes,
      batch: true,
      context: {
        'source': 'storekeeperNonProjectPage',
        'entry': 'embedded',
        'operation': operation.name,
      },
    );

    final config = flow.buildConfig(request);
    final raw = await context.pushNamed<List<dynamic>>(
      'qr-scan',
      extra: config,
    );
    final result = flow.normalize(request, raw);

    if (!mounted) return;

    if (operation == QrScanOperation.append && result.addedCodes.isNotEmpty) {
      context.read<StorekeeperNonProjectBloc>().add(
        ProcessScannedCodes(codes: result.addedCodes, operation: operation),
      );
    } else if (operation == QrScanOperation.remove &&
        result.removedCodes.isNotEmpty) {
      context.read<StorekeeperNonProjectBloc>().add(
        ProcessScannedCodes(codes: result.removedCodes, operation: operation),
      );
    } else if (operation == QrScanOperation.initial &&
        result.addedCodes.isNotEmpty) {
      context.read<StorekeeperNonProjectBloc>().add(
        ProcessScannedCodes(codes: result.addedCodes, operation: operation),
      );
    }
  }
}
