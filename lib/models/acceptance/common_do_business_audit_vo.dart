import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'common_do_business_audit_vo.g.dart';

@JsonSerializable()
class CommonDoBusinessAuditVO extends Equatable {
  final int id;
  final bool pass;

  const CommonDoBusinessAuditVO({
    required this.id,
    required this.pass,
  });

  factory CommonDoBusinessAuditVO.fromJson(Map<String, dynamic> json) =>
      _$CommonDoBusinessAuditVOFromJson(json);

  Map<String, dynamic> toJson() => _$CommonDoBusinessAuditVOToJson(this);

  @override
  List<Object?> get props => [id, pass];

  CommonDoBusinessAuditVO copyWith({
    int? id,
    bool? pass,
  }) {
    return CommonDoBusinessAuditVO(
      id: id ?? this.id,
      pass: pass ?? this.pass,
    );
  }
}