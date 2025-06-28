/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:10:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../models/qr_scan/qr_scan_result.dart';
import '../models/qr_scan/qr_scan_type.dart';
import 'qr_scan_strategies/qr_scan_strategy.dart';

abstract class QrScanService {
  Future<bool> validateCode(String code);
  Future<void> processAcceptance(List<QrScanResult> results, AcceptanceType type);
  Future<void> processVerification(QrScanResult result);
  Future<void> processInspection(QrScanResult result);
}

class QrScanServiceImpl implements QrScanService {
  QrScanServiceImpl();

  @override
  Future<bool> validateCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (code.isEmpty || code.length < 6) {
      return false;
    }
    
    final validPattern = RegExp(r'^[A-Z0-9]{6,20}$');
    return validPattern.hasMatch(code);
  }

  @override
  Future<void> processAcceptance(List<QrScanResult> results, AcceptanceType type) async {
    final strategy = AcceptanceStrategy(acceptanceType: type);
    await strategy.process(results);
  }

  @override
  Future<void> processVerification(QrScanResult result) async {
    final strategy = VerificationStrategy();
    await strategy.process([result]);
  }

  @override
  Future<void> processInspection(QrScanResult result) async {
    final strategy = InspectionStrategy();
    await strategy.process([result]);
  }
}