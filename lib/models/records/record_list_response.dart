import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'business_record.dart';
import 'project_record.dart';

part 'record_list_response.g.dart';

@JsonSerializable()
class BusinessRecordPageData extends Equatable {
  final List<BusinessRecord> records;
  final int total;
  final int size;
  final int current;

  const BusinessRecordPageData({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
  });

  factory BusinessRecordPageData.fromJson(Map<String, dynamic> json) =>
      _$BusinessRecordPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessRecordPageDataToJson(this);

  @override
  List<Object> get props => [records, total, size, current];
}

@JsonSerializable()
class ProjectRecordPageData extends Equatable {
  final List<ProjectRecord> records;
  final int total;
  final int size;
  final int current;
  final int? pages;

  const ProjectRecordPageData({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    this.pages,
  });

  factory ProjectRecordPageData.fromJson(Map<String, dynamic> json) =>
      _$ProjectRecordPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectRecordPageDataToJson(this);

  @override
  List<Object?> get props => [records, total, size, current, pages];
}

@JsonSerializable()
class BusinessRecordListResponse extends Equatable {
  final int code;
  final String msg;
  final BusinessRecordPageData data;

  const BusinessRecordListResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory BusinessRecordListResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessRecordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessRecordListResponseToJson(this);

  @override
  List<Object> get props => [code, msg, data];

  bool get isSuccess => code == 0;
}

@JsonSerializable()
class ProjectRecordListResponse extends Equatable {
  final int code;
  final String msg;
  final ProjectRecordPageData data;
  final bool? success;

  const ProjectRecordListResponse({
    required this.code,
    required this.msg,
    required this.data,
    this.success,
  });

  factory ProjectRecordListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectRecordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectRecordListResponseToJson(this);

  @override
  List<Object?> get props => [code, msg, data, success];

  bool get isSuccess => code == 0;
}

// Type alias for general record list response
typedef RecordListResponse = BusinessRecordListResponse;
