/*
 * @Author: LeeZB
 * @Date: 2025-07-16 14:11:07
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-17 09:58:18
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pipe_code_flutter/bloc/spare_qr/spare_qr_event.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';

import '../../bloc/spare_qr/spare_qr_bloc.dart';
import '../../bloc/spare_qr/spare_qr_state.dart';

class SpareQrPage extends StatefulWidget {
  const SpareQrPage({super.key});

  @override
  State<SpareQrPage> createState() => _SpareQrPageState();
}

class _SpareQrPageState extends State<SpareQrPage> {
  late final TextEditingController _numController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _currentFilePath;

  @override
  void initState() {
    super.initState();
    _numController = TextEditingController(text: '20');
  }

  @override
  void dispose() {
    // Cleanup temp file as a safety fallback
    if (_currentFilePath != null) {
      // Note: Can't use context here as widget is being disposed
      // PopScope should handle this, but this is a safety net
      _currentFilePath = null;
    }
    _numController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop && _currentFilePath != null) {
          await _cleanupTempFile();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('备用二维码下载')),
        body: BlocConsumer<SpareQrBloc, SpareQrState>(
          // 使用 listener 来显示 Toast 等一次性提示
          listener: (context, state) {
            if (state is SpareQrFailure) {
              context.showErrorToast('下载失败: ${state.error}');
            } else if (state is SpareQrSuccess) {
              _currentFilePath = state.filePath;
            } else if (state is SpareQrInitial) {
              _currentFilePath = null;
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
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                '备用二维码生成',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '生成指定数量的备用二维码并打包下载',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _numController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: const InputDecoration(
                          labelText: '生成数量',
                          hintText: '请输入数量',
                          helperText: '不超过500个',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入生成数量';
                          }
                          final num = int.tryParse(value);
                          if (num == null) {
                            return '请输入有效的数字';
                          }
                          if (num <= 0) {
                            return '数量必须大于0';
                          }
                          if (num > 500) {
                            return '数量不能超过500';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('打包下载'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() == true) {
                              final num = int.parse(_numController.text);
                              context.read<SpareQrBloc>().add(
                                SpareQrDownloadRequested(num: num),
                              );
                            }
                          },
                        ),
                      ),
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

  Widget _buildProgressIndicator(SpareQrInProgress state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: state.progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(state.progress * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '正在生成备用二维码...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请稍候，文件生成中',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, SpareQrSuccess state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '生成成功！',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '备用二维码已生成完成',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('用其他应用打开'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            final shareResult = await Share.shareXFiles([
                              XFile(state.filePath),
                            ]);
                            if (shareResult.status ==
                                ShareResultStatus.success) {
                              if (context.mounted) {
                                context.showSuccessToast('文件已分享，临时文件已清理');
                                context.read<SpareQrBloc>().add(
                                  SpareQrFileShared(filePath: state.filePath),
                                );
                              }
                            } else if (shareResult.status ==
                                ShareResultStatus.dismissed) {
                              if (context.mounted) {
                                context.showInfoToast('分享已取消，文件保留');
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              context.showErrorToast('分享失败: $e');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('继续生成'),
                      onPressed: () {
                        _showContinueGenerationDialog(context, state.filePath);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cleanupTempFile() async {
    if (_currentFilePath != null && mounted) {
      context.read<SpareQrBloc>().add(
        SpareQrFileShared(filePath: _currentFilePath!),
      );
      _currentFilePath = null;
    }
  }

  void _showContinueGenerationDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('确认继续生成'),
          content: const Text('如果不操作直接继续生成，将废弃之前下载的二维码无法找回，是否确定继续？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<SpareQrBloc>().add(
                  SpareQrResetWithFileCleanup(filePath: filePath),
                );
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
