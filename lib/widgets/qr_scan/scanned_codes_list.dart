/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:20:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:20:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import '../../models/qr_scan/qr_scan_result.dart';

class ScannedCodesList extends StatelessWidget {
  const ScannedCodesList({
    super.key,
    required this.scannedCodes,
    required this.onRemoveCode,
  });

  final List<QrScanResult> scannedCodes;
  final Function(String) onRemoveCode;

  @override
  Widget build(BuildContext context) {
    if (scannedCodes.isEmpty) {
      return const Center(
        child: Text(
          '暂无扫码记录\n扫描二维码后将显示在这里',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '已扫描的二维码 (${scannedCodes.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: scannedCodes.length,
            itemBuilder: (context, index) {
              final result = scannedCodes[index];
              return _buildCodeItem(context, result, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeItem(BuildContext context, QrScanResult result, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: result.isValid ? Colors.green : Colors.red,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          result.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          _formatDateTime(result.scannedAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(context, result.code),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除二维码 "$code" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRemoveCode(code);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}