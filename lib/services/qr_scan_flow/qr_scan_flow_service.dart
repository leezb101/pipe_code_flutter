import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_result.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';

/// 封装页面调用扫码的“初次/追加/移除”标准流程
/// 最终目标：业务页面只需构造 QrScanFlowRequest，得到标准化的 QrScanFlowResult
class QrScanFlowService {
  const QrScanFlowService();

  /// 构造运行时需要的 config（供外层导航使用）
  QrScanConfig buildConfig(QrScanFlowRequest request) => QrScanConfig(
    scanType: request.scanType,
    scanMode: request.batch ? QrScanMode.batch : QrScanMode.single,
    title: request.title,
    existingCodesToExclude: request.operation == QrScanOperation.append
        ? request.currentCodes
        : null,
    context: request.context,
    operation: request.operation,
  );

  /// 将导航（/qr-scan）返回的 raw list 归一化
  QrScanFlowResult normalize(QrScanFlowRequest request, List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return QrScanFlowResult.empty(request.operation);
    }
    final qrResults = raw.whereType<QrScanResult>().toList();
    final codes = qrResults.map((e) => e.code).toList();

    switch (request.operation) {
      case QrScanOperation.initial:
      case QrScanOperation.append:
        final added = codes
            .where((c) => !request.currentCodes.contains(c))
            .toList();
        final duplicates = codes
            .where((c) => request.currentCodes.contains(c))
            .toList();
        return QrScanFlowResult(
          operation: request.operation,
          addedCodes: added,
          removedCodes: const [],
          duplicates: duplicates,
          skipped: const [],
          rawResults: qrResults,
        );
      case QrScanOperation.remove:
        final removed = codes
            .where((c) => request.currentCodes.contains(c))
            .toList();
        final skipped = codes
            .where((c) => !request.currentCodes.contains(c))
            .toList();
        return QrScanFlowResult(
          operation: request.operation,
          addedCodes: const [],
          removedCodes: removed,
          duplicates: const [],
          skipped: skipped,
          rawResults: qrResults,
        );
    }
  }
}

class QrScanFlowRequest {
  QrScanFlowRequest({
    required this.operation,
    required this.currentCodes,
    required this.scanType,
    this.batch = true,
    this.title,
    this.context,
  });

  final QrScanOperation operation;
  final List<String> currentCodes;
  final QrScanType scanType;
  final bool batch;
  final String? title;
  final Map<String, dynamic>? context;
}

class QrScanFlowResult {
  QrScanFlowResult({
    required this.operation,
    required this.addedCodes,
    required this.removedCodes,
    required this.duplicates,
    required this.skipped,
    required this.rawResults,
  });

  final QrScanOperation operation;
  final List<String> addedCodes; // initial/append
  final List<String> removedCodes; // remove
  final List<String> duplicates; // 对 append/initial 判重
  final List<String> skipped; // 非法或不在集合内（remove 时）
  final List<QrScanResult> rawResults;

  factory QrScanFlowResult.empty(QrScanOperation op) => QrScanFlowResult(
    operation: op,
    addedCodes: const [],
    removedCodes: const [],
    duplicates: const [],
    skipped: const [],
    rawResults: const [],
  );

  bool get hasData =>
      addedCodes.isNotEmpty || removedCodes.isNotEmpty || rawResults.isNotEmpty;
}
