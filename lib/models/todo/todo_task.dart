import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_task.g.dart';

@JsonSerializable()
class TodoTask extends Equatable {
  const TodoTask({
    required this.id,
    required this.name,
    required this.businessType,
    required this.businessName,
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
  
  @JsonKey(name: 'businessType')
  final int businessType;
  
  @JsonKey(name: 'businessName')
  final String businessName;
  
  @JsonKey(name: 'businessId')
  final int businessId;
  
  @JsonKey(name: 'projectId')
  final int projectId;
  
  @JsonKey(name: 'projectName')
  final String projectName;
  
  @JsonKey(name: 'projectCode')
  final String projectCode;
  
  @JsonKey(name: 'launchTime', fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime? launchTime;
  
  @JsonKey(name: 'finishTime', fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime? finishTime;
  
  @JsonKey(name: 'finishStatus')
  final int finishStatus;
  
  @JsonKey(name: 'launchUser')
  final String launchUser;
  
  @JsonKey(name: 'launchName')
  final String launchName;

  bool get isCompleted => finishStatus == 1;

  factory TodoTask.fromJson(Map<String, dynamic> json) => _$TodoTaskFromJson(json);
  
  Map<String, dynamic> toJson() => _$TodoTaskToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        businessType,
        businessName,
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
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  static int? _dateTimeToTimestamp(DateTime? dateTime) {
    return dateTime?.millisecondsSinceEpoch;
  }
}