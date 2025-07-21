import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'business_record.g.dart';

@JsonSerializable()
class BusinessRecord extends Equatable {
  final int id;
  final int? bizType;
  final String projectName;
  final String projectCode;
  final int? materialNum;
  final String userName;
  @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
  final DateTime? doTime;

  const BusinessRecord({
    required this.id,
    this.bizType,
    required this.projectName,
    required this.projectCode,
    this.materialNum,
    required this.userName,
    this.doTime,
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
  ];

  BusinessRecord copyWith({
    int? id,
    int? bizType,
    String? projectName,
    String? projectCode,
    int? materialNum,
    String? userName,
    DateTime? doTime,
  }) {
    return BusinessRecord(
      id: id ?? this.id,
      bizType: bizType ?? this.bizType,
      projectName: projectName ?? this.projectName,
      projectCode: projectCode ?? this.projectCode,
      materialNum: materialNum ?? this.materialNum,
      userName: userName ?? this.userName,
      doTime: doTime ?? this.doTime,
    );
  }

  String get businessTypeDescription {
    if (bizType == null) return '未知业务';

    switch (bizType) {
      case 1:
        return '建设方验收确认';
      case 2:
        return '调拨收货确认';
      case 3:
        return '材料入库登记';
      case 4:
        return '设备安装确认';
      case 5:
        return '材料退库处理';
      case 6:
        return '设备报废处理';
      case 7:
        return '库存盘点';
      default:
        return '业务处理';
    }
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
