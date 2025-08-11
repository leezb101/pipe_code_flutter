import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';

void main() {
  group('QrScanConfig operation tests', () {
    test('defaults to initial operation', () {
      final config = QrScanConfig(scanType: QrScanType.scrap);
      expect(config.operation, QrScanOperation.initial);
      expect(config.isRemove, false);
    });

    test('explicit remove operation reflects in isRemove', () {
      final config = QrScanConfig(
        scanType: QrScanType.scrap,
        operation: QrScanOperation.remove,
      );
      expect(config.operation, QrScanOperation.remove);
      expect(config.isRemove, true);
    });

    test('json serialize/deserialize keeps operation', () {
      final config = QrScanConfig(
        scanType: QrScanType.returnMaterial,
        scanMode: QrScanMode.batch,
        context: {'source': 'returnPage'},
        operation: QrScanOperation.append,
      );
      final json = config.toJson();
      final restored = QrScanConfig.fromJson(json);
      expect(restored.operation, QrScanOperation.append);
      expect(restored.scanType, QrScanType.returnMaterial);
      expect(restored.scanMode, QrScanMode.batch);
      expect(restored.context?['source'], 'returnPage');
    });

    test('missing operation in json defaults to initial', () {
      final legacyJson = {
        'scanType': 'scrap',
        'scanMode': 'batch',
        'context': {'source': 'legacy'},
      };
      final cfg = QrScanConfig.fromJson(legacyJson);
      expect(cfg.operation, QrScanOperation.initial);
      expect(cfg.isRemove, false);
    });
  });
}
