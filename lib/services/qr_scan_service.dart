/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-05 15:22:01
 * @copyright: Copyright © 2025 高新供水.
 */

import '../models/qr_scan/qr_scan_result.dart';
import 'qr_scan_strategies/qr_scan_strategy.dart';

abstract class QrScanService {
  Future<bool> validateCode(String code);
  Future<void> processInbound(List<QrScanResult> results);
  Future<void> processOutbound(List<QrScanResult> results);
  Future<void> processTransfer(List<QrScanResult> results);
  Future<void> processInventory(List<QrScanResult> results);
  Future<void> processPipeCopy(List<QrScanResult> results);
  Future<void> processIdentification(List<QrScanResult> results);
  Future<void> processReturnMaterial(List<QrScanResult> results);
}

class QrScanServiceImpl implements QrScanService {
  QrScanServiceImpl();

  @override
  Future<bool> validateCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (code.isEmpty || code.length < 6) {
      return false;
    }

    // final validPattern = RegExp(r'^[A-Z0-9]{6,20}$');
    // return validPattern.hasMatch(code);
    return true;
  }

  @override
  Future<void> processInbound(List<QrScanResult> results) async {
    final strategy = InboundStrategy();
    await strategy.process(results);
  }

  @override
  Future<void> processOutbound(List<QrScanResult> results) async {
    final strategy = OutboundStrategy();
    await strategy.process(results);
  }

  @override
  Future<void> processTransfer(List<QrScanResult> results) async {
    final strategy = TransferStrategy();
    await strategy.process(results);
  }

  @override
  Future<void> processInventory(List<QrScanResult> results) async {
    final strategy = InventoryStrategy();
    await strategy.process(results);
  }

  @override
  Future<void> processPipeCopy(List<QrScanResult> results) async {
    final strategy = PipeCopyStrategy();
    await strategy.process(results);
  }

  @override
  Future<void> processIdentification(List<QrScanResult> results) async {
    final strategy = IdentificationStrategy();
    await strategy.process(results);
  }

  @override
  Future<void> processReturnMaterial(List<QrScanResult> results) {
    final strategy = ReturnMaterialStrategy();
    return strategy.process(results);
  }
}
