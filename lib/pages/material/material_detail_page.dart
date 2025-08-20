/*
 * @Author: LeeZB
 * @Date: 2025-07-20 15:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 15:50:23
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/material_field_maps.dart';
import '../../models/material/scan_identification_response.dart';
import '../../utils/toast_utils.dart';
import '../../bloc/material_detail/material_detail_cubit.dart';
import '../../bloc/material_detail/material_detail_state.dart';

class MaterialDetailPage extends StatelessWidget {
  const MaterialDetailPage({super.key, required this.materialCode});

  final String materialCode;

  @override
  Widget build(BuildContext context) {
    return const MaterialDetailView();
  }
}

class MaterialDetailView extends StatelessWidget {
  const MaterialDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialDetailCubit, MaterialDetailState>(
      builder: (context, state) {
        if (state is MaterialDetailLoading) {
          return _buildLoadingState();
        } else if (state is MaterialDetailError) {
          return _buildErrorState(state, context);
        } else if (state is MaterialDetailLoaded) {
          return _buildLoadedState(state, context);
        } else {
          return _buildInitialLoadingState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(title: const Text('材料详情')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildInitialLoadingState() {
    return Scaffold(
      appBar: AppBar(title: const Text('材料详情')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(MaterialDetailError state, BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('材料详情')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // For now, we'll just pop the page since we don't have the materialCode
                // In a real implementation, we'd store the materialCode in the BLoC state
                Navigator.of(context).pop();
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(MaterialDetailLoaded state, BuildContext context) {
    final data = state.materialDetail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('材料详情'),
        actions: [
          IconButton(
            onPressed: () => _copyAllInfo(data, context),
            icon: const Icon(Icons.copy),
            tooltip: '复制全部信息',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context
            .read<MaterialDetailCubit>()
            .refreshMaterialDetail(data.info.baseInfo.materialCode!),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(data, context),
              const SizedBox(height: 16),
              _buildProjectInfo(data, context),
              const SizedBox(height: 16),
              _buildDetailsCard(data, context),
              const SizedBox(height: 16),
              _buildLocationInfo(data, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ScanIdentificationData data, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(data.materialType.name),
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.info.baseInfo.prodNm ?? '未知材料',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.materialType.name} • ${data.materialGroup.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('材料编码', data.materialCode, context),
            if (data.info.baseInfo.spec != null)
              _buildInfoRow('规格', data.info.baseInfo.spec!, context),
            if (data.cut)
              Chip(
                label: const Text('已切割'),
                backgroundColor: Colors.orange.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.orange),
              ),
            if (data.cut) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _viewCuttingRecord(data, context),
                  icon: const Icon(Icons.account_tree),
                  label: const Text('查看截管记录'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(ScanIdentificationData data, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '项目信息',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('项目ID', data.projectId.toString(), context),
            if (data.projectName != null)
              _buildInfoRow('项目名称', data.projectName!, context),
            if (data.projectAddress != null)
              _buildInfoRow('项目地址', data.projectAddress!, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ScanIdentificationData data, BuildContext context) {
    final materialTypeKey = data.materialType.en;
    if (materialTypeKey == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('材料类型英文标识(en)缺失，无法匹配字段'),
        ),
      );
    }

    final fieldMap = materialFieldMaps[materialTypeKey];

    if (fieldMap == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('未找到与“$materialTypeKey”匹配的字段定义'),
        ),
      );
    }

    final allDisplayFields = <(String, String)>[];

    // 基础信息和扩展信息合并处理
    final combinedFields = {
      ...data.info.baseInfo.toJson(),
      ...data.info.extendedFields,
    };

    fieldMap.forEach((key, label) {
      if (combinedFields.containsKey(key)) {
        final value = combinedFields[key];
        if (value != null && value.toString().isNotEmpty) {
          allDisplayFields.add((label, value.toString()));
        }
      }
    });

    if (allDisplayFields.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细信息',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...allDisplayFields.map(
              (field) => _buildInfoRow(field.$1, field.$2, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(ScanIdentificationData data, BuildContext context) {
    if (data.lat == null && data.lng == null && data.img == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '位置信息',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (data.lat != null && data.lng != null) ...[
              _buildInfoRow('纬度', data.lat!.toStringAsFixed(6), context),
              _buildInfoRow('经度', data.lng!.toStringAsFixed(6), context),
            ],
            if (data.img != null) _buildInfoRow('图片', data.img!, context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Increased width for better label display
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(value, context),
              child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String materialType) {
    if (materialType.contains('管')) {
      return Icons.plumbing;
    } else if (materialType.contains('阀')) {
      return Icons.settings;
    } else if (materialType.contains('接头') || materialType.contains('管件')) {
      return Icons.join_inner;
    } else {
      return Icons.category;
    }
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    context.showSuccessToast('已复制到剪贴板');
  }

  void _copyAllInfo(ScanIdentificationData data, BuildContext context) {
    final buffer = StringBuffer();
    final materialTypeKey = data.materialType.en;
    final fieldMap = materialFieldMaps[materialTypeKey];

    buffer.writeln('=== 材料详情: ${data.info.baseInfo.prodNm ?? '未知'} ===');
    buffer.writeln('材料类型: ${data.materialType.name}');
    buffer.writeln('材料分组: ${data.materialGroup.name}');
    buffer.writeln('材料编码: ${data.materialCode}');
    buffer.writeln();

    buffer.writeln('=== 项目信息 ===');
    buffer.writeln('项目ID: ${data.projectId}');
    if (data.projectName != null) buffer.writeln('项目名称: ${data.projectName}');
    if (data.projectAddress != null) {
      buffer.writeln('项目地址: ${data.projectAddress}');
    }
    buffer.writeln();

    if (fieldMap != null) {
      buffer.writeln('=== 详细信息 ===');
      final combinedFields = {
        ...data.info.baseInfo.toJson(),
        ...data.info.extendedFields,
      };

      fieldMap.forEach((key, label) {
        if (combinedFields.containsKey(key)) {
          final value = combinedFields[key];
          if (value != null && value.toString().isNotEmpty) {
            buffer.writeln('$label: ${value.toString()}');
          }
        }
      });
      buffer.writeln();
    }

    if (data.lat != null || data.lng != null) {
      buffer.writeln('=== 位置信息 ===');
      if (data.lat != null) {
        buffer.writeln('纬度: ${data.lat!.toStringAsFixed(6)}');
      }
      if (data.lng != null) {
        buffer.writeln('经度: ${data.lng!.toStringAsFixed(6)}');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    context.showSuccessToast('材料详情已复制到剪贴板');
  }

  void _viewCuttingRecord(ScanIdentificationData data, BuildContext context) {
    context.pushNamed(
      'pipe-cutting-record',
      queryParameters: {'materialId': data.info.baseInfo.materialId.toString()},
      extra: context.read<MaterialDetailCubit>(),
    );
  }
}
