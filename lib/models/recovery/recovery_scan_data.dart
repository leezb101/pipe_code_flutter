/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'recovery_scan_data.g.dart';

/// Recovery模块专用的扫描数据模型
/// 用于Step3提交后返回的确认信息
@JsonSerializable()
class RecoveryScanData extends Equatable {
  const RecoveryScanData({
    required this.type,
    required this.group,
    this.produceDate,
    this.materialId,
    this.isDestroy,
    this.isBack,
    required this.materialCode,
    this.transCardNo,
    this.batchCode,
    this.deliveryNumber,
    this.mfgNm,
    this.mfgCode,
    this.purNm,
    this.prodStdNo,
    this.standard,
    this.prodNm,
    this.spec,
    this.pressLvl,
    this.weight,
    this.deliveryCode,
    this.otherMaterialByDelivery,
    this.delivery,
    this.warrantyUrl,
    this.currentWarrantyUrl,
    this.certificateUrl,
    this.currentCertificateUrl,
    this.signUrl,
    this.currentSignUrl,
  });

  /// 材料类型
  final int type;

  /// 材料分组
  final int group;

  /// 生产日期
  final String? produceDate;

  /// 材料ID
  final int? materialId;

  /// 是否销毁
  final bool? isDestroy;

  /// 是否回收
  final bool? isBack;

  /// 材料编码
  final String materialCode;

  /// 运输卡号
  final String? transCardNo;

  /// 批次号
  final String? batchCode;

  /// 发货单号
  final String? deliveryNumber;

  /// 制造商名称
  final String? mfgNm;

  /// 制造商代码
  final String? mfgCode;

  /// 采购方名称
  final String? purNm;

  /// 产品标准号
  final String? prodStdNo;

  /// 标准
  final String? standard;

  /// 产品名称
  final String? prodNm;

  /// 规格
  final String? spec;

  /// 压力等级
  final String? pressLvl;

  /// 重量
  final String? weight;

  /// 发货编码
  final String? deliveryCode;

  /// 其他材料（按发货单）
  final List<String>? otherMaterialByDelivery;

  /// 发货信息
  final DeliveryInfo? delivery;

  /// 质保书URL
  final String? warrantyUrl;

  /// 当前质保书URL
  final String? currentWarrantyUrl;

  /// 证书URL
  final String? certificateUrl;

  /// 当前证书URL
  final String? currentCertificateUrl;

  /// 签名URL
  final String? signUrl;

  /// 当前签名URL
  final String? currentSignUrl;

  factory RecoveryScanData.fromJson(Map<String, dynamic> json) =>
      _$RecoveryScanDataFromJson(json);

  Map<String, dynamic> toJson() => _$RecoveryScanDataToJson(this);

  @override
  List<Object?> get props => [
    type,
    group,
    produceDate,
    materialId,
    isDestroy,
    isBack,
    materialCode,
    transCardNo,
    batchCode,
    deliveryNumber,
    mfgNm,
    mfgCode,
    purNm,
    prodStdNo,
    standard,
    prodNm,
    spec,
    pressLvl,
    weight,
    deliveryCode,
    otherMaterialByDelivery,
    delivery,
    warrantyUrl,
    currentWarrantyUrl,
    certificateUrl,
    currentCertificateUrl,
    signUrl,
    currentSignUrl,
  ];
}

/// 发货信息模型
@JsonSerializable()
class DeliveryInfo extends Equatable {
  const DeliveryInfo({
    this.deliveryCode,
    this.tranPlanNo,
    this.salesmanName,
    this.salesmanPhone,
    this.consignee,
    this.consigneePhone,
    this.consigneeAddr,
    this.carryCorpName,
    this.vehicleNo,
    this.driverName,
    this.driverPhone,
    this.signUrl,
    this.currentSignUrl,
    this.totalQty,
    this.totalWt,
    this.leaveFactoryTime,
    this.signTime,
  });

  /// 发货编码
  final String? deliveryCode;

  /// 运输计划号
  final String? tranPlanNo;

  /// 销售员姓名
  final String? salesmanName;

  /// 销售员电话
  final String? salesmanPhone;

  /// 收货人
  final String? consignee;

  /// 收货人电话
  final String? consigneePhone;

  /// 收货地址
  final String? consigneeAddr;

  /// 承运公司名称
  final String? carryCorpName;

  /// 车牌号
  final String? vehicleNo;

  /// 司机姓名
  final String? driverName;

  /// 司机电话
  final String? driverPhone;

  /// 签名URL
  final String? signUrl;

  /// 当前签名URL
  final String? currentSignUrl;

  /// 总数量
  final String? totalQty;

  /// 总重量
  final String? totalWt;

  /// 出厂时间
  final String? leaveFactoryTime;

  /// 签收时间
  final String? signTime;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      _$DeliveryInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryInfoToJson(this);

  @override
  List<Object?> get props => [
    deliveryCode,
    tranPlanNo,
    salesmanName,
    salesmanPhone,
    consignee,
    consigneePhone,
    consigneeAddr,
    carryCorpName,
    vehicleNo,
    driverName,
    driverPhone,
    signUrl,
    currentSignUrl,
    totalQty,
    totalWt,
    leaveFactoryTime,
    signTime,
  ];
}
