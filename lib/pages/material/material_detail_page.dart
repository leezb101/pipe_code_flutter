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
import '../../models/material/scan_identification_response.dart';
import '../../models/material/material_info_base.dart';
import '../../utils/toast_utils.dart';
import '../../bloc/material_detail/material_detail_cubit.dart';
import '../../bloc/material_detail/material_detail_state.dart';

class MaterialDetailPage extends StatelessWidget {
  const MaterialDetailPage({super.key, required this.materialCode});

  final String materialCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MaterialDetailCubit()..loadMaterialDetail(materialCode),
      child: const MaterialDetailView(),
    );
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
              _buildBasicInfo(data.info.baseInfo, context),
              const SizedBox(height: 16),
              if (data.info.extendedFields.isNotEmpty) ...[
                _buildExtendedInfo(data.info.extendedFields, context),
                const SizedBox(height: 16),
              ],
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
                backgroundColor: Colors.orange.withValues(alpha: 0.2),
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

  Widget _buildBasicInfo(MaterialInfoBase baseInfo, BuildContext context) {
    final basicFields = [
      ('材料编码', baseInfo.materialCode),
      ('发货单号', baseInfo.deliveryNumber),
      ('批次号', baseInfo.batchCode),
      ('制造商', baseInfo.mfgNm),
      ('采购方', baseInfo.purNm),
      ('产品标准号', baseInfo.prodStdNo),
      ('产品名称', baseInfo.prodNm),
      ('规格', baseInfo.spec),
      ('压力等级', baseInfo.pressLvl),
      ('重量', baseInfo.weight),
    ];

    final nonEmptyFields = basicFields
        .where((field) => field.$2 != null && field.$2!.isNotEmpty)
        .toList();

    if (nonEmptyFields.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基础信息',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...nonEmptyFields.map(
              (field) => _buildInfoRow(field.$1, field.$2!, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtendedInfo(
    Map<String, dynamic> extendedFields,
    BuildContext context,
  ) {
    final nonEmptyFields = extendedFields.entries
        .where(
          (entry) => entry.value != null && entry.value.toString().isNotEmpty,
        )
        .toList();

    if (nonEmptyFields.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '技术参数',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...nonEmptyFields.map(
              (entry) => _buildInfoRow(
                _formatFieldName(entry.key),
                entry.value.toString(),
                context,
              ),
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
            width: 100,
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

  String _formatFieldName(String fieldName) {
    // 简单的字段名格式化
    final fieldMap = {
      'matGradeParam': '材料牌号参数',
      'posDev': '正偏差',
      'len': '长度',
      'graphSpherRate': '球化率',
      'pipeGskMatBrand': '管道垫片材料品牌',
      'extCorrProtType': '外防腐类型',
      'extCorrProtStd': '外防腐标准',
      'extCorrProtThk': '外防腐厚度',
      'extCorrProtAppPerfInsp': '外防腐外观性能检验',
      'intCorrProtType': '内防腐类型',
      'intCorrProtStd': '内防腐标准',
      'intCorrProtThk': '内防腐厚度',
      'intCorrProtAppPerfInsp': '内防腐外观性能检验',
      'chemCompInsp': '化学成分检验',
      'mechPerfInsp': '机械性能检验',
      'nonDsInsp': '无损检测',
      'steelGrade': '钢材牌号',
      'weldingType': '焊接类型',
      'coatingType': '涂层类型',
      'coatingThickness': '涂层厚度',
      'hydroTestPressure': '水压试验压力',
      'testDuration': '试验持续时间',
      'certificateNo': '证书编号',
      'valveType': '阀门类型',
      'operationType': '操作类型',
      'sealMaterial': '密封材料',
      'bodyMaterial': '阀体材料',
      'connectionType': '连接类型',
      'operatingTemp': '工作温度',
      'testPressure': '试验压力',
      'workingPressure': '工作压力',
      'remark': '备注',
    };

    return fieldMap[fieldName] ?? fieldName;
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    context.showSuccessToast('已复制到剪贴板');
  }

  void _copyAllInfo(ScanIdentificationData data, BuildContext context) {
    final buffer = StringBuffer();

    // 基本信息
    buffer.writeln('=== 材料详情 ===');
    buffer.writeln('产品名称: ${data.info.baseInfo.prodNm ?? '未知'}');
    buffer.writeln('材料类型: ${data.materialType.name}');
    buffer.writeln('材料分组: ${data.materialGroup.name}');
    buffer.writeln('材料编码: ${data.materialCode}');
    buffer.writeln();

    // 项目信息
    buffer.writeln('=== 项目信息 ===');
    buffer.writeln('项目ID: ${data.projectId}');
    if (data.projectName != null) buffer.writeln('项目名称: ${data.projectName}');
    if (data.projectAddress != null) {
      buffer.writeln('项目地址: ${data.projectAddress}');
    }
    buffer.writeln();

    // 基础信息
    final baseInfo = data.info.baseInfo;
    if (baseInfo.materialCode != null ||
        baseInfo.deliveryNumber != null ||
        baseInfo.batchCode != null ||
        baseInfo.mfgNm != null ||
        baseInfo.purNm != null) {
      buffer.writeln('=== 基础信息 ===');
      if (baseInfo.materialCode != null) {
        buffer.writeln('材料编码: ${baseInfo.materialCode}');
      }
      if (baseInfo.deliveryNumber != null) {
        buffer.writeln('发货单号: ${baseInfo.deliveryNumber}');
      }
      if (baseInfo.batchCode != null) {
        buffer.writeln('批次号: ${baseInfo.batchCode}');
      }
      if (baseInfo.mfgNm != null) buffer.writeln('制造商: ${baseInfo.mfgNm}');
      if (baseInfo.purNm != null) buffer.writeln('采购方: ${baseInfo.purNm}');
      if (baseInfo.prodStdNo != null) {
        buffer.writeln('产品标准号: ${baseInfo.prodStdNo}');
      }
      if (baseInfo.spec != null) buffer.writeln('规格: ${baseInfo.spec}');
      if (baseInfo.pressLvl != null) {
        buffer.writeln('压力等级: ${baseInfo.pressLvl}');
      }
      if (baseInfo.weight != null) buffer.writeln('重量: ${baseInfo.weight}');
      buffer.writeln();
    }

    // 技术参数
    if (data.info.extendedFields.isNotEmpty) {
      buffer.writeln('=== 技术参数 ===');
      data.info.extendedFields.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buffer.writeln('${_formatFieldName(key)}: $value');
        }
      });
      buffer.writeln();
    }

    // 位置信息
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
      queryParameters: {'materialCode': data.materialCode},
    );
  }
}
