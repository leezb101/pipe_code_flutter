import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pipe_code_flutter/widgets/unified/unified_ui.dart';

/// 用于测试调拨详情页的简单测试页
class DispatchDetailTestPage extends StatelessWidget {
  const DispatchDetailTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('调拨详情页测试', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.getBusinessColor('dispatch'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppTheme.grey50,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UnifiedCard(
              title: '测试功能',
              icon: Icons.science,
              businessType: 'dispatch',
              child: Column(
                children: [
                  Text(
                    '点击按钮测试调拨详情页',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.spacingLarge),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(
                        'dispatch-detail',
                        queryParameters: {'id': '1'},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getBusinessColor('dispatch'),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: Text('查看调拨详情 (ID: 1)'),
                  ),
                  SizedBox(height: AppTheme.spacingMedium),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(
                        'dispatch-detail',
                        queryParameters: {'id': '2'},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getBusinessColor('dispatch'),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: Text('查看调拨详情 (ID: 2)'),
                  ),
                  SizedBox(height: AppTheme.spacingMedium),
                  OutlinedButton(
                    onPressed: () {
                      context.goNamed(
                        'dispatch-confirmation',
                        queryParameters: {'id': '1'},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppTheme.spacingMedium,
                      ),
                      side: BorderSide(
                        color: AppTheme.getBusinessColor('dispatch'),
                      ),
                      foregroundColor: AppTheme.getBusinessColor('dispatch'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: Text('对比: 调拨确认页 (ID: 1)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
