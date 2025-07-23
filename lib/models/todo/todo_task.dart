/*
 * @Author: LeeZB
 * @Date: 2025-07-22 10:43:58
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-23 15:02:39
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';

part 'todo_task.g.dart';

@JsonSerializable()
class TodoTask extends Equatable {
  const TodoTask({
    required this.id,
    required this.name,
    required this.todoType,
    required this.todoName,
    required this.businessId,
    required this.projectId,
    required this.projectName,
    required this.projectCode,
    required this.launchTime,
    required this.finishTime,
    required this.finishStatus,
    required this.launchUser,
    required this.launchName,
  });

  final int id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'todoType')
  final int todoType;

  @JsonKey(name: 'todoName')
  final String todoName;

  @JsonKey(name: 'businessId')
  final int businessId;

  @JsonKey(name: 'projectId')
  final int projectId;

  @JsonKey(name: 'projectName')
  final String projectName;

  @JsonKey(name: 'projectCode')
  final String projectCode;

  @JsonKey(
    name: 'launchTime',
    fromJson: _timestampToDateTime,
    toJson: _dateTimeToTimestamp,
  )
  final DateTime? launchTime;

  @JsonKey(
    name: 'finishTime',
    fromJson: _timestampToDateTime,
    toJson: _dateTimeToTimestamp,
  )
  final DateTime? finishTime;

  @JsonKey(name: 'finishStatus')
  final int finishStatus;

  @JsonKey(name: 'launchUser')
  final String launchUser;

  @JsonKey(name: 'launchName')
  final String launchName;

  bool get isCompleted => finishStatus == 1;

  /// 获取材料类型枚举
  TodoType get type => TodoType.fromInt(todoType) ?? TodoType(todoType, '未知类型');

  factory TodoTask.fromJson(Map<String, dynamic> json) =>
      _$TodoTaskFromJson(json);

  Map<String, dynamic> toJson() => _$TodoTaskToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    todoType,
    todoName,
    businessId,
    projectId,
    projectName,
    projectCode,
    launchTime,
    finishTime,
    finishStatus,
    launchUser,
    launchName,
  ];

  static DateTime? _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    // 处理数字类型（int、double）
    if (timestamp is num) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }

    // 处理字符串类型的时间戳
    if (timestamp is String) {
      final parsed = int.tryParse(timestamp);
      if (parsed != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsed);
      }
    }

    return null;
  }

  static int? _dateTimeToTimestamp(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch;
  }
}
