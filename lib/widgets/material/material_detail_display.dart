/*
 * @Author: LeeZB
 * @Date: 2025-09-25
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-25
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_bloc.dart';
import 'package:pipe_code_flutter/bloc/auth/auth_state.dart';
import 'package:pipe_code_flutter/constants/material_field_maps.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';

/// 通用材料详情展示组件
/// 用于在弹窗或其他容器中展示材料的详细信息
/// 支持简化模式，不包括切割、截管记录、生命周期等特殊功能
class MaterialDetailDisplay extends StatelessWidget {
  const MaterialDetailDisplay({
    super.key,
    required this.material,
    this.materialType,
    this.materialGroup,
    this.projectName,
    this.projectAddress,
    this.showProjectInfo = true,
    this.showCopyAction = true,
    this.isCompact = false,
  });

  /// 材料信息
  final MaterialInfo material;

  /// 材料类型（如果有的话，用于获取字段映射）
  final MaterialTypeInfo? materialType;

  /// 材料分组（如果有的话）
  final MaterialGroupInfo? materialGroup;

  /// 项目名称
  final String? projectName;

  /// 项目地址
  final String? projectAddress;

  /// 是否显示项目信息
  final bool showProjectInfo;

  /// 是否显示复制操作
  final bool showCopyAction;

  /// 是否使用紧凑模式（减少间距和字体大小）
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummarySection(context),
          if (showProjectInfo &&
              (projectName != null || projectAddress != null)) ...[
            SizedBox(height: isCompact ? 12 : 16),
            _buildProjectSection(context),
          ],
          SizedBox(height: isCompact ? 12 : 16),
          _buildDetailsSection(context),
        ],
      ),
    );
  }

  /// 构建材料概要信息部分
  Widget _buildSummarySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTypeIcon(),
                size: isCompact ? 24 : 32,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.baseInfo.prodNm ?? '未知材料',
                      style: isCompact
                          ? Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                          : Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                    if (!isCompact) const SizedBox(height: 4),
                    if (materialType != null || materialGroup != null)
                      Text(
                        '${materialType?.name ?? ''} ${materialGroup != null ? '• ${materialGroup!.name}' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (showCopyAction)
                IconButton(
                  onPressed: () => _copyAllInfo(context),
                  icon: const Icon(Icons.copy),
                  tooltip: '复制材料信息',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 12),
          _buildInfoRow('材料编码', material.baseInfo.materialCode ?? '无', context),
          if (material.baseInfo.spec != null)
            _buildInfoRow('规格', material.baseInfo.spec!, context),
          if (material.baseInfo.mfgNm != null)
            _buildInfoRow('生产厂家', material.baseInfo.mfgNm!, context),
          if (material.baseInfo.prodStdNo != null)
            _buildInfoRow('标准号', material.baseInfo.prodStdNo!, context),
        ],
      ),
    );
  }

  /// 构建项目信息部分
  Widget _buildProjectSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '项目信息',
            style: isCompact
                ? Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
          SizedBox(height: isCompact ? 8 : 12),
          if (projectName != null) _buildInfoRow('项目名称', projectName!, context),
          if (projectAddress != null)
            _buildInfoRow('项目地址', projectAddress!, context),
        ],
      ),
    );
  }

  /// 构建详细信息部分
  Widget _buildDetailsSection(BuildContext context) {
    final materialTypeKey = materialType?.en;
    final fieldMap = materialFieldMaps[materialTypeKey];

    final allDisplayFields = <Widget>[];

    // 合并基础信息和扩展信息
    final combinedFields = {
      ...material.baseInfo.toJson(),
      ...material.extendedFields,
    };

    // 定义需要过滤掉的字段（不属于材料本身的字段）
    final excludedFields = {
      'otherMaterialByDelivery',
      'delivery',
      'warrantyUrl',
      'currentWarrantyUrl',
      'certificateUrl',
      'currentCertificateUrl',
      'materialId', // ID字段不需要显示
      'materialCode', // 已在概要信息中显示
      'prodNm', // 已在概要信息中显示
      'spec', // 已在概要信息中显示
      'mfgNm', // 已在概要信息中显示
      'prodStdNo', // 已在概要信息中显示
      'intCorrProtAppPerfInsp',
    };

    // 如果有字段映射，优先使用映射显示字段
    if (fieldMap != null) {
      fieldMap.forEach((key, label) {
        if (!excludedFields.contains(key) && combinedFields.containsKey(key)) {
          final value = combinedFields[key];
          if (value != null &&
              value.toString().isNotEmpty &&
              value.toString() != '0') {
            allDisplayFields.add(
              _buildInfoRow(label, value.toString(), context),
            );
          }
        }
      });
    }

    // 处理文件字段（currentWarrantyUrl和currentCertificateUrl）
    final currentWarrantyUrl = combinedFields['currentWarrantyUrl']?.toString();
    if (currentWarrantyUrl != null && currentWarrantyUrl.isNotEmpty) {
      allDisplayFields.add(
        _buildFileInfoRow('质保书', currentWarrantyUrl, context),
      );
    }

    final currentCertificateUrl = combinedFields['currentCertificateUrl']
        ?.toString();
    if (currentCertificateUrl != null && currentCertificateUrl.isNotEmpty) {
      allDisplayFields.add(
        _buildFileInfoRow('合格证', currentCertificateUrl, context),
      );
    }

    // 如果没有字段映射，显示其他有意义的字段
    if (fieldMap == null) {
      combinedFields.forEach((key, value) {
        if (!excludedFields.contains(key) &&
            value != null &&
            value.toString().isNotEmpty &&
            value.toString() != '0') {
          // 尝试从基础字段映射中获取中文标签
          String label = _getFieldLabel(key);
          allDisplayFields.add(_buildInfoRow(label, value.toString(), context));
        }
      });
    }

    if (allDisplayFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '详细信息',
            style: isCompact
                ? Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
                : Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
          ),
          SizedBox(height: isCompact ? 8 : 12),
          ...allDisplayFields,
        ],
      ),
    );
  }

  /// 获取字段的中文标签
  String _getFieldLabel(String fieldKey) {
    // 从基础字段映射中查找
    const baseFieldLabels = {
      'deliveryNumber': '发货单号',
      'batchCode': '批次号',
      'purNm': '采购方名称',
      'pressLvl': '压力等级',
      'weight': '重量',
      'produceDate': '生产日期',
      'mfgCode': '制造商编码',
      'standard': '产品标准号',
      'deliveryCode': '归属运单号',
      'transCardNo': '运单号',
      'matGradeParam': '材质（牌号）参数',
      'posDev': '正偏差',
      'len': '长度(mm)',
      'industryArea': '承口铸字',
      'graphSpherRate': '石墨球化率',
      'pipeGskMatBrand': '配套胶圈材质/品牌',
      'extCorrProtType': '外防腐类型',
      'extCorrProtStd': '外防腐标准',
      'extCorrProtThk': '外防腐厚度',
      'intCorrProtType': '内防腐类型',
      'intCorrProtStd': '内防腐标准',
      'intCorrProtThk': '内防腐厚度',
      'chemCompInsp': '化学成分检验',
      'mechPerfInsp': '力学性能检验',
      'nonDsInsp': '无损检验',
      'galvCoatWtThk': '镀锌层重量或厚度',
      'hydroTest': '静水压试验',
      'tempCorrosionResParam': '耐温与耐腐蚀参数',
      'coatingProcess': '涂覆工艺',
    };

    return baseFieldLabels[fieldKey] ?? fieldKey;
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 2 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isCompact ? 80 : 100,
            child: Text(
              label,
              style:
                  (isCompact
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium)
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(value, context),
              child: Text(
                value,
                style: isCompact
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文件信息行
  Widget _buildFileInfoRow(
    String label,
    String documentUrl,
    BuildContext context,
  ) {
    // 从URL中提取文件名
    String getFileNameFromUrl(String url) {
      try {
        final urlWithoutQuery = url.split('?').first;
        final fileName = urlWithoutQuery.split('/').last;
        return fileName.isNotEmpty ? fileName : '查看文件';
      } catch (e) {
        return '查看文件';
      }
    }

    final displayName = getFileNameFromUrl(documentUrl);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 2 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isCompact ? 80 : 100,
            child: Text(
              label,
              style:
                  (isCompact
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium)
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                // 添加认证token
                final authState = context.read<AuthBloc>().state;
                String finalUrl = documentUrl;
                if (authState is AuthLoginSuccess) {
                  final token = authState.wxLoginVO.tk;
                  if (finalUrl.contains('?')) {
                    finalUrl = '$finalUrl&auth_toke=$token';
                  } else {
                    finalUrl = '$finalUrl?auth_toke=$token';
                  }
                }
                context.push('/pdf-preview', extra: finalUrl);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: isCompact ? 16 : 18,
                      color: Colors.blue[600],
                    ),
                    SizedBox(width: isCompact ? 6 : 8),
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: isCompact ? 12 : 14,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: isCompact ? 14 : 16,
                      color: Colors.blue[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取材料类型图标
  IconData _getTypeIcon() {
    final typeName = materialType?.name ?? material.baseInfo.prodNm ?? '';
    if (typeName.contains('管')) {
      return Icons.plumbing;
    } else if (typeName.contains('阀')) {
      return Icons.settings;
    } else if (typeName.contains('接头') || typeName.contains('管件')) {
      return Icons.join_inner;
    } else {
      return Icons.category;
    }
  }

  /// 复制到剪贴板
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    context.showSuccessToast('已复制到剪贴板');
  }

  /// 复制所有信息
  void _copyAllInfo(BuildContext context) {
    final buffer = StringBuffer();

    buffer.writeln('=== 材料详情: ${material.baseInfo.prodNm ?? '未知'} ===');
    if (materialType != null) {
      buffer.writeln('材料类型: ${materialType!.name}');
    }
    if (materialGroup != null) {
      buffer.writeln('材料分组: ${materialGroup!.name}');
    }
    buffer.writeln('材料编码: ${material.baseInfo.materialCode ?? '无'}');
    buffer.writeln();

    if (showProjectInfo && (projectName != null || projectAddress != null)) {
      buffer.writeln('=== 项目信息 ===');
      if (projectName != null) buffer.writeln('项目名称: $projectName');
      if (projectAddress != null) buffer.writeln('项目地址: $projectAddress');
      buffer.writeln();
    }

    buffer.writeln('=== 基础信息 ===');
    final baseInfo = material.baseInfo;
    if (baseInfo.spec != null) buffer.writeln('规格: ${baseInfo.spec}');
    if (baseInfo.mfgNm != null) buffer.writeln('生产厂家: ${baseInfo.mfgNm}');
    if (baseInfo.prodStdNo != null)
      buffer.writeln('标准号: ${baseInfo.prodStdNo}');
    if (baseInfo.deliveryNumber != null)
      buffer.writeln('发货单号: ${baseInfo.deliveryNumber}');
    if (baseInfo.batchCode != null)
      buffer.writeln('批次号: ${baseInfo.batchCode}');
    if (baseInfo.purNm != null) buffer.writeln('采购方名称: ${baseInfo.purNm}');
    if (baseInfo.pressLvl != null) buffer.writeln('压力等级: ${baseInfo.pressLvl}');
    if (baseInfo.weight != null) buffer.writeln('重量: ${baseInfo.weight}');

    if (material.extendedFields.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('=== 扩展信息 ===');
      material.extendedFields.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buffer.writeln('$key: ${value.toString()}');
        }
      });
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    context.showSuccessToast('材料详情已复制到剪贴板');
  }
}

/// 材料类型信息（简化版，用于显示）
class MaterialTypeInfo {
  const MaterialTypeInfo({required this.name, this.en});

  final String name;
  final String? en;
}

/// 材料分组信息（简化版，用于显示）
class MaterialGroupInfo {
  const MaterialGroupInfo({required this.name});

  final String name;
}
