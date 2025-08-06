/*
 * @Author: LeeZB
 * @Date: 2025-08-06 15:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-06 15:30:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';

class PipeCuttingRecordPage extends StatelessWidget {
  const PipeCuttingRecordPage({super.key, required this.materialCode});
  
  final String materialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('截管记录'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pending, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '截管记录页面开发中...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text('将显示材料 $materialCode 的树状结构'),
            const SizedBox(height: 16),
            const Text(
              '包含父级、子级、兄弟级关系',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}