/*
 * @Author: LeeZB
 * @Date: 2025-09-29
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/jsf_accept_vo.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';

/// 建设方验收事件
sealed class JsfAcceptanceEvent extends Equatable {
  const JsfAcceptanceEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化材料列表
final class InitializeJsfMaterials extends JsfAcceptanceEvent {
  final List<MaterialInfo> materials;

  const InitializeJsfMaterials({required this.materials});

  @override
  List<Object?> get props => [materials];
}

/// 从扫码初始化材料
final class InitializeJsfMaterialsFromCodes extends JsfAcceptanceEvent {
  final List<String> codes;
  final bool isBatch;

  const InitializeJsfMaterialsFromCodes({
    required this.codes,
    this.isBatch = true,
  });

  @override
  List<Object?> get props => [codes, isBatch];
}

/// 通过扫码追加材料
final class AppendJsfMaterialsByCodes extends JsfAcceptanceEvent {
  final List<String> codes;

  const AppendJsfMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// 通过扫码移除材料
final class RemoveJsfMaterialsByCodes extends JsfAcceptanceEvent {
  final List<String> codes;

  const RemoveJsfMaterialsByCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// 加载仓库列表
final class LoadJsfWarehouseList extends JsfAcceptanceEvent {
  const LoadJsfWarehouseList();
}

/// 加载仓库用户信息
final class LoadJsfWarehouseUsers extends JsfAcceptanceEvent {
  final int warehouseId;

  const LoadJsfWarehouseUsers({required this.warehouseId});

  @override
  List<Object?> get props => [warehouseId];
}

/// 提交验收
final class SubmitJsfAcceptance extends JsfAcceptanceEvent {
  final JsfAcceptVO request;

  const SubmitJsfAcceptance({required this.request});

  @override
  List<Object?> get props => [request];
}

/// 清除消息
final class ClearJsfMessage extends JsfAcceptanceEvent {
  const ClearJsfMessage();
}
