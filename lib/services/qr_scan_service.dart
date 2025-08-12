/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:10:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 13:03:48
 * @copyright: Copyright © 2025 高新供水.
 */

abstract class QrScanService {
  Future<bool> validateCode(String code);
  // Scanning is decoupled from business; service only validates code format now.
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

  // No more processXxx calls here.
}
