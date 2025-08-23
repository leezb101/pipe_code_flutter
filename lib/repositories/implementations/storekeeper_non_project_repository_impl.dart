/*
 * @Author: LeeZB
 * @Date: 2025-08-23 15:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 15:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:pipe_code_flutter/models/common/result.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_warehouse_item.dart';
import 'package:pipe_code_flutter/models/storekeeperActions/storekeeper_signin_request.dart';
import 'package:pipe_code_flutter/models/qr_scan/qr_scan_config.dart';
import 'package:pipe_code_flutter/repositories/interfaces/storekeeper_non_project_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/storekeeper_action_repository.dart';
import 'package:pipe_code_flutter/repositories/interfaces/material_handle_repository.dart';

class StorekeeperNonProjectRepositoryImpl
    implements StorekeeperNonProjectRepository {
  const StorekeeperNonProjectRepositoryImpl({
    required StorekeeperActionRepository storekeeperActionRepository,
    required MaterialHandleRepository materialHandleRepository,
  }) : _storekeeperActionRepository = storekeeperActionRepository,
       _materialHandleRepository = materialHandleRepository;

  final StorekeeperActionRepository _storekeeperActionRepository;
  final MaterialHandleRepository _materialHandleRepository;

  @override
  Future<Result<List<StorekeeperWarehouseItem>>> getStorekeeperWarehouses() {
    return _storekeeperActionRepository.getStorekeeperWarehouses();
  }

  @override
  Future<Result<MaterialProcessResult>> processScannedMaterials(
    List<String> codes,
    QrScanOperation operation,
    List<MaterialInfo> currentMaterials,
  ) async {
    try {
      // 输入校验
      if (codes.isEmpty) {
        return Result(
          code: 0,
          msg: '成功',
          data: MaterialProcessResult(
            operation: operation,
            processedMaterials: currentMaterials,
            addedCount: 0,
            removedCount: 0,
            duplicateCount: 0,
            skippedCount: 0,
          ),
        );
      }

      // 调用物料查询服务
      final materialResult = await _materialHandleRepository
          .scanBatchToQueryAll(codes);

      if (materialResult.isFailure) {
        return Result(
          code: materialResult.code,
          msg: materialResult.msg,
          data: null,
        );
      }

      final materialBusiness = materialResult.data!;

      // 处理查询错误
      if (materialBusiness.errors.isNotEmpty) {
        final errorMessages = materialBusiness.errors
            .map(
              (e) =>
                  '二维码 ${e.qrCode ?? 'unknown'} 查询失败: ${e.msg ?? 'unknown error'}',
            )
            .toList();

        // 如果所有物料都查询失败，返回错误
        if (materialBusiness.normals.isEmpty) {
          return Result(
            code: -1,
            msg: '所有扫码物料查询失败: ${errorMessages.join('; ')}',
            data: null,
          );
        }
      }

      final scannedMaterials = materialBusiness.normals;

      // 根据操作类型处理物料列表
      switch (operation) {
        case QrScanOperation.initial:
          return Result(
            code: 0,
            msg: '成功',
            data: MaterialProcessResult(
              operation: operation,
              processedMaterials: scannedMaterials,
              addedCount: scannedMaterials.length,
              removedCount: 0,
              duplicateCount: 0,
              skippedCount: 0,
              errorMessages: _buildErrorMessages(materialBusiness.errors),
            ),
          );

        case QrScanOperation.append:
          return _processAppendOperation(
            currentMaterials,
            scannedMaterials,
            materialBusiness.errors,
          );

        case QrScanOperation.remove:
          return _processRemoveOperation(
            currentMaterials,
            scannedMaterials,
            materialBusiness.errors,
          );
      }
    } catch (e) {
      return Result(code: -1, msg: '处理扫码物料失败: $e', data: null);
    }
  }

  @override
  Result<void> validateSubmissionData({
    required int warehouseId,
    required List<MaterialInfo> materials,
    required String imageUrl,
    String? description,
  }) {
    try {
      // 校验仓库ID
      if (warehouseId <= 0) {
        return Result(code: -1, msg: '请选择仓库', data: null);
      }

      // 校验物料列表
      if (materials.isEmpty) {
        return Result(code: -1, msg: '请添加物料', data: null);
      }

      // 校验图片
      if (imageUrl.trim().isEmpty) {
        return Result(code: -1, msg: '请上传图片', data: null);
      }

      // 校验物料数据完整性
      for (final material in materials) {
        if (material.baseInfo.materialId <= 0) {
          return Result(code: -1, msg: '存在无效的物料数据', data: null);
        }
      }

      return Result(code: 0, msg: '校验通过', data: null);
    } catch (e) {
      return Result(code: -1, msg: '数据校验失败: $e', data: null);
    }
  }

  @override
  Future<Result<void>> submitNonProjectEntry({
    required int warehouseId,
    required List<MaterialInfo> materials,
    required String imageUrl,
    String? description,
  }) async {
    try {
      // 首先进行数据校验
      final validationResult = validateSubmissionData(
        warehouseId: warehouseId,
        materials: materials,
        imageUrl: imageUrl,
        description: description,
      );

      if (validationResult.isFailure) {
        return validationResult;
      }

      // 构造提交请求
      final materialIds = materials
          .map((m) => m.baseInfo.materialId.toString())
          .toList();

      final request = StorekeeperSigninRequest(
        materialIds: materialIds,
        warehouseId: warehouseId,
        img: imageUrl,
        describe: description,
      );

      // 调用提交接口
      return await _storekeeperActionRepository.storekeeperSigninWithoutProject(
        request,
      );
    } catch (e) {
      return Result(code: -1, msg: '提交入库失败: $e', data: null);
    }
  }

  /// 处理追加操作
  Result<MaterialProcessResult> _processAppendOperation(
    List<MaterialInfo> currentMaterials,
    List<MaterialInfo> scannedMaterials,
    List<dynamic> errors,
  ) {
    final duplicateCodes = <String>[];
    final newMaterials = <MaterialInfo>[];

    // 创建当前物料的ID映射表，用于快速查重
    final currentMaterialIds = currentMaterials
        .map((m) => m.baseInfo.materialId)
        .toSet();

    for (final material in scannedMaterials) {
      if (currentMaterialIds.contains(material.baseInfo.materialId)) {
        // 重复物料
        if (material.baseInfo.materialCode != null) {
          duplicateCodes.add(material.baseInfo.materialCode!);
        }
      } else {
        // 新物料
        newMaterials.add(material);
      }
    }

    // 合并物料列表
    final processedMaterials = [...currentMaterials, ...newMaterials];

    return Result(
      code: 0,
      msg: '成功',
      data: MaterialProcessResult(
        operation: QrScanOperation.append,
        processedMaterials: processedMaterials,
        addedCount: newMaterials.length,
        removedCount: 0,
        duplicateCount: duplicateCodes.length,
        skippedCount: 0,
        duplicateCodes: duplicateCodes,
        errorMessages: _buildErrorMessages(errors),
      ),
    );
  }

  /// 处理移除操作
  Result<MaterialProcessResult> _processRemoveOperation(
    List<MaterialInfo> currentMaterials,
    List<MaterialInfo> scannedMaterials,
    List<dynamic> errors,
  ) {
    final skippedCodes = <String>[];
    final removedCodes = <String>[];

    // 创建扫描物料的ID映射表
    final scannedMaterialIds = scannedMaterials
        .map((m) => m.baseInfo.materialId)
        .toSet();

    // 找出要移除的物料
    final materialsToRemove = currentMaterials
        .where((m) => scannedMaterialIds.contains(m.baseInfo.materialId))
        .toList();

    // 找出不存在的物料（跳过的）
    for (final scannedMaterial in scannedMaterials) {
      final exists = currentMaterials.any(
        (m) => m.baseInfo.materialId == scannedMaterial.baseInfo.materialId,
      );

      if (!exists && scannedMaterial.baseInfo.materialCode != null) {
        skippedCodes.add(scannedMaterial.baseInfo.materialCode!);
      } else if (exists && scannedMaterial.baseInfo.materialCode != null) {
        removedCodes.add(scannedMaterial.baseInfo.materialCode!);
      }
    }

    // 生成新的物料列表（移除指定物料）
    final processedMaterials = currentMaterials
        .where((m) => !scannedMaterialIds.contains(m.baseInfo.materialId))
        .toList();

    return Result(
      code: 0,
      msg: '成功',
      data: MaterialProcessResult(
        operation: QrScanOperation.remove,
        processedMaterials: processedMaterials,
        addedCount: 0,
        removedCount: materialsToRemove.length,
        duplicateCount: 0,
        skippedCount: skippedCodes.length,
        skippedCodes: skippedCodes,
        errorMessages: _buildErrorMessages(errors),
      ),
    );
  }

  /// 构建错误消息列表
  List<String> _buildErrorMessages(List<dynamic> errors) {
    return errors.map((e) => '二维码查询异常: ${e.toString()}').toList();
  }
}
