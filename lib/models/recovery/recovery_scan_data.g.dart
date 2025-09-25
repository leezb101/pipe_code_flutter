// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_scan_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecoveryScanData _$RecoveryScanDataFromJson(Map<String, dynamic> json) =>
    RecoveryScanData(
      type: (json['type'] as num).toInt(),
      group: (json['group'] as num).toInt(),
      produceDate: json['produceDate'] as String?,
      materialId: (json['materialId'] as num?)?.toInt(),
      isDestroy: json['isDestroy'] as bool?,
      isBack: json['isBack'] as bool?,
      materialCode: json['materialCode'] as String,
      transCardNo: json['transCardNo'] as String?,
      batchCode: json['batchCode'] as String?,
      deliveryNumber: json['deliveryNumber'] as String?,
      mfgNm: json['mfgNm'] as String?,
      mfgCode: json['mfgCode'] as String?,
      purNm: json['purNm'] as String?,
      prodStdNo: json['prodStdNo'] as String?,
      standard: json['standard'] as String?,
      prodNm: json['prodNm'] as String?,
      spec: json['spec'] as String?,
      pressLvl: json['pressLvl'] as String?,
      weight: json['weight'] as String?,
      deliveryCode: json['deliveryCode'] as String?,
      otherMaterialByDelivery:
          (json['otherMaterialByDelivery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      delivery: json['delivery'] == null
          ? null
          : DeliveryInfo.fromJson(json['delivery'] as Map<String, dynamic>),
      warrantyUrl: json['warrantyUrl'] as String?,
      currentWarrantyUrl: json['currentWarrantyUrl'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      currentCertificateUrl: json['currentCertificateUrl'] as String?,
      signUrl: json['signUrl'] as String?,
      currentSignUrl: json['currentSignUrl'] as String?,
    );

Map<String, dynamic> _$RecoveryScanDataToJson(RecoveryScanData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'group': instance.group,
      'produceDate': instance.produceDate,
      'materialId': instance.materialId,
      'isDestroy': instance.isDestroy,
      'isBack': instance.isBack,
      'materialCode': instance.materialCode,
      'transCardNo': instance.transCardNo,
      'batchCode': instance.batchCode,
      'deliveryNumber': instance.deliveryNumber,
      'mfgNm': instance.mfgNm,
      'mfgCode': instance.mfgCode,
      'purNm': instance.purNm,
      'prodStdNo': instance.prodStdNo,
      'standard': instance.standard,
      'prodNm': instance.prodNm,
      'spec': instance.spec,
      'pressLvl': instance.pressLvl,
      'weight': instance.weight,
      'deliveryCode': instance.deliveryCode,
      'otherMaterialByDelivery': instance.otherMaterialByDelivery,
      'delivery': instance.delivery,
      'warrantyUrl': instance.warrantyUrl,
      'currentWarrantyUrl': instance.currentWarrantyUrl,
      'certificateUrl': instance.certificateUrl,
      'currentCertificateUrl': instance.currentCertificateUrl,
      'signUrl': instance.signUrl,
      'currentSignUrl': instance.currentSignUrl,
    };

DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) => DeliveryInfo(
  deliveryCode: json['deliveryCode'] as String?,
  tranPlanNo: json['tranPlanNo'] as String?,
  salesmanName: json['salesmanName'] as String?,
  salesmanPhone: json['salesmanPhone'] as String?,
  consignee: json['consignee'] as String?,
  consigneePhone: json['consigneePhone'] as String?,
  consigneeAddr: json['consigneeAddr'] as String?,
  carryCorpName: json['carryCorpName'] as String?,
  vehicleNo: json['vehicleNo'] as String?,
  driverName: json['driverName'] as String?,
  driverPhone: json['driverPhone'] as String?,
  signUrl: json['signUrl'] as String?,
  currentSignUrl: json['currentSignUrl'] as String?,
  totalQty: json['totalQty'] as String?,
  totalWt: json['totalWt'] as String?,
  leaveFactoryTime: json['leaveFactoryTime'] as String?,
  signTime: json['signTime'] as String?,
);

Map<String, dynamic> _$DeliveryInfoToJson(DeliveryInfo instance) =>
    <String, dynamic>{
      'deliveryCode': instance.deliveryCode,
      'tranPlanNo': instance.tranPlanNo,
      'salesmanName': instance.salesmanName,
      'salesmanPhone': instance.salesmanPhone,
      'consignee': instance.consignee,
      'consigneePhone': instance.consigneePhone,
      'consigneeAddr': instance.consigneeAddr,
      'carryCorpName': instance.carryCorpName,
      'vehicleNo': instance.vehicleNo,
      'driverName': instance.driverName,
      'driverPhone': instance.driverPhone,
      'signUrl': instance.signUrl,
      'currentSignUrl': instance.currentSignUrl,
      'totalQty': instance.totalQty,
      'totalWt': instance.totalWt,
      'leaveFactoryTime': instance.leaveFactoryTime,
      'signTime': instance.signTime,
    };
