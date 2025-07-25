/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-24 18:49:56
 * @copyright: Copyright © 2025 高新供水.
 */

enum QrScanType {
  // inbound('入库'),
  signout('出库'),
  transfer('调拨'),
  inventory('盘点'),
  pipeCopy('截管复制'),
  identification('扫码识别'),
  returnMaterial('退库'),
  acceptance('验收'),
  materialInbound('物料入库');

  /// 扫码类型枚举

  const QrScanType(this.displayName);

  final String displayName;
}

enum QrScanMode {
  single('单个扫码'),
  batch('连续扫码');

  const QrScanMode(this.displayName);

  final String displayName;
}
