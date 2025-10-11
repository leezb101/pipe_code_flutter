import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'cut_records_item_vo.g.dart';

@JsonSerializable()
class CutRecordsItemVO extends Equatable {
  final int projectId;

  final int? type;

  final String? typeName;

  final String? spec;

  final String? name;

  final String? len;

  final String? materialCode;

  final int materialId;

  /// 截管时间，格式化为 YYYY-MM-DD HH:mm:ss
  @JsonKey(fromJson: _cutTimeFromJson, toJson: _cutTimeToJson)
  final String? cutTime;

  const CutRecordsItemVO({
    required this.projectId,
    required this.materialId,
    this.type,
    this.typeName,
    this.spec,
    this.name,
    this.len,
    this.materialCode,
    this.cutTime,
  });

  /// 将13位时间戳转换为格式化字符串
  static String? _cutTimeFromJson(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      int timeInMillis;
      if (timestamp is int) {
        timeInMillis = timestamp;
      } else if (timestamp is String) {
        timeInMillis = int.parse(timestamp);
      } else {
        return null;
      }

      final dateTime = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      return formatter.format(dateTime);
    } catch (e) {
      return null;
    }
  }

  /// 将格式化字符串转换回时间戳（用于序列化）
  static int? _cutTimeToJson(String? formattedTime) {
    if (formattedTime == null) return null;

    try {
      final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final dateTime = formatter.parse(formattedTime);
      return dateTime.millisecondsSinceEpoch;
    } catch (e) {
      return null;
    }
  }

  factory CutRecordsItemVO.fromJson(Map<String, dynamic> json) =>
      _$CutRecordsItemVOFromJson(json);

  Map<String, dynamic> toJson() => _$CutRecordsItemVOToJson(this);

  @override
  List<Object?> get props => [
    projectId,
    materialId,
    type,
    typeName,
    spec,
    name,
    len,
    materialCode,
    cutTime,
  ];
}
