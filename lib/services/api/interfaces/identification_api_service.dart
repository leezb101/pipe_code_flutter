/*
 * @Author: LeeZB
 * @Date: 2025-07-20 15:25:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-20 15:25:00
 * @copyright: Copyright © 2025 高新供水.
 */

import '../../../models/material/scan_identification_response.dart';
import '../../../models/common/result.dart';

/// 扫码识别API服务接口
abstract class IdentificationApiService {
  /// 扫码识别材料信息
  /// 
  /// [code] 扫描到的二维码内容，如 ZZWATER:729960879520481280
  /// 
  /// 返回材料的详细信息，包括基础属性和根据类型动态的扩展属性
  Future<Result<ScanIdentificationData>> scanMaterialIdentification(String code);
}