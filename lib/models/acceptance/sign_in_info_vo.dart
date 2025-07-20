import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';

part 'sign_in_info_vo.g.dart';

@JsonSerializable()
class SignInInfoVO extends Equatable {
  final List<MaterialVO> materiaList;
  final List<AttachmentVO> imageList;
  final int warehouseId;

  const SignInInfoVO({
    required this.materiaList,
    required this.imageList,
    required this.warehouseId,
  });

  factory SignInInfoVO.fromJson(Map<String, dynamic> json) =>
      _$SignInInfoVOFromJson(json);

  Map<String, dynamic> toJson() => _$SignInInfoVOToJson(this);

  @override
  List<Object?> get props => [
        materiaList,
        imageList,
        warehouseId,
      ];

  SignInInfoVO copyWith({
    List<MaterialVO>? materiaList,
    List<AttachmentVO>? imageList,
    int? warehouseId,
  }) {
    return SignInInfoVO(
      materiaList: materiaList ?? this.materiaList,
      imageList: imageList ?? this.imageList,
      warehouseId: warehouseId ?? this.warehouseId,
    );
  }
}