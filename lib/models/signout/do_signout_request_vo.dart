import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/acceptance/attachment_vo.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';

part 'do_signout_request_vo.g.dart';

@JsonSerializable()
class DoSignoutRequestVo extends Equatable {
  final List<MaterialVO> materialList;
  final List<AttachmentVO> imageList;
  final List<int> messageTo;

  const DoSignoutRequestVo({
    required this.materialList,
    required this.imageList,
    required this.messageTo,
  });

  factory DoSignoutRequestVo.fromJson(Map<String, dynamic> json) =>
      _$DoSignoutRequestVoFromJson(json);

  Map<String, dynamic> toJson() => _$DoSignoutRequestVoToJson(this);

  @override
  List<Object?> get props => [materialList, imageList, messageTo];

  DoSignoutRequestVo copyWith({
    List<MaterialVO>? materialList,
    List<AttachmentVO>? imageList,
    List<int>? messageTo,
  }) {
    return DoSignoutRequestVo(
      materialList: materialList ?? this.materialList,
      imageList: imageList ?? this.imageList,
      messageTo: messageTo ?? this.messageTo,
    );
  }
}
