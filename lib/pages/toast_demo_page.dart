/*
 * @Author: LeeZB
 * @Date: 2025-06-28 15:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 15:45:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import '../utils/toast_utils.dart';

class ToastDemoPage extends StatelessWidget {
  const ToastDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast 演示'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFE6F3FF),
              Color(0xFFDCEEFF),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新的 iOS 风格提示',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () {
                context.showSuccessToast('操作成功完成！这是一个成功提示的示例');
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('显示成功提示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                context.showErrorToast('发生了错误！请检查您的网络连接并重试');
              },
              icon: const Icon(Icons.error, color: Colors.white),
              label: const Text('显示错误提示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                context.showWarningToast('请注意！此操作可能会影响您的数据');
              },
              icon: const Icon(Icons.warning, color: Colors.white),
              label: const Text('显示警告提示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                context.showInfoToast('这是一条信息提示，用于向用户传达重要信息');
              },
              icon: const Icon(Icons.info, color: Colors.white),
              label: const Text('显示信息提示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ToastUtils.showMessages(context, [
                        '第一条消息（立即显示）',
                        '第二条消息（错开位置）',
                        '第三条消息（同时出现）',
                      ]);
                    },
                    icon: const Icon(Icons.layers, size: 16),
                    label: const Text('批量显示'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ToastUtils.showMessagesSequentially(context, [
                        '消息1（顺序显示）',
                        '消息2（延迟出现）',
                        '消息3（依次播放）',
                      ]);
                    },
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('顺序显示'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // 快速连续点击测试
                      context.showInfoToast('消息 1');
                      context.showWarningToast('消息 2');
                      context.showSuccessToast('消息 3');
                      context.showErrorToast('消息 4');
                    },
                    icon: const Icon(Icons.speed, size: 16),
                    label: const Text('快速测试'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ToastUtils.dismissAll();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('清除所有'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            const Card(
              color: Color(0xFFF5F5F5),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          '特点',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• iOS 风格设计，符合原生体验'),
                    Text('• 位于屏幕中上部，视觉焦点更好'),
                    Text('• 增强毛玻璃效果，现代化视觉'),
                    Text('• 支持震动反馈，交互更自然'),
                    Text('• 自动动画和定时消失'),
                    Text('• 支持多个 Toast 同时显示'),
                    Text('• 批量显示和顺序显示两种模式'),
                    Text('• 最多同时显示 3 个，自动管理'),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}