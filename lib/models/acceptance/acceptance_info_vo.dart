/*
 * @Author: LeeZB
 * @Date: 2025-07-21 16:24:48
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-21 19:22:05
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';
import 'sign_in_info_vo.dart';
import '../common/common_user_vo.dart';

part 'acceptance_info_vo.g.dart';

@JsonSerializable()
class AcceptanceInfoVO extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final String? sendAcceptUrl;
  final String? acceptReportUrl;
  final bool realWarehouse;
  final int warehouseId;
  final List<CommonUserVO> warehouseUsers;
  final List<CommonUserVO> supervisorUsers;
  final List<CommonUserVO> constructionUsers;
  final SignInInfoVO? signInInfo;

  const AcceptanceInfoVO({
    required this.materialList,
    required this.imageList,
    this.sendAcceptUrl,
    this.acceptReportUrl,
    required this.realWarehouse,
    required this.warehouseId,
    required this.warehouseUsers,
    required this.supervisorUsers,
    required this.constructionUsers,
    this.signInInfo,
  });

  factory AcceptanceInfoVO.fromJson(Map<String, dynamic> json) =>
      _$AcceptanceInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptanceInfoVOToJson(this);

  @override
  List<Object?> get props => [
    materialList,
    imageList,
    sendAcceptUrl,
    acceptReportUrl,
    realWarehouse,
    warehouseId,
    warehouseUsers,
    supervisorUsers,
    constructionUsers,
    signInInfo,
  ];

  AcceptanceInfoVO copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    String? sendAcceptUrl,
    String? acceptReportUrl,
    bool? realWarehouse,
    int? warehouseId,
    List<CommonUserVO>? warehouseUsers,
    List<CommonUserVO>? supervisorUsers,
    List<CommonUserVO>? constructionUsers,
    SignInInfoVO? signInInfo,
  }) {
    return AcceptanceInfoVO(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      sendAcceptUrl: sendAcceptUrl ?? this.sendAcceptUrl,
      acceptReportUrl: acceptReportUrl ?? this.acceptReportUrl,
      realWarehouse: realWarehouse ?? this.realWarehouse,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseUsers: warehouseUsers ?? this.warehouseUsers,
      supervisorUsers: supervisorUsers ?? this.supervisorUsers,
      constructionUsers: constructionUsers ?? this.constructionUsers,
      signInInfo: signInInfo ?? this.signInInfo,
    );
  }

  String get warehouseTypeDescription {
    return realWarehouse ? '独立仓库' : '项目现场';
  }
}
