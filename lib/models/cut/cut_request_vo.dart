/*
 * @Author: LeeZB
 * @Date: 2025-07-30 18:42:46
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 18:46:19
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cut_request_vo.g.dart';

@JsonSerializable()
class CutRequestVo extends Equatable {
  final List<CutRequestVo> cutMaterialSubVOS;
  final String qrCode;
  final String img;
  final String? description;

  const CutRequestVo({
    required this.cutMaterialSubVOS,
    required this.qrCode,
    required this.img,
    this.description,
  });

  @override
  List<Object?> get props => [cutMaterialSubVOS, qrCode, img, description];

  factory CutRequestVo.fromJson(Map<String, dynamic> json) =>
      _$CutRequestVoFromJson(json);

  Map<String, dynamic> toJson() => _$CutRequestVoToJson(this);
}
