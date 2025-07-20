import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment_vo.g.dart';

@JsonSerializable()
class AttachmentVO extends Equatable {
  final int type;
  final String name;
  final String url;
  final int attachFormat;

  const AttachmentVO({
    required this.type,
    required this.name,
    required this.url,
    required this.attachFormat,
  });

  factory AttachmentVO.fromJson(Map<String, dynamic> json) =>
      _$AttachmentVOFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentVOToJson(this);

  @override
  List<Object?> get props => [
        type,
        name,
        url,
        attachFormat,
      ];

  AttachmentVO copyWith({
    int? type,
    String? name,
    String? url,
    int? attachFormat,
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

  bool get isImage => attachFormat == 1;
  bool get isPdf => attachFormat == 2;
  bool get isDoc => attachFormat == 3;
}