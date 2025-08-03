/*
 * @Author: LeeZB
 * @Date: 2025-08-03 
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 17:09:36
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_event.dart';
import 'package:pipe_code_flutter/bloc/inventory/inventory_state.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/widgets/common_state_widgets.dart' as common;

class InventoryDetailPage extends StatefulWidget {
  final int taskId;

  const InventoryDetailPage({super.key, required this.taskId});

  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    context.read<InventoryBloc>().add(InventoryDetailFetched(widget.taskId));
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
      body: BlocBuilder<InventoryBloc, InventoryState>(
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
          _buildMaterialsSection(detail),
          const SizedBox(height: 16),
          if (detail.materialExtras.isNotEmpty) ...[
            _buildSurplusMaterialsSection(detail),
            const SizedBox(height: 16),
          ],
          if (detail.attachmentUrl1 != null || detail.attachmentUrl2 != null)
            _buildPhotosSection(detail),
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
            _buildInfoRow('执行人', detail.executeName ?? '无'),
            _buildInfoRow('物料数量', '${detail.materialNum ?? 0}'),
            _buildInfoRow('实际数量', '${detail.realMaterialNum ?? 0}'),
            _buildInfoRow('状态', _getStatusText(detail.status)),
            if (detail.passFlag != null)
              _buildInfoRow('盘点结果', detail.passFlag! ? '正常' : '异常'),
            if (detail.createdTime != null)
              _buildInfoRow('创建时间', _formatDateTime(detail.createdTime!)),
            if (detail.executeTime != null)
              _buildInfoRow('执行时间', _formatDateTime(detail.executeTime!)),
            if (detail.warehouseName != null)
              _buildInfoRow('仓库', detail.warehouseName!),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(InventoryDetailInfoVO detail) {
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
                  '盘点物料 (${detail.materials.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (detail.materials.isEmpty)
              _buildEmptyMaterialsWidget('暂无盘点物料')
            else
              ...detail.materials.map(
                (material) => _buildMaterialItem(material),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurplusMaterialsSection(InventoryDetailInfoVO detail) {
    if (detail.materialExtras.isEmpty) {
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
                  '盘盈物料 (${detail.materialExtras.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...detail.materialExtras.map(
              (material) => _buildExtraMaterialItem(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(InventoryBindMaterialInfoVO material) {
    // 直接根据 materialRealNum 判断是否已盘点
    final isInventoried = (material.materialRealNum ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInventoried ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isInventoried ? Colors.green[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isInventoried ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2,
              size: 20,
              color: isInventoried ? Colors.green[700] : Colors.grey[700],
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
                Row(
                  children: [
                    Text(
                      '应盘数量: ${material.materialNum}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      ' | 实盘数量: ${material.materialRealNum ?? 0}',
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            (material.materialRealNum ?? 0) ==
                                material.materialNum
                            ? Colors.green[600]
                            : Colors.orange[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (material.inWarehouse != null)
                  Text(
                    material.inWarehouse! ? '在库' : '不在库',
                    style: TextStyle(
                      fontSize: 12,
                      color: material.inWarehouse!
                          ? Colors.blue[600]
                          : Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (isInventoried)
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

  Widget _buildExtraMaterialItem(InventoryBindMaterialInfoVO material) {
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
                  '盘盈数量: ${material.materialNum}',
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

  Widget _buildPhotosSection(InventoryDetailInfoVO detail) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, size: 24, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  '盘点照片',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (detail.attachmentUrl1 != null)
                  Expanded(
                    child: _buildPhotoCard('照片 1', detail.attachmentUrl1!),
                  ),
                if (detail.attachmentUrl1 != null &&
                    detail.attachmentUrl2 != null)
                  const SizedBox(width: 12),
                if (detail.attachmentUrl2 != null)
                  Expanded(
                    child: _buildPhotoCard('照片 2', detail.attachmentUrl2!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String title, String imageUrl) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 32, color: Colors.grey[400]),
                const SizedBox(height: 4),
                Text(
                  '图片加载失败',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
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

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return '待执行';
      case 1:
        return '已执行';
      case 2:
        return '已完成';
      default:
        return '未知状态';
    }
  }
}
