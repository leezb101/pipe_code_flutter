/*
 * @Author: LeeZB
 * @Date: 2025-07-27 13:20:56
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-27 13:21:48
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_simple_vo.g.dart';

@JsonSerializable()
class ProjectSimpleVo extends Equatable {
  final int id;
  final String name;

  const ProjectSimpleVo({required this.id, required this.name});

  factory ProjectSimpleVo.fromJson(Map<String, dynamic> json) =>
      _$ProjectSimpleVoFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSimpleVoToJson(this);

  @override
  List<Object?> get props => [id, name];

  copyWith({int? id, String? name}) {
    return ProjectSimpleVo(id: id ?? this.id, name: name ?? this.name);
  }
}
