/*
 * @Author: LeeZB
 * @Date: 2025-07-30 18:38:05
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 18:42:34
 * @copyright: Copyright © 2025 高新供水.
 */
/*
 * @Author: LeeZB
 * @Date: 2025-07-30 18:38:05
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 18:41:17
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cut_material_sub_vo.g.dart';

@JsonSerializable()
class CutMaterialSubVO extends Equatable {
  final String qrCode;
  final String len;
  @JsonKey(defaultValue: '')
  final String img;

  const CutMaterialSubVO({
    required this.qrCode,
    required this.len,
    this.img = '',
  });

  @override
  List<Object?> get props => [qrCode, len, img];

  factory CutMaterialSubVO.fromJson(Map<String, dynamic> json) =>
      _$CutMaterialSubVOFromJson(json);

  Map<String, dynamic> toJson() => _$CutMaterialSubVOToJson(this);
}
