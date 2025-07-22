/*
 * @Author: LeeZB
 * @Date: 2025-06-28 14:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 17:16:56
 * @copyright: Copyright © 2025 高新供水.
 */

import '../../models/qr_scan/qr_scan_result.dart';
import '../../models/inventory/pipe_material.dart';
import '../../utils/logger.dart';
import '../api_service_factory.dart';

abstract class QrScanStrategy {
  Future<QrScanProcessResult?> process(List<QrScanResult> results);
}

class QrScanProcessResult {
  const QrScanProcessResult({
    required this.success,
    this.navigationData,
    this.errorMessage,
  });

  final bool success;
  final QrScanNavigationData? navigationData;
  final String? errorMessage;
}

class QrScanNavigationData {
  const QrScanNavigationData({required this.route, this.data});

  final String route;
  final Map<String, dynamic>? data;
}

class InboundStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (results.length == 1) {
        return await _processSingleInbound(results.first);
      } else {
        return await _processBatchInbound(results);
      }
    } catch (e) {
      return QrScanProcessResult(
        success: false,
        errorMessage: '处理入库扫码时发生错误: $e',
      );
    }
  }

  Future<QrScanProcessResult> _processSingleInbound(QrScanResult result) async {
    Logger.qrScan('=== 单个入库处理 ===', deviceCode: result.code);
    Logger.qrScan('扫码内容: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

    // 单个模式下，直接按照扫码内容获取对应的物料信息
    // 这里可能是交付批次码，也可能是单个物料码，由API后端判断
    final materials = await _getPipeMaterialsByCode(result.code);

    if (materials.isNotEmpty) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/inventory-confirmation',
          data: {'materials': materials, 'scanMode': 'single'},
        ),
      );
    } else {
      return const QrScanProcessResult(
        success: false,
        errorMessage: '未找到对应的管件信息',
      );
    }
  }

  Future<QrScanProcessResult> _processBatchInbound(
    List<QrScanResult> results,
  ) async {
    Logger.qrScan('=== 批量入库处理 ===');
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
    final materials = await _getPipeMaterialsByIds(codes);

    if (materials.isNotEmpty) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/inventory-confirmation',
          data: {'materials': materials, 'scanMode': 'batch'},
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
  Future<List<PipeMaterial>> _getPipeMaterialsByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 这里应该调用后端API，后端根据码的内容返回对应的物料信息
    // 后端会自动判断这是批次码还是单个物料码，并返回相应的物料列表

    // 模拟：这里简单返回单个物料，实际项目中应该由后端API处理
    return [
      PipeMaterial(
        id: code,
        materialCode: 'FDSIU-129A',
        materialName: '材料A',
        specification: 'DN100',
        quantity: 1,
        unit: '个',
        batchCode: 'BATCH_001',
        deliveryDate: DateTime.now().subtract(const Duration(days: 7)),
        supplier: '供应商A',
        remarks: '质量良好',
      ),
    ];
  }

  // 模拟根据ID获取管件信息
  Future<List<PipeMaterial>> _getPipeMaterialsByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ids
        .map(
          (id) => PipeMaterial(
            id: id,
            materialCode: 'FDSIU-129A',
            materialName: '材料A',
            specification: 'DN100',
            quantity: 1,
            unit: '个',
            batchCode: 'BATCH_001',
            deliveryDate: DateTime.now().subtract(const Duration(days: 7)),
            supplier: '供应商A',
            remarks: '质量良好',
          ),
        )
        .toList();
  }
}

class OutboundStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
    await Future.delayed(const Duration(seconds: 1));

    if (results.length == 1) {
      await _processSingleOutbound(results.first);
    } else {
      await _processBatchOutbound(results);
    }

    return const QrScanProcessResult(success: true);
  }

  Future<void> _processSingleOutbound(QrScanResult result) async {
    Logger.qrScan('=== 单个出库处理 ===', deviceCode: result.code);
    Logger.qrScan('货物编号: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);
    Logger.qrScan('出库状态: 出库完成', deviceCode: result.code);

    // TODO: 实现单个出库的具体业务逻辑
    // 1. 验证货物编号和库存状态
    // 2. 检查可用库存数量
    // 3. 更新库存数量和状态
    // 4. 生成出库单据
    // 5. 记录出库操作日志
  }

  Future<void> _processBatchOutbound(List<QrScanResult> results) async {
    Logger.qrScan('=== 批量出库处理 ===');
    Logger.qrScan('批次大小: ${results.length}');

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      Logger.qrScan(
        '第${i + 1}个货物 - 编号: ${result.code}',
        deviceCode: result.code,
      );
    }

    Logger.qrScan('批量出库状态: 全部完成');

    // TODO: 实现批量出库的具体业务逻辑
    // 1. 批量验证所有货物编号
    // 2. 批量检查库存数量
    // 3. 批量更新库存状态
    // 4. 生成批量出库报告
    // 5. 发送出库完成通知
  }
}

class TransferStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
    await Future.delayed(const Duration(seconds: 1));

    if (results.length == 1) {
      await _processSingleTransfer(results.first);
    } else {
      await _processBatchTransfer(results);
    }

    return const QrScanProcessResult(success: true);
  }

  Future<void> _processSingleTransfer(QrScanResult result) async {
    Logger.qrScan('=== 单个调拨处理 ===', deviceCode: result.code);
    Logger.qrScan('货物编号: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);
    Logger.qrScan('调拨状态: 调拨完成', deviceCode: result.code);

    // TODO: 实现单个调拨的具体业务逻辑
    // 1. 验证货物编号和当前位置
    // 2. 检查源和目标仓库状态
    // 3. 更新货物位置信息
    // 4. 生成调拨单据
    // 5. 记录调拨操作日志
  }

  Future<void> _processBatchTransfer(List<QrScanResult> results) async {
    Logger.qrScan('=== 批量调拨处理 ===');
    Logger.qrScan('批次大小: ${results.length}');

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      Logger.qrScan(
        '第${i + 1}个货物 - 编号: ${result.code}',
        deviceCode: result.code,
      );
    }

    Logger.qrScan('批量调拨状态: 全部完成');

    // TODO: 实现批量调拨的具体业务逻辑
    // 1. 批量验证所有货物编号
    // 2. 批量检查仓库状态
    // 3. 批量更新位置信息
    // 4. 生成批量调拨报告
    // 5. 发送调拨完成通知
  }
}

class InventoryStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
    await Future.delayed(const Duration(seconds: 1));

    if (results.length == 1) {
      await _processSingleInventory(results.first);
    } else {
      await _processBatchInventory(results);
    }

    return const QrScanProcessResult(success: true);
  }

  Future<void> _processSingleInventory(QrScanResult result) async {
    Logger.qrScan('=== 单个盘点处理 ===', deviceCode: result.code);
    Logger.qrScan('货物编号: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

    // 模拟库存信息查询结果
    final inventoryInfo = _mockInventoryInfo(result.code);
    Logger.qrScan('库存信息: $inventoryInfo', deviceCode: result.code);
    Logger.qrScan('盘点状态: 盘点完成', deviceCode: result.code);

    // TODO: 实现单个盘点的具体业务逻辑
    // 1. 查询货物的理论库存数量
    // 2. 记录实际盘点数量
    // 3. 计算库存差异
    // 4. 生成盘点记录
    // 5. 标记异常情况
  }

  Future<void> _processBatchInventory(List<QrScanResult> results) async {
    Logger.qrScan('=== 批量盘点处理 ===');
    Logger.qrScan('批次大小: ${results.length}');

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      Logger.qrScan(
        '第${i + 1}个货物 - 编号: ${result.code}',
        deviceCode: result.code,
      );
    }

    Logger.qrScan('批量盘点状态: 全部完成');

    // TODO: 实现批量盘点的具体业务逻辑
    // 1. 批量查询理论库存
    // 2. 批量记录实际数量
    // 3. 批量计算库存差异
    // 4. 生成批量盘点报告
    // 5. 发送盘点完成通知
  }

  Map<String, dynamic> _mockInventoryInfo(String itemCode) {
    return {
      '货物编号': itemCode,
      '货物名称': '水管配件',
      '理论库存': 100,
      '实际数量': 98,
      '差异数量': -2,
      '仓库位置': 'A区01号货架',
      '最近更新': '2024-06-15',
      '备注': '需要检查缺失原因',
    };
  }
}

class PipeCopyStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
    await Future.delayed(const Duration(seconds: 1));

    if (results.length == 1) {
      await _processSinglePipeCopy(results.first);
    } else {
      await _processBatchPipeCopy(results);
    }

    return const QrScanProcessResult(success: true);
  }

  Future<void> _processSinglePipeCopy(QrScanResult result) async {
    Logger.qrScan('=== 单个截管复制处理 ===', deviceCode: result.code);
    Logger.qrScan('管道编号: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

    // 模拟管道信息查询结果
    final pipeInfo = _mockPipeInfo(result.code);
    Logger.qrScan('管道信息: $pipeInfo', deviceCode: result.code);
    Logger.qrScan('截管复制状态: 复制完成', deviceCode: result.code);

    // TODO: 实现单个截管复制的具体业务逻辑
    // 1. 查询管道的详细信息和图纸
    // 2. 复制管道规格和参数
    // 3. 生成新的管道编号
    // 4. 创建管道复制记录
    // 5. 更新管网图纸资料
  }

  Future<void> _processBatchPipeCopy(List<QrScanResult> results) async {
    Logger.qrScan('=== 批量截管复制处理 ===');
    Logger.qrScan('批次大小: ${results.length}');

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      Logger.qrScan(
        '第${i + 1}个管道 - 编号: ${result.code}',
        deviceCode: result.code,
      );
    }

    Logger.qrScan('批量截管复制状态: 全部完成');

    // TODO: 实现批量截管复制的具体业务逻辑
    // 1. 批量查询管道信息
    // 2. 批量生成新编号
    // 3. 批量创建复制记录
    // 4. 生成批量复制报告
    // 5. 更新管网系统数据
  }

  Map<String, dynamic> _mockPipeInfo(String pipeCode) {
    return {
      '管道编号': pipeCode,
      '管道类型': '主供水管',
      '管径规格': 'DN300',
      '材质': '球墨铸铁管',
      '安装日期': '2023-03-20',
      '位置信息': '某某路段地下2米',
      '设计压力': '1.0MPa',
      '备注': '需要截管延伸施工',
    };
  }
}

class ReturnMaterialStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
    await Future.delayed(const Duration(seconds: 1));

    if (results.length == 1) {
      await _processSingleReturnMaterial(results.first);
    } else {
      await _processBatchReturnMaterial(results);
    }

    return const QrScanProcessResult(success: true);
  }

  Future<void> _processSingleReturnMaterial(QrScanResult result) async {
    Logger.qrScan('=== 单个退料处理 ===', deviceCode: result.code);
    Logger.qrScan('材料编号: ${result.code}', deviceCode: result.code);
    Logger.qrScan('扫描时间: ${result.scannedAt}', deviceCode: result.code);

    // 模拟退料信息查询结果
    final returnInfo = _mockReturnMaterialInfo(result.code);
    Logger.qrScan('退料信息: $returnInfo', deviceCode: result.code);
    Logger.qrScan('退料状态: 退料完成', deviceCode: result.code);

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

  Map<String, dynamic> _mockReturnMaterialInfo(String materialCode) {
    return {
      '材料编号': materialCode,
      '材料名称': '水管接头',
      '规格型号': 'DN100 弯头',
      '退料数量': 5,
      '退料原因': '规格不匹配',
      '原领料人': '李师傅',
      '退料时间': DateTime.now().toString().substring(0, 19),
      '退料状态': '已退回库存',
      '备注': '材料完好，可重新使用',
    };
  }
}

class AcceptanceStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
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
    final materials = await _getPipeMaterialsByCode(result.code);

    if (materials.isNotEmpty) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/acceptance',
          data: {'materials': materials, 'scanMode': 'single'},
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
    final materials = await _getPipeMaterialsByIds(codes);

    if (materials.isNotEmpty) {
      return QrScanProcessResult(
        success: true,
        navigationData: QrScanNavigationData(
          route: '/acceptance',
          data: {'materials': materials, 'scanMode': 'batch'},
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
  Future<List<PipeMaterial>> _getPipeMaterialsByCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟：返回验收物料信息
    return [
      PipeMaterial(
        id: code,
        materialCode: 'FDSIU-129A',
        materialName: '材料A',
        specification: 'DN100',
        quantity: 1,
        unit: '个',
        batchCode: 'BATCH_001',
        deliveryDate: DateTime.now().subtract(const Duration(days: 7)),
        supplier: '供应商A',
        remarks: '待验收',
      ),
    ];
  }

  // 模拟根据ID获取管件信息
  Future<List<PipeMaterial>> _getPipeMaterialsByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ids
        .map(
          (id) => PipeMaterial(
            id: id,
            materialCode: 'FDSIU-129A',
            materialName: '材料A',
            specification: 'DN100',
            quantity: 1,
            unit: '个',
            batchCode: 'BATCH_001',
            deliveryDate: DateTime.now().subtract(const Duration(days: 7)),
            supplier: '供应商A',
            remarks: '待验收',
          ),
        )
        .toList();
  }
}

class IdentificationStrategy implements QrScanStrategy {
  @override
  Future<QrScanProcessResult?> process(List<QrScanResult> results) async {
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
      // 调用扫码识别API
      final identificationService =
          ApiServiceFactory.createIdentificationService();
      final apiResult = await identificationService.scanMaterialIdentification(
        result.code,
      );

      if (apiResult.isSuccess && apiResult.data != null) {
        Logger.qrScan(
          '识别成功 - 类型: ${apiResult.data!.materialType.name}, 分组: ${apiResult.data!.materialGroup.name}, 编码: ${apiResult.data!.materialCode}',
          deviceCode: result.code,
        );

        // 返回导航到材料详情页面
        return QrScanProcessResult(
          success: true,
          navigationData: QrScanNavigationData(
            route: '/material-detail',
            data: {'identificationData': apiResult.data},
          ),
        );
      } else {
        Logger.qrScan('识别失败: ${apiResult.msg}', deviceCode: result.code);
        return QrScanProcessResult(
          success: false,
          errorMessage: apiResult.msg.isNotEmpty ? apiResult.msg : '识别失败',
        );
      }
    } catch (e) {
      Logger.qrScan('识别API调用异常: $e', deviceCode: result.code);
      return QrScanProcessResult(
        success: false,
        errorMessage: e.toString().contains('网络')
            ? e.toString()
            : '识别服务异常，请稍后重试',
      );
    }
  }
}
