/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:25:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:25:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/qr_scan/qr_scan_bloc.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../models/qr_scan/qr_scan_type.dart';
import '../../pages/qr_scan/qr_scan_page.dart';
import '../../services/qr_scan_service.dart';
import '../../config/service_locator.dart';
import '../../utils/toast_utils.dart';
import '../toast_demo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('智慧水务'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '扫码功能',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ToastDemoPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications, size: 16),
                  label: const Text('Toast 演示'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildScanOption(
                    context,
                    title: '单个验收',
                    subtitle: '一次扫一个码',
                    icon: Icons.qr_code_scanner,
                    color: Colors.green,
                    config: const QrScanConfig(
                      scanType: QrScanType.acceptance,
                      acceptanceType: AcceptanceType.single,
                    ),
                  ),
                  _buildScanOption(
                    context,
                    title: '批量验收',
                    subtitle: '支持连续扫码',
                    icon: Icons.qr_code_2,
                    color: Colors.orange,
                    config: const QrScanConfig(
                      scanType: QrScanType.acceptance,
                      acceptanceType: AcceptanceType.batch,
                    ),
                  ),
                  _buildScanOption(
                    context,
                    title: '核销',
                    subtitle: '设备核销处理',
                    icon: Icons.verified,
                    color: Colors.blue,
                    config: const QrScanConfig(
                      scanType: QrScanType.verification,
                    ),
                  ),
                  _buildScanOption(
                    context,
                    title: '巡检',
                    subtitle: '设备巡检查询',
                    icon: Icons.search,
                    color: Colors.purple,
                    config: const QrScanConfig(
                      scanType: QrScanType.inspection,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required QrScanConfig config,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToScan(context, config),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScan(BuildContext context, QrScanConfig config) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => QrScanBloc(
            qrScanService: getIt<QrScanService>(),
          ),
          child: QrScanPage(config: config),
        ),
      ),
    ).then((result) {
      if (result != null && context.mounted) {
        _showScanResult(context, result, config);
      }
    });
  }

  void _showScanResult(BuildContext context, dynamic result, QrScanConfig config) {
    String message;
    if (result is List) {
      message = '${config.displayTitle}: 成功处理 ${result.length} 个二维码';
    } else {
      message = '${config.displayTitle}: 扫码完成';
    }

    context.showSuccessToast(message);
  }
}