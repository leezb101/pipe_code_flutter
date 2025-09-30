/*
 * @Author: LeeZB
 * @Date: 2025-09-30 17:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-30 17:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

// 这是acceptance页面的集成示例，展示如何完整地集成错误材料展示功能

import 'package:flutter/material.dart';
import '../../widgets/unified/unified_components.dart';
import '../../utils/material_business_helper.dart';
import '../../models/material/material_info_for_business.dart';
import '../../constants/app_theme.dart';

class AcceptancePageWithErrorMaterial extends StatefulWidget {
  final MaterialInfoForBusiness? materials;
  final List<String>? initialCodes;

  const AcceptancePageWithErrorMaterial({
    super.key,
    this.materials,
    this.initialCodes,
  });

  @override
  State<AcceptancePageWithErrorMaterial> createState() =>
      _AcceptancePageWithErrorMaterialState();
}

class _AcceptancePageWithErrorMaterialState
    extends State<AcceptancePageWithErrorMaterial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('验收管理'),
        backgroundColor: AppTheme.acceptanceColor,
      ),
      body: Column(
        children: [
          // 页面头部信息
          _buildHeaderSection(),

          // 材料展示区域
          Expanded(child: _buildMaterialSection()),

          // 底部操作按钮
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final normalCount = MaterialBusinessHelper.getNormalCount(widget.materials);
    final errorCount = MaterialBusinessHelper.getErrorCount(widget.materials);
    final hasErrors = errorCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      color: AppTheme.grey50,
      child: Column(
        children: [
          // 扫码统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                title: '正常材料',
                count: normalCount,
                color: AppTheme.successColor,
                icon: Icons.check_circle,
              ),
              if (hasErrors)
                _buildStatCard(
                  title: '异常材料',
                  count: errorCount,
                  color: AppTheme.errorColor,
                  icon: Icons.error_outline,
                ),
            ],
          ),

          // 提示信息
          if (hasErrors) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      '发现 $errorCount 个异常材料，这些材料不会参与验收提交。',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLarge,
        vertical: AppTheme.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(
            '$count',
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: AppTheme.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildMaterialSection() {
    if (widget.materials == null) {
      return const Center(child: Text('暂无材料数据'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: MaterialBusinessHelper.buildMaterialDisplay(
        materialInfoForBusiness: widget.materials!,
        onMaterialTap: _handleMaterialTap,
        onErrorMaterialTap: _handleErrorMaterialTap,
        businessType: 'acceptance',
        showErrorSection: true,
        materialItemBuilder: _buildCustomMaterialItem,
      ),
    );
  }

  // 自定义材料项构建器，保持与原有页面的一致性
  Widget _buildCustomMaterialItem(dynamic material) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: MaterialListItem(
        onTap: () => _handleMaterialTap(material),
        materialName: material.baseInfo?.prodNm ?? '无',
        primaryText: material.baseInfo?.materialCode ?? '无',
        batchCode: material.baseInfo?.batchCode ?? '无',
        materialId: material.baseInfo?.materialCode ?? '无',
        quantity: 1,
        businessType: 'acceptance',
        icon: Icons.water_drop,
        trailing: _buildMaterialTrailing(material),
      ),
    );
  }

  Widget _buildMaterialTrailing(dynamic material) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showMaterialDetail(material),
          tooltip: '查看详情',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeMaterial(material),
          tooltip: '移除',
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleScanMore,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('继续扫码'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.check),
              label: const Text('提交验收'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.acceptanceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 事件处理方法

  void _handleMaterialTap(dynamic material) {
    _showMaterialDetail(material);
  }

  void _handleErrorMaterialTap(dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: AppTheme.spacingSmall),
            const Text('异常材料详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(
              label: '二维码',
              value: error.qrCode ?? '无',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '厂家编码',
              value: error.code ?? '无',
              icon: Icons.business,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '厂家名称',
              value: error.name ?? '无',
              icon: Icons.factory,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '错误信息',
              value: error.msg ?? '无',
              icon: Icons.error_outline,
              valueStyle: AppTheme.bodyMedium.copyWith(
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleReportError(error);
            },
            child: const Text('报告问题'),
          ),
        ],
      ),
    );
  }

  void _showMaterialDetail(dynamic material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('材料详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow(label: '材料名称', value: material.baseInfo?.prodNm ?? '无'),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(
              label: '材料编码',
              value: material.baseInfo?.materialCode ?? '无',
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(label: '批次码', value: material.baseInfo?.batchCode ?? '无'),
            const SizedBox(height: AppTheme.spacingSmall),
            InfoRow(label: '规格', value: material.baseInfo?.spec ?? '无'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _removeMaterial(dynamic material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认移除'),
        content: const Text('确定要移除这个材料吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 实际的移除逻辑
              // context.read<AcceptanceBloc>().add(RemoveMaterial(material));
            },
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  void _handleScanMore() {
    // 继续扫码的逻辑
    Navigator.of(context).pushNamed('/scan');
  }

  Future<void> _handleSubmit() async {
    // 使用MaterialBusinessHelper进行提交前检查
    final shouldProceed = await MaterialBusinessHelper.checkBeforeSubmit(
      context,
      materialInfoForBusiness: widget.materials,
      title: '验收提交确认',
      businessType: 'acceptance',
    );

    if (shouldProceed) {
      _performSubmit();
    }
  }

  void _performSubmit() {
    // 执行实际的验收提交
    final normalMaterials = MaterialBusinessHelper.getNormals(widget.materials);

    if (normalMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有可提交的材料'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    // 调用bloc进行提交
    // context.read<AcceptanceBloc>().add(
    //   SubmitAcceptance(materials: normalMaterials),
    // );

    // 显示提交成功信息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已提交 ${normalMaterials.length} 个材料进行验收'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _handleReportError(dynamic error) {
    // 报告错误材料问题的逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('问题报告已提交'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
