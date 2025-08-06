/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 13:03:29
 * @copyright: Copyright © 2025 高新供水.
 */

import '../../models/qr_scan/qr_scan_result.dart';
import '../../models/material/material_info_for_business.dart';
import '../../repositories/interfaces/material_handle_repository.dart';
import '../../utils/logger.dart';
import '../../config/service_locator.dart';

abstract class QrScanStrategy {
  Future<QrScanProcessResult?> process(List<QrScanResult> results, {Map<String, dynamic>? context});
}

class QrScanProcessResult {
  const QrScanProcessResult({
    required this.success,
    this.navigationData,
    this.errorMessage,
    this.data,
  });

  final bool success;
  final QrScanNavigationData? navigationData;
  final String? errorMessage;
  final List<QrScanResult>? data;
}

class QrScanNavigationData {
  const QrScanNavigationData({required this.route, this.data});

  final String route;
  final Map<String, dynamic>? data;
}

// class InboundStrategy implements QrScanStrategy {
//   late final MaterialHandleRepository _materialHandleRepository;

//   InboundStrategy() {
//     _materialHandleRepository = getIt<MaterialHandleRepository>();
//   }
//   @override
//   Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
//     await Future.delayed(const Duration(seconds: 1));

//     try {
//       if (results.length == 1) {
//         return await _processSingleInbound(results.first);
//       } else {
//         return await _processBatchInbound(results);
//       }
//     } catch (e) {
//       return QrScanProcessResult(
//         success: false,
//         errorMessage: '处理入库扫码时发生错误: $e',
//       );
//     }
//   }

//   Future<QrScanProcessResult> _processSingleInbound(QrScanResult result) async {
//     Logger.qrScan('=== 单个入库处理 ===', deviceCode: result.code);
//     Logger.qrScan('扫码内容: ${result.code}', deviceCode: result.code);
//     Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

//     // 单个模式下，直接按照扫码内容获取对应的物料信息
//     // 这里可能是交付批次码，也可能是单个物料码，由API后端判断
//     final materialResult = await _getMaterialInfoByCode(result.code);

//     if (materialResult != null &&
//         (materialResult.normals.isNotEmpty ||
//             materialResult.errors.isNotEmpty)) {
//       return QrScanProcessResult(
//         success: true,
//         navigationData: QrScanNavigationData(
//           route: '/inventory-confirmation',
//           data: {'materialInfo': materialResult, 'scanMode': 'single'},
//         ),
//       );
//     } else {
//       return const QrScanProcessResult(
//         success: false,
//         errorMessage: '未找到对应的管件信息',
//       );
//     }
//   }

//   Future<QrScanProcessResult> _processBatchInbound(
//     List<QrScanResult> results,
//   ) async {
//     Logger.qrScan('=== 批量入库处理 ===');
//     Logger.qrScan('批次大小: ${results.length}');

//     final codes = results.map((r) => r.code).toList();
//     for (int i = 0; i < results.length; i++) {
//       final result = results[i];
//       Logger.qrScan(
//         '第${i + 1}个货物 - 编号: ${result.code}',
//         deviceCode: result.code,
//       );
//     }

//     // 批量模式下，所有码都是单个物料码
//     final materialResult = await _getMaterialInfoByBatchCodes(codes);

//     if (materialResult != null &&
//         (materialResult.normals.isNotEmpty ||
//             materialResult.errors.isNotEmpty)) {
//       return QrScanProcessResult(
//         success: true,
//         navigationData: QrScanNavigationData(
//           route: '/inventory-confirmation',
//           data: {'materialInfo': materialResult, 'scanMode': 'batch'},
//         ),
//       );
//     } else {
//       return const QrScanProcessResult(
//         success: false,
//         errorMessage: '未找到对应的管件信息',
//       );
//     }
//   }

//   // 通用方法：根据任意码获取物料信息（可能是批次码或单个物料码）
//   Future<MaterialInfoForBusiness?> _getMaterialInfoByCode(String code) async {
//     try {
//       final result = await _materialHandleRepository.scanSingleToQueryAll(code);
//       if (result.isSuccess && result.data != null) {
//         return result.data!;
//       } else {
//         Logger.qrScan('获取物料信息失败: ${result.msg}', deviceCode: code);
//         return null;
//       }
//     } catch (e) {
//       Logger.qrScan('获取物料信息异常: $e', deviceCode: code);
//       return null;
//     }
//   }

//   // 批量获取物料信息
//   Future<MaterialInfoForBusiness?> _getMaterialInfoByBatchCodes(
//     List<String> codes,
//   ) async {
//     try {
//       final result = await _materialHandleRepository.scanBatchToQueryAll(codes);
//       if (result.isSuccess && result.data != null) {
//         return result.data!;
//       } else {
//         Logger.qrScan('批量获取物料信息失败: ${result.msg}');
//         return null;
//       }
//     } catch (e) {
//       Logger.qrScan('批量获取物料信息异常: $e');
//       return null;
//     }
//   }
// }

class SignoutStrategy implements QrScanStrategy {
  late final MaterialHandleRepository _materialHandleRepository;

  SignoutStrategy() {
    _materialHandleRepository = getIt<MaterialHandleRepository>();
  }

  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final result = await _processBatchSignout(results);

    return result;
  }

  Future<QrScanProcessResult> _processBatchSignout(
    List<QrScanResult> results,
  ) async {
    Logger.qrScan('=== 批量出库处理 ===');
    Logger.qrScan('批次大小: ${results.length}');
    final codes = results.map((r) => r.code).toList();

    final materialResult = await _getMaterialInfoByBatchCodes(codes);
    if (materialResult != null) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/signout',
          data: {'materialInfo': materialResult, 'scanMode': 'batch'},
        ),
      );
    } else {
      return const QrScanProcessResult(
        success: false,
        errorMessage: "未找到对应的管件信息",
      );
    }
  }

  // 批量获取物料信息
  Future<MaterialInfoForBusiness?> _getMaterialInfoByBatchCodes(
    List<String> codes,
  ) async {
    try {
      final result = await _materialHandleRepository.scanBatchToQueryAll(codes);
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        Logger.qrScan('批量获取物料信息失败: ${result.msg}');
        return null;
      }
    } catch (e) {
      Logger.qrScan('批量获取物料信息异常: $e');
      return null;
    }
  }
}

class TransferStrategy implements QrScanStrategy {
  late final MaterialHandleRepository _materialHandleRepository;

  TransferStrategy() {
    _materialHandleRepository = getIt<MaterialHandleRepository>();
  }

  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    final result = await _processBatchTransfer(results);

    return result;
  }

  Future<QrScanProcessResult> _processBatchTransfer(
    List<QrScanResult> results,
  ) async {
    Logger.qrScan('=== 批量出库处理 ===');
    Logger.qrScan('批次大小: ${results.length}');
    final codes = results.map((r) => r.code).toList();

    final materialResult = await _getMaterialInfoByBatchCodes(codes);
    if (materialResult != null) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/dispatch-application',
          data: {'materialInfo': materialResult, 'scanMode': 'batch'},
        ),
      );
    } else {
      return const QrScanProcessResult(
        success: false,
        errorMessage: "未找到对应的管件信息",
      );
    }
  }

  // 批量获取物料信息
  Future<MaterialInfoForBusiness?> _getMaterialInfoByBatchCodes(
    List<String> codes,
  ) async {
    try {
      final result = await _materialHandleRepository.scanBatchToQueryAll(codes);
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        Logger.qrScan('批量获取物料信息失败: ${result.msg}');
        return null;
      }
    } catch (e) {
      Logger.qrScan('批量获取物料信息异常: $e');
      return null;
    }
  }
}

class InventoryStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    // 对于盘点，直接返回扫码结果，让页面自己处理
    return QrScanProcessResult(success: true, data: results);
  }
}

class PipeCopyStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    // This strategy, similar to MaterialInboundStrategy, will not perform business logic here.
    // It ensures the QR code is returned to the calling page (CutPage),
    // which then uses MaterialHandleCubit to fetch the data.
    // This is necessary because the scan page cannot directly return complex data objects.

    if (results.length != 1) {
      return const QrScanProcessResult(
        success: false,
        errorMessage: '原耗材扫码一次只能扫描一个二维码',
      );
    }

    final result = results.first;
    Logger.qrScan('=== 截管-原耗材扫码 ===', deviceCode: result.code);
    Logger.qrScan('扫码内容: ${result.code}', deviceCode: result.code);

    // Return success without navigation data.
    // This signals the QrScanPage to pop and return the scanned codes to the caller.
    return const QrScanProcessResult(success: true);
  }
}

class ReturnMaterialStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (results.length == 1) {
      await _processSingleReturnMaterial(results.first);
    } else {
      await _processBatchReturnMaterial(results);
    }

    return const QrScanProcessResult(success: true);
  }

  Future<void> _processSingleReturnMaterial(QrScanResult result) async {
    // TODO: 实现单个退料的具体业务逻辑
    // 1. 验证材料编号和当前状态
    // 2. 检查退料权限和条件
    // 3. 更新库存数量和状态
    // 4. 生成退料单据
    // 5. 记录退料操作日志
  }

  Future<void> _processBatchReturnMaterial(List<QrScanResult> results) async {
    Logger.qrScan('=== 批量退料处理 ===');
    Logger.qrScan('批次大小: ${results.length}');

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      Logger.qrScan(
        '第${i + 1}个材料 - 编号: ${result.code}',
        deviceCode: result.code,
      );
    }

    Logger.qrScan('批量退料状态: 全部完成');

    // TODO: 实现批量退料的具体业务逻辑
    // 1. 批量验证所有材料编号
    // 2. 批量检查退料权限
    // 3. 批量更新库存状态
    // 4. 生成批量退料报告
    // 5. 发送退料完成通知
  }
}

class AcceptanceStrategy implements QrScanStrategy {
  late final MaterialHandleRepository _materialHandleRepository;

  AcceptanceStrategy() {
    _materialHandleRepository = getIt<MaterialHandleRepository>();
  }
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (results.length == 1) {
        return await _processSingleAcceptance(results.first);
      } else {
        return await _processBatchAcceptance(results);
      }
    } catch (e) {
      return QrScanProcessResult(
        success: false,
        errorMessage: '处理验收扫码时发生错误: $e',
      );
    }
  }

  Future<QrScanProcessResult> _processSingleAcceptance(
    QrScanResult result,
  ) async {
    Logger.qrScan('=== 单个验收处理 ===', deviceCode: result.code);
    Logger.qrScan('扫码内容: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

    // 单个模式下，直接按照扫码内容获取对应的物料信息
    final materialResult = await _getMaterialInfoByCode(result.code);

    if (materialResult != null &&
        (materialResult.normals.isNotEmpty ||
            materialResult.errors.isNotEmpty)) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/acceptance',
          data: {'materialInfo': materialResult, 'scanMode': 'single'},
        ),
      );
    } else {
      return const QrScanProcessResult(
        success: false,
        errorMessage: '未找到对应的管件信息',
      );
    }
  }

  Future<QrScanProcessResult> _processBatchAcceptance(
    List<QrScanResult> results,
  ) async {
    Logger.qrScan('=== 批量验收处理 ===');
    Logger.qrScan('批次大小: ${results.length}');

    final codes = results.map((r) => r.code).toList();
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      Logger.qrScan(
        '第${i + 1}个货物 - 编号: ${result.code}',
        deviceCode: result.code,
      );
    }

    // 批量模式下，所有码都是单个物料码
    final materialResult = await _getMaterialInfoByBatchCodes(codes);

    if (materialResult != null &&
        (materialResult.normals.isNotEmpty ||
            materialResult.errors.isNotEmpty)) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/acceptance',
          data: {'materialInfo': materialResult, 'scanMode': 'batch'},
        ),
      );
    } else {
      return const QrScanProcessResult(
        success: false,
        errorMessage: '未找到对应的管件信息',
      );
    }
  }

  // 通用方法：根据任意码获取物料信息（可能是批次码或单个物料码）
  Future<MaterialInfoForBusiness?> _getMaterialInfoByCode(String code) async {
    try {
      final result = await _materialHandleRepository.scanSingleToQueryAll(code);
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        Logger.qrScan('获取物料信息失败: ${result.msg}', deviceCode: code);
        return null;
      }
    } catch (e) {
      Logger.qrScan('获取物料信息异常: $e', deviceCode: code);
      return null;
    }
  }

  // 批量获取物料信息
  Future<MaterialInfoForBusiness?> _getMaterialInfoByBatchCodes(
    List<String> codes,
  ) async {
    try {
      final result = await _materialHandleRepository.scanBatchToQueryAll(codes);
      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        Logger.qrScan('批量获取物料信息失败: ${result.msg}');
        return null;
      }
    } catch (e) {
      Logger.qrScan('批量获取物料信息异常: $e');
      return null;
    }
  }
}

class IdentificationStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // 扫码识别只支持单个扫码
      if (results.length == 1) {
        return await _processSingleIdentification(results.first);
      } else {
        return const QrScanProcessResult(
          success: false,
          errorMessage: '扫码识别功能不支持批量扫码，请一次只扫描一个二维码',
        );
      }
    } catch (e) {
      Logger.qrScan('扫码识别处理异常: $e');
      return QrScanProcessResult(
        success: false,
        errorMessage: '扫码识别失败: ${e.toString()}',
      );
    }
  }

  Future<QrScanProcessResult> _processSingleIdentification(
    QrScanResult result,
  ) async {
    Logger.qrScan('=== 单个扫码识别处理 ===', deviceCode: result.code);
    Logger.qrScan('识别编号: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

    try {
      // 简化验证：只检查二维码格式有效性，不获取详细数据
      if (result.code.trim().isEmpty) {
        return QrScanProcessResult(
          success: false,
          errorMessage: '二维码内容为空',
        );
      }

      // 基本格式验证（可根据需要添加更多验证规则）
      if (result.code.length < 3) {
        return QrScanProcessResult(
          success: false,
          errorMessage: '二维码内容格式无效',
        );
      }

      Logger.qrScan('扫码识别验证通过 - 编码: ${result.code}', deviceCode: result.code);

      // 直接返回二维码字符串，让 MaterialDetailCubit 处理数据获取
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/material-detail',
          data: {'materialCode': result.code},
        ),
      );
    } catch (e) {
      Logger.qrScan('扫码识别处理异常: $e', deviceCode: result.code);
      return QrScanProcessResult(
        success: false,
        errorMessage: '扫码处理失败: ${e.toString()}',
      );
    }
  }
}

class MaterialInboundStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // 这个策略只负责返回扫码结果，不做任何业务处理
      // 物料匹配和验证逻辑由AcceptanceBloc处理
      if (results.length == 1) {
        final result = results.first;
        Logger.qrScan('=== 物料入库扫码 ===', deviceCode: result.code);
        Logger.qrScan('扫码内容: ${result.code}', deviceCode: result.code);
        Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

        return const QrScanProcessResult(
          success: true,
          // 不设置 navigationData，让调用页面处理扫码结果
        );
      } else {
        return const QrScanProcessResult(
          success: false,
          errorMessage: '物料入库扫码只支持单个扫码',
        );
      }
    } catch (e) {
      Logger.qrScan('物料入库扫码处理异常: $e');
      return QrScanProcessResult(
        success: false,
        errorMessage: '扫码处理失败: ${e.toString()}',
      );
    }
  }
}

class InstallStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // 这个策略只负责返回扫码结果，不做任何业务处理
      // 物料匹配和验证逻辑由AcceptanceBloc处理
      if (results.length == 1) {
        final result = results.first;
        Logger.qrScan('=== 物料入库扫码 ===', deviceCode: result.code);
        Logger.qrScan('扫码内容: ${result.code}', deviceCode: result.code);
        Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

        return const QrScanProcessResult(
          success: true,
          // 不设置 navigationData，让调用页面处理扫码结果
        );
      } else {
        return const QrScanProcessResult(
          success: false,
          errorMessage: '物料入库扫码只支持单个扫码',
        );
      }
    } catch (e) {
      Logger.qrScan('物料入库扫码处理异常: $e');
      return QrScanProcessResult(
        success: false,
        errorMessage: '扫码处理失败: ${e.toString()}',
      );
    }
  }
}

class ScrapStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(
    List<QrScanResult> results, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // 根据调用来源决定处理方式
      final source = context?['source'] as String?;
      
      if (source == 'scrapPage') {
        // 从 ScrapPage 中继续扫码，只返回数据不进行导航
        Logger.qrScan('=== ScrapPage 继续扫码 ===');
        Logger.qrScan('扫码数量: ${results.length}');
        
        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          Logger.qrScan(
            '第${i + 1}个 - 编号: ${result.code}',
            deviceCode: result.code,
          );
        }
        
        return QrScanProcessResult(success: true, data: results);
      } else {
        // 从菜单页面进入，需要带上导航信息跳转到 ScrapPage
        Logger.qrScan('=== 菜单页面报废扫码 ===');
        Logger.qrScan('扫码数量: ${results.length}');
        
        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          Logger.qrScan(
            '第${i + 1}个 - 编号: ${result.code}',
            deviceCode: result.code,
          );
        }
        
        // 返回导航数据，跳转到 ScrapPage
        final codes = results.map((r) => r.code).toList();
        return QrScanProcessResult(
          success: true,
          navigationData: QrScanNavigationData(
            route: '/scrap',
            data: {'codes': codes},
          ),
        );
      }
    } catch (e) {
      Logger.qrScan('报废扫码处理异常: $e');
      return QrScanProcessResult(
        success: false,
        errorMessage: '扫码处理失败: ${e.toString()}',
      );
    }
  }
}
