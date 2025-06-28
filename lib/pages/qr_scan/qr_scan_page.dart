/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:25:04
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../bloc/qr_scan/qr_scan_bloc.dart';
import '../../bloc/qr_scan/qr_scan_event.dart';
import '../../bloc/qr_scan/qr_scan_state.dart';
import '../../models/qr_scan/qr_scan_config.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrScanBloc>().add(InitializeScan(widget.config));
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.displayTitle),
        actions: [
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
          } else if (state.status == QrScanStatus.completed) {
            _handleScanCompleted(context, state);
          }
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
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            context.read<QrScanBloc>().add(
                              CodeScanned(barcode.rawValue!),
                            );
                            break;
                          }
                        }
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

  void _handleScanCompleted(BuildContext context, QrScanState state) {
    if (!widget.config.supportsBatch) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && context.mounted) {
          Navigator.of(context).pop(state.scannedCodes);
        }
      });
    } else {
      Navigator.of(context).pop(state.scannedCodes);
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
