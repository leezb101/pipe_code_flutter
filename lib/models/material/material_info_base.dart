/*
 * @Author: LeeZB
 * @Date: 2025-07-20 15:15:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 18:18:32
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'material_info_base.g.dart';

/// 材料信息基类
/// 包含所有材料类型的公共字段
@JsonSerializable()
class MaterialInfoBase extends Equatable {
  const MaterialInfoBase({
    required this.materialId,
    this.materialCode,
    this.deliveryNumber,
    this.batchCode,
    this.mfgNm,
    this.purNm,
    this.prodStdNo,
    this.prodNm,
    this.spec,
    this.pressLvl,
    this.weight,
  });

  /// 产品Id
  final int materialId;

  /// 产品唯一编号
  final String? materialCode;

  /// 发货单号,通过此单号,可以查询到该运单包含多少件货物?
  final String? deliveryNumber;

  /// 批次号
  final String? batchCode;

  /// 制造商名称
  final String? mfgNm;

  /// 采购方名称
  final String? purNm;

  /// 产品标准号
  final String? prodStdNo;

  /// 产品名称
  final String? prodNm;

  /// 规格
  final String? spec;

  /// 压力等级
  final String? pressLvl;

  /// 重量
  final String? weight;

  factory MaterialInfoBase.fromJson(Map<String, dynamic> json) =>
      _$MaterialInfoBaseFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialInfoBaseToJson(this);

  @override
  List<Object?> get props => [
    materialId,
    materialCode,
    deliveryNumber,
    batchCode,
    mfgNm,
    purNm,
    prodStdNo,
    prodNm,
    spec,
    pressLvl,
    weight,
  ];
}

/// 完整材料信息
/// 支持动态字段，包含基础字段和扩展字段
@JsonSerializable()
class MaterialInfo extends Equatable {
  const MaterialInfo({required this.baseInfo, this.extendedFields = const {}});

  /// 基础信息
  final MaterialInfoBase baseInfo;

  /// 扩展字段，根据type和group动态包含不同的字段
  final Map<String, dynamic> extendedFields;

  factory MaterialInfo.fromJson(Map<String, dynamic> json) {
    // 提取基础字段
    final baseInfo = MaterialInfoBase.fromJson(json);

    // 提取扩展字段（排除基础字段）
    final extendedFields = Map<String, dynamic>.from(json);
    extendedFields.removeWhere(
      (key, value) => [
        'materialCode',
        'deliveryNumber',
        'batchCode',
        'mfgNm',
        'purNm',
        'prodStdNo',
        'prodNm',
        'spec',
        'pressLvl',
        'weight',
      ].contains(key),
    );

    return MaterialInfo(baseInfo: baseInfo, extendedFields: extendedFields);
  }

  Map<String, dynamic> toJson() {
    final result = baseInfo.toJson();
    result.addAll(extendedFields);
    return result;
  }

  @override
  List<Object?> get props => [baseInfo, extendedFields];
}
