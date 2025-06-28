/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-06-28 14:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

enum QrScanType {
  acceptance('验收'),
  verification('核销'),
  inspection('巡检');

  const QrScanType(this.displayName);

  final String displayName;
}

enum AcceptanceType {
  single('单个验收'),
  batch('批量验收');

  const AcceptanceType(this.displayName);

  final String displayName;
}