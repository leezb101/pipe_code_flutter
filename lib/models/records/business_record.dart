import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart';

part 'business_record.g.dart';

@JsonSerializable()
class BusinessRecord extends Equatable {
  final int id;
  final int? bizType;
  final String? projectName;
  final String? projectCode;
  final int? materialNum;
  @JsonKey(defaultValue: '')
  final String userName;
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime? doTime;
  final String? statusName;
  final String? toProjectName;

  const BusinessRecord({
    required this.id,
    this.bizType,
    this.projectName,
    this.projectCode,
    this.materialNum,
    required this.userName,
    this.doTime,
    this.statusName,
    this.toProjectName,
  });

  factory BusinessRecord.fromJson(Map<String, dynamic> json) =>
      _$BusinessRecordFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessRecordToJson(this);

  @override
  List<Object?> get props => [
    id,
    bizType,
    projectName,
    projectCode,
    materialNum,
    userName,
    doTime,
    statusName,
    toProjectName,
  ];

  BusinessRecord copyWith({
    int? id,
    int? bizType,
    String? projectName,
    String? projectCode,
    int? materialNum,
    String? userName,
    DateTime? doTime,
    String? statusName,
    String? toProjectName,
  }) {
    return BusinessRecord(
      id: id ?? this.id,
      bizType: bizType ?? this.bizType,
      projectName: projectName ?? this.projectName,
      projectCode: projectCode ?? this.projectCode,
      materialNum: materialNum ?? this.materialNum,
      userName: userName ?? this.userName,
      doTime: doTime ?? this.doTime,
      statusName: statusName ?? this.statusName,
      toProjectName: toProjectName ?? this.toProjectName,
    );
  }

  String get businessTypeDescription {
    if (bizType == null) return '未知业务';

    final businessType = BusinessType.fromInt(bizType!);
    return businessType?.name ?? '未知业务';
  }

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
