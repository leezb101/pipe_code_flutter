/*
 * @Author: LeeZB
 * @Date: 2025-09-29 
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-09-29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'jsf_material_vo.dart';
import 'attachment_vo.dart';
import 'jsf_return_data_vo.dart';

part 'jsf_accept_vo.g.dart';

@JsonSerializable()
class JsfAcceptVO extends Equatable {
  final String? lng;
  final String? lat;
  final List<JsfMaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final List<String>? sendAcceptUrl;
  final List<String>? acceptReportUrl;
  final bool realWarehouse;
  final int warehouseId;
  final List<int> messageTo;
  final JsfReturnDataVO? returnData;

  const JsfAcceptVO({
    this.lng,
    this.lat,
    required this.materialList,
    required this.imageList,
    this.sendAcceptUrl,
    this.acceptReportUrl,
    required this.realWarehouse,
    required this.warehouseId,
    required this.messageTo,
    this.returnData,
  });

  factory JsfAcceptVO.fromJson(Map<String, dynamic> json) =>
      _$JsfAcceptVOFromJson(json);

  Map<String, dynamic> toJson() => _$JsfAcceptVOToJson(this);

  @override
  List<Object?> get props => [
    lng,
    lat,
    materialList,
    imageList,
    sendAcceptUrl,
    acceptReportUrl,
    realWarehouse,
    warehouseId,
    messageTo,
    returnData,
  ];

  JsfAcceptVO copyWith({
    String? lng,
    String? lat,
    List<JsfMaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    List<String>? sendAcceptUrl,
    List<String>? acceptReportUrl,
    bool? realWarehouse,
    int? warehouseId,
    List<int>? messageTo,
    JsfReturnDataVO? returnData,
  }) {
    return JsfAcceptVO(
      lng: lng ?? this.lng,
      lat: lat ?? this.lat,
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      sendAcceptUrl: sendAcceptUrl ?? this.sendAcceptUrl,
      acceptReportUrl: acceptReportUrl ?? this.acceptReportUrl,
      realWarehouse: realWarehouse ?? this.realWarehouse,
      warehouseId: warehouseId ?? this.warehouseId,
      messageTo: messageTo ?? this.messageTo,
      returnData: returnData ?? this.returnData,
    );
  }
}
