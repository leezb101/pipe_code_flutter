/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 18:53:18
 * @copyright: Copyright © 2025 高新供水.
 */

import '../models/qr_scan/qr_scan_result.dart';
import 'qr_scan_strategies/qr_scan_strategy.dart';

abstract class QrScanService {
  Future<bool> validateCode(String code);
  // Future<QrScanProcessResult?> processInbound(List<QrScanResult> results);
  Future<QrScanProcessResult?> processSignout(List<QrScanResult> results);
  Future<QrScanProcessResult?> processTransfer(List<QrScanResult> results);
  Future<QrScanProcessResult?> processInventory(List<QrScanResult> results);
  Future<QrScanProcessResult?> processPipeCopy(List<QrScanResult> results);
  Future<QrScanProcessResult?> processIdentification(
    List<QrScanResult> results,
  );
  Future<QrScanProcessResult?> processReturnMaterial(
    List<QrScanResult> results,
  );
  Future<QrScanProcessResult?> processAcceptance(List<QrScanResult> results);
  Future<QrScanProcessResult?> processMaterialInbound(
    List<QrScanResult> results,
  );
}

class QrScanServiceImpl implements QrScanService {
  QrScanServiceImpl();

  @override
  Future<bool> validateCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (code.isEmpty) {
      return false;
    }

    // final validPattern = RegExp(r'^[A-Z0-9]{6,20}$');
    // return validPattern.hasMatch(code);
    return true;
  }

  // @override
  // Future<QrScanProcessResult?> processInbound(
  //   List<QrScanResult> results,
  // ) async {
  //   final strategy = InboundStrategy();
  //   return strategy.process(results);
  // }

  @override
  Future<QrScanProcessResult?> processSignout(
    List<QrScanResult> results,
  ) async {
    final strategy = SignoutStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processTransfer(
    List<QrScanResult> results,
  ) async {
    final strategy = TransferStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processInventory(
    List<QrScanResult> results,
  ) async {
    final strategy = InventoryStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processPipeCopy(
    List<QrScanResult> results,
  ) async {
    final strategy = PipeCopyStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processIdentification(
    List<QrScanResult> results,
  ) async {
    final strategy = IdentificationStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processReturnMaterial(
    List<QrScanResult> results,
  ) {
    final strategy = ReturnMaterialStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processAcceptance(List<QrScanResult> results) {
    final strategy = AcceptanceStrategy();
    return strategy.process(results);
  }

  @override
  Future<QrScanProcessResult?> processMaterialInbound(
    List<QrScanResult> results,
  ) {
    final strategy = MaterialInboundStrategy();
    return strategy.process(results);
  }
}
