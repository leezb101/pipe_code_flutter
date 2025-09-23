import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_do_business_audit_vo.g.dart';

@JsonSerializable()
class CommonDoBusinessAuditVO extends Equatable {
  final int id;
  final bool pass;
  final String? reason;
  final List<String>? reasonVoice;

  const CommonDoBusinessAuditVO({
    required this.id,
    required this.pass,
    this.reason,
    this.reasonVoice,
  });

  factory CommonDoBusinessAuditVO.fromJson(Map<String, dynamic> json) =>
      _$CommonDoBusinessAuditVOFromJson(json);

  Map<String, dynamic> toJson() => _$CommonDoBusinessAuditVOToJson(this);

  @override
  List<Object?> get props => [id, pass, reason, reasonVoice];

  CommonDoBusinessAuditVO copyWith({
    int? id,
    bool? pass,
    String? reason,
    List<String>? reasonVoice,
  }) {
    return CommonDoBusinessAuditVO(
      id: id ?? this.id,
      pass: pass ?? this.pass,
      reason: reason ?? this.reason,
      reasonVoice: reasonVoice ?? this.reasonVoice,
    );
  }
}
