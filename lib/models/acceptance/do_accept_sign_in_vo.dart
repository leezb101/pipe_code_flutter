import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';

part 'do_accept_sign_in_vo.g.dart';

@JsonSerializable()
class DoAcceptSignInVO extends Equatable {
  final int acceptId;
  final List<MaterialVO> materiaList;
  final List<AttachmentVO> imageList;

  const DoAcceptSignInVO({
    required this.acceptId,
    required this.materiaList,
    required this.imageList,
  });

  factory DoAcceptSignInVO.fromJson(Map<String, dynamic> json) =>
      _$DoAcceptSignInVOFromJson(json);

  Map<String, dynamic> toJson() => _$DoAcceptSignInVOToJson(this);

  @override
  List<Object?> get props => [
        acceptId,
        materiaList,
        imageList,
      ];

  DoAcceptSignInVO copyWith({
    int? acceptId,
    List<MaterialVO>? materiaList,
    List<AttachmentVO>? imageList,
  }) {
    return DoAcceptSignInVO(
      acceptId: acceptId ?? this.acceptId,
      materiaList: materiaList ?? this.materiaList,
      imageList: imageList ?? this.imageList,
    );
  }
}