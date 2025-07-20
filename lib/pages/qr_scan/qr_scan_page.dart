/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-20 12:37:41
 * @copyright: Copyright © 2025 高新供水.
 */

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import '../../bloc/qr_scan/qr_scan_bloc.dart';
import '../../bloc/qr_scan/qr_scan_event.dart';
import '../../bloc/qr_scan/qr_scan_state.dart';
import '../../config/app_config.dart';
import '../../models/qr_scan/qr_scan_config.dart';
import '../../services/qr_scan_strategies/qr_scan_strategy.dart';
import '../../widgets/qr_scan/scanned_codes_list.dart';
import '../../utils/toast_utils.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key, required this.config});

  final QrScanConfig config;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  MobileScannerController? _controller;
  bool _hasReturned = false;

  // 防抖相关
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  static const Duration _debounceInterval = Duration(milliseconds: 1000);

  // 批量模式扫码器控制
  bool _isTemporarilyPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrScanBloc>().add(InitializeScan(widget.config));
      // 确保扫码器启动
      _controller?.start();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _controlScanner(QrScanState state) {
    if (_controller == null) {
      print('扫码器控制器为空');
      return;
    }

    print('控制扫码器状态: ${state.status}, 暂停状态: $_isTemporarilyPaused');

    switch (state.status) {
      case QrScanStatus.scanning:
        if (!_isTemporarilyPaused) {
          print('启动扫码器');
          _controller?.start();
        }
        break;
      case QrScanStatus.processing:
      case QrScanStatus.processComplete:
        print('暂停扫码器');
        _controller?.stop();
        break;
      case QrScanStatus.initial:
        print('初始化启动扫码器');
        _controller?.start();
        break;
      case QrScanStatus.error:
      case QrScanStatus.completed:
        // 这些状态不主动控制扫码器
        break;
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture, QrScanState state) {
    print('扫码检测到数据: ${capture.barcodes.length} codes, 当前状态: ${state.status}');

    // 检查是否允许扫码
    if (!_canScanInCurrentState(state)) {
      print('当前状态不允许扫码: ${state.status}');
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final code = barcode.rawValue!;

        // 防抖检查
        if (_isRecentlyScanned(code)) {
          print('防抖：忽略重复扫码 $code');
          return;
        }

        print('处理扫码: $code');

        // 立即停止扫码器，防止重复触发
        _controller?.stop();

        // 震动反馈
        _provideScanFeedback();

        // 更新扫码历史
        _updateScanHistory(code);

        // 发送扫码事件
        context.read<QrScanBloc>().add(CodeScanned(code));

        // 如果是批量模式，安排重启扫码器
        if (widget.config.supportsBatch) {
          _scheduleRestartScanner();
        }

        break;
      }
    }
  }

  bool _canScanInCurrentState(QrScanState state) {
    return state.status == QrScanStatus.scanning ||
        state.status == QrScanStatus.initial ||
        state.status == QrScanStatus.error;
  }

  bool _isRecentlyScanned(String code) {
    final now = DateTime.now();

    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!) < _debounceInterval) {
      return true;
    }

    return false;
  }

  void _updateScanHistory(String code) {
    _lastScannedCode = code;
    _lastScanTime = DateTime.now();
  }

  void _provideScanFeedback() {
    // 震动反馈
    HapticFeedback.mediumImpact();
  }

  void _scheduleRestartScanner() {
    if (!widget.config.supportsBatch) return;

    _isTemporarilyPaused = true;

    // 2.5秒后重新启动扫码器
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_hasReturned) {
        _isTemporarilyPaused = false;
        print('批量模式重新启动扫码器');
        _controller?.start();
      }
    });
  }

  void _simulateScan() {
    // 生成适合当前扫码类型的测试代码
    String testCode;
    // switch (widget.config.scanType.name) {
    //   case 'inbound':
    //     // 入库：生成批次码触发入库确认页面
    //     testCode = 'BATCH_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    //     break;
    //   case 'outbound':
    //     testCode = 'OUT_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    //     break;
    //   case 'transfer':
    //     testCode = 'TRF_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    //     break;
    //   case 'inventory':
    //     testCode = 'INV_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    //     break;
    //   case 'pipeCopy':
    //     testCode = 'PIPE_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    //     break;
    //   case 'returnMaterial':
    //     testCode = 'RET_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    //     break;
    //   default:
    //     testCode = 'TEST_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    // }
    const testCodePool = [
      "ZZWATER:XT03K3312500172041",
      "ZZWATER:729960875670110208",
      "ZZWATER:729960879520481280",
    ];

    testCode = testCodePool[Random().nextInt(testCodePool.length)];

    print('模拟扫码: $testCode');
    context.read<QrScanBloc>().add(CodeScanned(testCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.displayTitle),
        actions: [
          if (AppConfig.isDevelopment)
            BlocBuilder<QrScanBloc, QrScanState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    _simulateScan();
                  },
                  icon: const Icon(Icons.bug_report),
                  tooltip: '模拟扫码',
                );
              },
            ),
          if (widget.config.supportsBatch)
            BlocBuilder<QrScanBloc, QrScanState>(
              builder: (context, state) {
                if (state.scannedCodes.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      context.read<QrScanBloc>().add(const FinishBatchScan());
                    },
                    child: const Text('结束扫码'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
      body: BlocConsumer<QrScanBloc, QrScanState>(
        listener: (context, state) {
          if (state.status == QrScanStatus.error &&
              state.errorMessage != null) {
            context.showErrorToast(state.errorMessage!);
          } else if (state.status == QrScanStatus.processComplete) {
            _handleProcessComplete(context, state);
          }

          // 根据状态控制扫码器
          _controlScanner(state);
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        _onBarcodeDetected(capture, state);
                      },
                    ),
                    _buildScanOverlay(state),
                  ],
                ),
              ),
              if (widget.config.supportsBatch) ...[
                Expanded(
                  flex: 2,
                  child: ScannedCodesList(
                    scannedCodes: state.scannedCodes,
                    onRemoveCode: (code) {
                      context.read<QrScanBloc>().add(RemoveScannedCode(code));
                    },
                  ),
                ),
              ],
              _buildStatusIndicator(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanOverlay(QrScanState state) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: _getBorderColor(state),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  Color _getBorderColor(QrScanState state) {
    switch (state.status) {
      case QrScanStatus.processing:
        return Colors.orange;
      case QrScanStatus.error:
        return Colors.red;
      default:
        return state.isValidCode ? Colors.green : Colors.blue;
    }
  }

  Widget _buildStatusIndicator(QrScanState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: _getStatusColor(state).withValues(alpha: 0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.status == QrScanStatus.processing)
            const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            _getStatusText(state),
            style: TextStyle(
              color: _getStatusColor(state),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.config.supportsBatch && state.scannedCodes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '已扫描: ${state.scannedCodes.length} 个',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(QrScanState state) {
    switch (state.status) {
      case QrScanStatus.scanning:
        return Colors.blue;
      case QrScanStatus.processing:
        return Colors.orange;
      case QrScanStatus.completed:
        return Colors.green;
      case QrScanStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(QrScanState state) {
    switch (state.status) {
      case QrScanStatus.scanning:
        return widget.config.supportsBatch ? '请扫描二维码，支持连续扫码' : '请将二维码放入扫描框内';
      case QrScanStatus.processing:
        return '正在处理...';
      case QrScanStatus.completed:
        return '扫码完成';
      case QrScanStatus.error:
        return state.errorMessage ?? '扫码出错';
      default:
        return '准备扫码';
    }
  }

  void _handleProcessComplete(BuildContext context, QrScanState state) {
    // 防止重复返回
    if (_hasReturned) {
      return;
    }

    print('处理完成，检查导航数据: ${state.processResult?.navigationData?.route}');

    // 检查是否有导航数据需要处理
    if (state.processResult?.navigationData != null) {
      _handleNavigation(context, state.processResult!.navigationData!);
      return;
    }

    // 如果没有导航数据，则返回扫码结果
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && context.mounted && !_hasReturned) {
        _popWithResult(context, state.scannedCodes);
      }
    });
  }

  void _handleNavigation(
    BuildContext context,
    QrScanNavigationData navigationData,
  ) {
    if (_hasReturned) {
      return;
    }

    _hasReturned = true;

    // 使用GoRouter进行导航
    context.push(navigationData.route, extra: navigationData.data);
  }

  void _popWithResult(BuildContext context, List<QrScanResult> result) {
    if (_hasReturned) {
      return;
    }

    _hasReturned = true;

    // 统一使用GoRouter返回
    if (context.canPop()) {
      context.pop(result);
    }
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // Path getLeftTopPath(double s) {
    //   return Path()
    //     ..moveTo(rect.center.dx - s, rect.center.dy - s)
    //     ..lineTo(rect.center.dx - s + borderLength, rect.center.dy - s)
    //     ..moveTo(rect.center.dx - s, rect.center.dy - s)
    //     ..lineTo(rect.center.dx - s, rect.center.dy - s + borderLength);
    // }

    // Path getRightTopPath(double s) {
    //   return Path()
    //     ..moveTo(rect.center.dx + s, rect.center.dy - s)
    //     ..lineTo(rect.center.dx + s - borderLength, rect.center.dy - s)
    //     ..moveTo(rect.center.dx + s, rect.center.dy - s)
    //     ..lineTo(rect.center.dx + s, rect.center.dy - s + borderLength);
    // }

    // Path getLeftBottomPath(double s) {
    //   return Path()
    //     ..moveTo(rect.center.dx - s, rect.center.dy + s)
    //     ..lineTo(rect.center.dx - s + borderLength, rect.center.dy + s)
    //     ..moveTo(rect.center.dx - s, rect.center.dy + s)
    //     ..lineTo(rect.center.dx - s, rect.center.dy + s - borderLength);
    // }

    // Path getRightBottomPath(double s) {
    //   return Path()
    //     ..moveTo(rect.center.dx + s, rect.center.dy + s)
    //     ..lineTo(rect.center.dx + s - borderLength, rect.center.dy + s)
    //     ..moveTo(rect.center.dx + s, rect.center.dy + s)
    //     ..lineTo(rect.center.dx + s, rect.center.dy + s - borderLength);
    // }

    final path = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      );

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // final width = rect.width;
    // final borderWidthSize = width / 2;
    // final height = rect.height;
    // final borderOffset = borderWidth / 2;
    final mWidth = cutOutSize / 2;
    // final mHeight = cutOutSize / 2;

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.clipPath(backgroundPath);
    canvas.drawRect(rect, paint);

    canvas.restore();

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    Path getLeftTopPath(double s) {
      return Path()
        ..moveTo(rect.center.dx - s, rect.center.dy - s + borderRadius)
        ..quadraticBezierTo(
          rect.center.dx - s,
          rect.center.dy - s,
          rect.center.dx - s + borderRadius,
          rect.center.dy - s,
        )
        ..lineTo(rect.center.dx - s + borderLength, rect.center.dy - s)
        ..moveTo(rect.center.dx - s + borderRadius, rect.center.dy - s)
        ..lineTo(rect.center.dx - s, rect.center.dy - s + borderRadius)
        ..lineTo(rect.center.dx - s, rect.center.dy - s + borderLength);
    }

    Path getRightTopPath(double s) {
      return Path()
        ..moveTo(rect.center.dx + s, rect.center.dy - s + borderRadius)
        ..quadraticBezierTo(
          rect.center.dx + s,
          rect.center.dy - s,
          rect.center.dx + s - borderRadius,
          rect.center.dy - s,
        )
        ..lineTo(rect.center.dx + s - borderLength, rect.center.dy - s)
        ..moveTo(rect.center.dx + s - borderRadius, rect.center.dy - s)
        ..lineTo(rect.center.dx + s, rect.center.dy - s + borderRadius)
        ..lineTo(rect.center.dx + s, rect.center.dy - s + borderLength);
    }

    Path getLeftBottomPath(double s) {
      return Path()
        ..moveTo(rect.center.dx - s, rect.center.dy + s - borderRadius)
        ..quadraticBezierTo(
          rect.center.dx - s,
          rect.center.dy + s,
          rect.center.dx - s + borderRadius,
          rect.center.dy + s,
        )
        ..lineTo(rect.center.dx - s + borderLength, rect.center.dy + s)
        ..moveTo(rect.center.dx - s + borderRadius, rect.center.dy + s)
        ..lineTo(rect.center.dx - s, rect.center.dy + s - borderRadius)
        ..lineTo(rect.center.dx - s, rect.center.dy + s - borderLength);
    }

    Path getRightBottomPath(double s) {
      return Path()
        ..moveTo(rect.center.dx + s, rect.center.dy + s - borderRadius)
        ..quadraticBezierTo(
          rect.center.dx + s,
          rect.center.dy + s,
          rect.center.dx + s - borderRadius,
          rect.center.dy + s,
        )
        ..lineTo(rect.center.dx + s - borderLength, rect.center.dy + s)
        ..moveTo(rect.center.dx + s - borderRadius, rect.center.dy + s)
        ..lineTo(rect.center.dx + s, rect.center.dy + s - borderRadius)
        ..lineTo(rect.center.dx + s, rect.center.dy + s - borderLength);
    }

    canvas.drawPath(getLeftTopPath(mWidth), borderPaint);
    canvas.drawPath(getRightTopPath(mWidth), borderPaint);
    canvas.drawPath(getLeftBottomPath(mWidth), borderPaint);
    canvas.drawPath(getRightBottomPath(mWidth), borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
