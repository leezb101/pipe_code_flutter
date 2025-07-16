/*
 * @Author: LeeZB
 * @Date: 2025-07-16 14:11:07
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 15:14:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_event.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';

import '../../bloc/spare_qr/spare_qr_bloc.dart';
import '../../bloc/spare_qr/spare_qr_state.dart';

class SpareQrPage extends StatelessWidget {
  const SpareQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLoC 文件流下载')),
      body: BlocConsumer<SpareQrBloc, SpareQrState>(
        // 使用 listener 来显示 SnackBar 等一次性提示
        listener: (context, state) {
          if (state is SpareQrFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('下载失败: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        // 使用 builder 来构建 UI
        builder: (context, state) {
          if (state is SpareQrInProgress) {
            return _buildProgressIndicator(state);
          }
          if (state is SpareQrSuccess) {
            return _buildSuccessView(context, state);
          }
          // 初始状态和失败状态都显示下载按钮
          return _buildInitialView(context);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download),
        label: const Text('开始下载 (100MB)'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          // 触发下载事件，我们只需要提供 URL
          // 文件名和保存路径将在 Repository 层自动处理
          context.read<SpareQrBloc>().add(const SpareQrDownloadRequested());
        },
      ),
    );
  }

  Widget _buildProgressIndicator(SpareQrInProgress state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: state.progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                  ),
                  Center(
                    child: Text(
                      '${(state.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('下载中，请稍候...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, SpareQrSuccess state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              '下载成功!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '文件已保存至临时目录',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('打开文件'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // 直接调用 open_file_plus 打开文件
                OpenFile.open(state.filePath);
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // 重置状态，回到初始界面
                context.read<SpareQrBloc>().add(SpareQrReset());
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
