/*
 * @Author: LeeZB
 * @Date: 2025-08-03 
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 18:35:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_event.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_state.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_cubit.dart';
import 'package:pipe_code_flutter/bloc/material_handle/material_handle_state.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;
import 'package:pipe_code_flutter/widgets/file_upload/image_upload_widget.dart';

class InventoryPage extends StatefulWidget {
  final int taskId;

  const InventoryPage({super.key, required this.taskId});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<File> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    context.read<InventoryBloc>().add(InventoryDetailFetched(widget.taskId));
  }

  Future<void> _startQrScan() async {
    final config = QrScanConfig(
      scanType: QrScanType.inventory,
      scanMode: QrScanMode.batch,
      title: '盘点扫码',
    );

    try {
      final result = await context.push('/qr-scan', extra: config);
      if (result != null && result is List<QrScanResult>) {
        // 获取扫码的二维码列表
        final qrCodes = result.map((r) => r.code).toList();

        // 使用MaterialHandleCubit查询物料信息
        await context.read<MaterialHandleCubit>().getMaterialInfoFromQrList(
              qrCodes,
            );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('扫码失败: $e');
      }
    }
  }

  Future<void> _submitInventory() async {
    final state = context.read<InventoryBloc>().state;

    if (state.inventoryDetail == null) {
      context.showErrorToast('请先加载任务详情');
      return;
    }

    if (_photos.length < 2) {
      context.showErrorToast('请上传两张盘点照片');
      return;
    }

    context.read<InventoryBloc>().add(
          InventoryPhotosUpdated(photo1: _photos[0], photo2: _photos[1]),
        );

    context.read<InventoryBloc>().add(InventorySubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('盘点详情'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MaterialHandleCubit, MaterialHandleState>(
            listener: (context, state) {
              if (state is MaterialHandleScanSuccess) {
                // 扫码查询成功后，触发比对逻辑
                context.read<InventoryBloc>().add(
                  InventoryMaterialsCompared(state.materialInfo.normals),
                );
                context.showSuccessToast(
                  '扫码成功，已识别 ${state.materialInfo.normals.length} 个物料',
                );
              } else if (state is MaterialHandleScanFailure) {
                context.showErrorToast('扫码查询失败: ${state.error}');
              }
            },
          ),
          BlocListener<InventoryBloc, InventoryState>(
            listener: (context, state) {
              if (state.submissionStatus == SubmissionStatus.success) {
                context.showSuccessToast('盘点提交成功');
                // 返回到列表页面，此时列表已经通过Bloc自动刷新了
                context.pop(true);
              } else if (state.submissionStatus == SubmissionStatus.failure) {
                context.showErrorToast(
                  '盘点提交失败: ${state.errorMessage ?? '未知错误'}',
                );
              }
            },
          ),
        ],
        child: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            switch (state.detailStatus) {
              case DataStatus.initial:
              case DataStatus.loading:
                return const common.LoadingWidget(message: '正在加载详情...');
              case DataStatus.failure:
                return common.ErrorWidget(
                  message: state.errorMessage ?? '加载失败',
                  onRetry: _loadDetail,
                );
              case DataStatus.success:
                if (state.inventoryDetail == null) {
                  return const common.ErrorWidget(message: '数据为空');
                }
                return _buildContent(state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(InventoryState state) {
    final detail = state.inventoryDetail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskInfoCard(detail),
          const SizedBox(height: 16),
          _buildMaterialsSection(detail, state),
          const SizedBox(height: 16),
          _buildSurplusMaterialsSection(state),
          const SizedBox(height: 16),
          _buildScanButton(state),
          const SizedBox(height: 16),
          ImageUploadWidget(
            title: '盘点照片',
            maxImages: 2,
            requiredPhotoCount: 2,
            onImagesChanged: (images) {
              setState(() {
                _photos = images;
              });
              if (images.length == 2) {
                context.read<InventoryBloc>().add(
                      InventoryPhotosUpdated(
                        photo1: images[0],
                        photo2: images[1],
                      ),
                    );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSubmitButton(state),
        ],
      ),
    );
  }

  Widget _buildTaskInfoCard(InventoryDetailInfoVO detail) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, size: 24, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  '任务信息',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('任务名称', detail.name ?? '无'),
            _buildInfoRow('负责人', detail.bindUserName ?? '无'),
            _buildInfoRow('物料数量', '${detail.materialNum ?? 0}'),
            if (detail.createdTime != null)
              _buildInfoRow('创建时间', _formatDateTime(detail.createdTime!)),
            if (detail.warehouseName != null)
              _buildInfoRow('仓库', detail.warehouseName!),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(
    InventoryDetailInfoVO detail,
    InventoryState state,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, size: 24, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  '待盘点物料 (${detail.materials.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (detail.materials.isEmpty)
              _buildEmptyMaterialsWidget('暂无待盘点物料')
            else
              ...detail.materials.map(
                (material) => _buildMaterialItem(
                  material,
                  isMatched: state.matchedMaterialIds.contains(
                    material.materialId,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurplusMaterialsSection(InventoryState state) {
    if (state.surplusMaterials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle, size: 24, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  '盘盈物料 (${state.surplusMaterials.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...state.surplusMaterials.map(
              (material) => _buildSurplusMaterialItem(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(
    InventoryBindMaterialInfoVO material, {
    bool isMatched = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMatched ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMatched ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMatched ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2,
              size: 20,
              color: isMatched ? Colors.green[700] : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.materialName ?? '无名称',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (material.materialCode != null)
                  Text(
                    '编号: ${material.materialCode}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                Text(
                  '数量: ${material.materialNum}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isMatched)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildSurplusMaterialItem(MaterialInfo material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add_circle, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.baseInfo.prodNm ?? '无名称',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (material.baseInfo.materialCode != null)
                  Text(
                    '编号: ${material.baseInfo.materialCode}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                if (material.baseInfo.spec != null)
                  Text(
                    '规格: ${material.baseInfo.spec}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '盘盈',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMaterialsWidget(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(InventoryState state) {
    final isScanning = state.comparisonStatus == DataStatus.loading;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isScanning ? null : _startQrScan,
        icon: isScanning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.qr_code_scanner),
        label: Text(isScanning ? '正在处理扫码结果...' : '扫码盘点'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(InventoryState state) {
    final isSubmitting = state.submissionStatus == SubmissionStatus.loading;
    final canSubmit = state.inventoryDetail != null && _photos.length >= 2;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (canSubmit && !isSubmitting) ? _submitInventory : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('提交中...'),
                ],
              )
            : const Text('提交盘点'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
