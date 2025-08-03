import 'package:flutter_test/flutter_test.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_type.dart';

void main() {
  group('QrScanConfig isRemoveOperation tests', () {
    test('should default to false for isRemoveOperation', () {
      final config = QrScanConfig(scanType: QrScanType.scrap);

      expect(config.isRemoveOperation, false);
    });

    test('should allow setting isRemoveOperation to true', () {
      final config = QrScanConfig(
        scanType: QrScanType.scrap,
        isRemoveOperation: true,
      );

      expect(config.isRemoveOperation, true);
    });

    test('should correctly serialize and deserialize isRemoveOperation', () {
      final config = QrScanConfig(
        scanType: QrScanType.scrap,
        scanMode: QrScanMode.batch,
        context: {'source': 'scrapPageRemove'},
        isRemoveOperation: true,
      );

      final json = config.toJson();
      final deserialized = QrScanConfig.fromJson(json);

      expect(deserialized.isRemoveOperation, true);
      expect(deserialized.scanType, QrScanType.scrap);
      expect(deserialized.scanMode, QrScanMode.batch);
      expect(deserialized.context?['source'], 'scrapPageRemove');
    });

    test(
      'should default to false when deserializing without isRemoveOperation field',
      () {
        final json = {
          'scanType': 'scrap',
          'scanMode': 'batch',
          'context': {'source': 'scrapPage'},
        };

        final config = QrScanConfig.fromJson(json);

        expect(config.isRemoveOperation, false);
      },
    );
  });
}
