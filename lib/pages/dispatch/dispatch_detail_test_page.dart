import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 用于测试调拨详情页的简单测试页
class DispatchDetailTestPage extends StatelessWidget {
  const DispatchDetailTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('调拨详情页测试')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '点击按钮测试调拨详情页',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 使用测试ID跳转到调拨详情页
                context.goNamed(
                  'dispatch-detail',
                  queryParameters: {'id': '1'},
                );
              },
              child: const Text('查看调拨详情 (ID: 1)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  'dispatch-detail',
                  queryParameters: {'id': '2'},
                );
              },
              child: const Text('查看调拨详情 (ID: 2)'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.goNamed(
                  'dispatch-confirmation',
                  queryParameters: {'id': '1'},
                );
              },
              child: const Text('对比: 调拨确认页 (ID: 1)'),
            ),
          ],
        ),
      ),
    );
  }
}
