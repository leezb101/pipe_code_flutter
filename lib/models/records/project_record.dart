import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_record.g.dart';

@JsonSerializable()
class ProjectRecord extends Equatable {
  final int id;
  final String projectName;
  final String projectCode;
  final String? projectStart;
  final String? projectEnd;
  final String? createdName;
  final int? createdId;
  final int status;

  const ProjectRecord({
    required this.id,
    required this.projectName,
    required this.projectCode,
    this.projectStart,
    this.projectEnd,
    this.createdName,
    this.createdId,
    required this.status,
  });

  factory ProjectRecord.fromJson(Map<String, dynamic> json) =>
      _$ProjectRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectRecordToJson(this);

  @override
  List<Object?> get props => [
        id,
        projectName,
        projectCode,
        projectStart,
        projectEnd,
        createdName,
        createdId,
        status,
      ];

  ProjectRecord copyWith({
    int? id,
    String? projectName,
    String? projectCode,
    String? projectStart,
    String? projectEnd,
    String? createdName,
    int? createdId,
    int? status,
  }) {
    return ProjectRecord(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      projectCode: projectCode ?? this.projectCode,
      projectStart: projectStart ?? this.projectStart,
      projectEnd: projectEnd ?? this.projectEnd,
      createdName: createdName ?? this.createdName,
      createdId: createdId ?? this.createdId,
      status: status ?? this.status,
    );
  }

  String get statusDescription {
    switch (status) {
      case 0:
        return '待审核';
      case 1:
        return '已通过';
      case 2:
        return '已拒绝';
      case 3:
        return '进行中';
      case 4:
        return '已完成';
      default:
        return '未知状态';
    }
  }

  String get businessTypeDescription {
    return '项目$statusDescription';
  }

  String get userName => createdName ?? '未知用户';
  
  String get doTime => projectStart ?? '';
}