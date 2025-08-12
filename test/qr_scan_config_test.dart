import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
// QrScanType removed

void main() {
  group('QrScanConfig operation tests', () {
    test('defaults to initial operation', () {
      final config = const QrScanConfig();
      expect(config.operation, QrScanOperation.initial);
      expect(config.isRemove, false);
    });

    test('explicit remove operation reflects in isRemove', () {
      final config = const QrScanConfig(operation: QrScanOperation.remove);
      expect(config.operation, QrScanOperation.remove);
      expect(config.isRemove, true);
    });

    test('json serialize/deserialize keeps operation', () {
      final config = const QrScanConfig(
        scanMode: QrScanMode.batch,
        context: {'source': 'returnPage'},
        operation: QrScanOperation.append,
      );
      final json = config.toJson();
      final restored = QrScanConfig.fromJson(json);
      expect(restored.operation, QrScanOperation.append);
      expect(restored.scanMode, QrScanMode.batch);
      expect(restored.context?['source'], 'returnPage');
    });

    test('missing operation in json defaults to initial', () {
      final legacyJson = {
        'scanMode': 'batch',
        'context': {'source': 'legacy'},
      };
      final cfg = QrScanConfig.fromJson(legacyJson);
      expect(cfg.operation, QrScanOperation.initial);
      expect(cfg.isRemove, false);
    });
  });
}
