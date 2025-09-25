/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/models/recovery/recovery_scan_data.dart';
import 'package:pipe_code_flutter/models/recovery/step3_result.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

/// Recovery确认弹窗组件
/// 显示Step3提交后的确认信息，等待用户确认是否继续Step4
class RecoveryConfirmationDialog extends StatelessWidget {
  const RecoveryConfirmationDialog({
    super.key,
    required this.step3Result,
    required this.onConfirmed,
    required this.onCancelled,
  });

  /// Step3的结果数据
  final Step3Result step3Result;

  /// 用户确认回调
  final VoidCallback onConfirmed;

  /// 用户取消回调
  final VoidCallback onCancelled;

  @override
  Widget build(BuildContext context) {
    final scanData = step3Result.scanData;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('确认材料信息'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '请确认以下材料信息是否正确：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(context, scanData),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '确认后请扫描QR码完成最终提交',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Logger.info('用户取消确认', tag: 'RecoveryConfirmationDialog');
            Navigator.of(context).pop();
            onCancelled();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onPressed: () {
            Logger.info('用户确认材料信息', tag: 'RecoveryConfirmationDialog');
            Navigator.of(context).pop();
            onConfirmed();
          },
          child: const Text('确认并扫码'),
        ),
      ],
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard(BuildContext context, RecoveryScanData scanData) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('材料编码', scanData.materialCode),
            _buildInfoRow('产品名称', scanData.prodNm ?? '未指定'),
            _buildInfoRow('规格型号', scanData.spec ?? '未指定'),
            _buildInfoRow('材料类型', '类型${scanData.type}'),
            _buildInfoRow('材料分组', '分组${scanData.group}'),
            if (scanData.purNm != null) ...[
              _buildInfoRow('采购方', scanData.purNm!),
            ],
            if (scanData.mfgNm != null) ...[
              _buildInfoRow('制造商', scanData.mfgNm!),
            ],
            _buildInfoRow('产品标准号', scanData.prodStdNo ?? '未指定'),
            _buildInfoRow('标准', scanData.standard ?? '未指定'),
            _buildInfoRow('压力等级', scanData.pressLvl ?? '未指定'),
            if (scanData.weight != null) ...[
              _buildInfoRow('重量', '${scanData.weight}kg'),
            ],
            if (scanData.batchCode != null) ...[
              _buildInfoRow('批次号', scanData.batchCode!),
            ],
            if (scanData.produceDate != null) ...[
              _buildInfoRow('生产日期', scanData.produceDate!),
            ],
            if (scanData.delivery != null) ...[
              const Divider(),
              const Text('发货信息', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDeliveryInfo(scanData.delivery!),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建发货信息
  Widget _buildDeliveryInfo(DeliveryInfo delivery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (delivery.deliveryCode != null)
          _buildInfoRow('发货编码', delivery.deliveryCode!),
        if (delivery.vehicleNo != null)
          _buildInfoRow('车牌号', delivery.vehicleNo!),
        if (delivery.driverName != null)
          _buildInfoRow('司机', delivery.driverName!),
        if (delivery.totalQty != null) _buildInfoRow('总数量', delivery.totalQty!),
        if (delivery.totalWt != null)
          _buildInfoRow('总重量', '${delivery.totalWt}kg'),
        if (delivery.leaveFactoryTime != null)
          _buildInfoRow('出厂时间', delivery.leaveFactoryTime!),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label：',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示Recovery确认弹窗的便捷方法
Future<void> showRecoveryConfirmationDialog({
  required BuildContext context,
  required Step3Result step3Result,
  required VoidCallback onConfirmed,
  required VoidCallback onCancelled,
}) async {
  Logger.info('显示Recovery确认弹窗', tag: 'RecoveryConfirmationDialog');

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // 防止用户点击外部关闭
    builder: (BuildContext context) {
      return RecoveryConfirmationDialog(
        step3Result: step3Result,
        onConfirmed: onConfirmed,
        onCancelled: onCancelled,
      );
    },
  );
}
