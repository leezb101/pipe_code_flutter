/*
 * @Author: LeeZB
 * @Date: 2025-07-05 16:45:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-16 14:31:19
 * @copyright: Copyright © 2025 高新供水.
 */

/// 菜单操作常量定义
///
/// 用于定义所有菜单项的action值，避免在使用时出现拼写错误
/// 所有菜单操作都应该使用这里定义的常量
class MenuActions {
  MenuActions._();

  // QR扫码相关操作
  static const String qrScanInbound = 'qr_scan_inbound';
  static const String qrScanOutbound = 'qr_scan_outbound';
  static const String qrScanReturnMaterial = 'qr_scan_return_material';
  static const String qrScanTransfer = 'qr_scan_transfer';
  static const String qrScanInventory = 'qr_scan_inventory';
  static const String qrScanPipeCopy = 'qr_scan_pipe_copy';
  static const String qrScanAcceptance = 'qr_scan_acceptance';
  static const String qrIdentify = 'qr_identify';

  // 委托操作
  static const String delegateHarvest = 'delegate_harvest';
  static const String delegateAccept = 'delegate_accept';

  // 其他操作

  // 所有可用的操作列表（用于验证）
  static const List<String> allActions = [
    qrScanInbound,
    qrScanOutbound,
    qrScanReturnMaterial,
    qrScanTransfer,
    qrScanInventory,
    qrScanPipeCopy,
    qrScanAcceptance,
    qrIdentify,
    delegateHarvest,
    delegateAccept,
  ];

  /// 验证action是否有效
  static bool isValidAction(String action) {
    return allActions.contains(action);
  }

  /// 获取action的显示名称
  static String getDisplayName(String action) {
    switch (action) {
      case qrScanInbound:
        return '入库扫码';
      case qrScanOutbound:
        return '出库扫码';
      case qrScanReturnMaterial:
        return '退库扫码';
      case qrScanTransfer:
        return '调拨扫码';
      case qrScanInventory:
        return '盘点扫码';
      case qrScanPipeCopy:
        return '截管复制扫码';
      case qrScanAcceptance:
        return '验收扫码';
      case qrIdentify:
        return '扫码识别';
      case delegateHarvest:
        return '委托收割';
      case delegateAccept:
        return '委托验收';
      default:
        return action;
    }
  }
}
