/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/recovery/recovery_scan_data.dart';

/// Step3提交结果
/// 封装step3 API返回的数据，包含服务端确认信息和用于step4的key
class Step3Result extends Equatable {
  /// 服务端返回的材料识别数据
  final RecoveryScanData scanData;

  /// 从response header中提取的key，用于step4提交
  final String headerKey;

  const Step3Result({required this.scanData, required this.headerKey});

  @override
  List<Object?> get props => [scanData, headerKey];
}
