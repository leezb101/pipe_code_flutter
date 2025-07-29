/*
 * @Author: LeeZB
 * @Date: 2025-07-22 08:53:08
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-28 19:42:33
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment_vo.g.dart';

@JsonSerializable()
class AttachmentVO extends Equatable {
  final int? type;
  final String? name;
  final String url;
  final String? attachFormat;

  const AttachmentVO({
    this.type,
    this.name,
    required this.url,
    this.attachFormat,
  });

  factory AttachmentVO.fromJson(Map<String, dynamic> json) =>
      _$AttachmentVOFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentVOToJson(this);

  @override
  List<Object?> get props => [type, name, url, attachFormat];

  AttachmentVO copyWith({
    int? type,
    String? name,
    String? url,
    String? attachFormat,
  }) {
    return AttachmentVO(
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
      attachFormat: attachFormat ?? this.attachFormat,
    );
  }

  String get attachmentTypeDescription {
    switch (type) {
      case 1:
        return '报验单';
      case 2:
        return '验收报告';
      case 3:
        return '验收照片';
      default:
        return '其他附件';
    }
  }
}
