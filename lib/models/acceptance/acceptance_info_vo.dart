import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';
import 'sign_in_info_vo.dart';
import 'common_user_vo.dart';

part 'acceptance_info_vo.g.dart';

@JsonSerializable()
class AcceptanceInfoVO extends Equatable {
  final List<MaterialVO> materiaList;
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
    required this.materiaList,
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
        materiaList,
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
    List<MaterialVO>? materiaList,
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
      materiaList: materiaList ?? this.materiaList,
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