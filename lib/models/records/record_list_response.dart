import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'business_record.dart';
import 'project_record.dart';

part 'record_list_response.g.dart';

@JsonSerializable()
class OrderItem extends Equatable {
  final String column;
  final bool asc;

  const OrderItem({
    required this.column,
    required this.asc,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  @override
  List<Object> get props => [column, asc];
}

@JsonSerializable()
class BusinessRecordPageData extends Equatable {
  final List<BusinessRecord> records;
  final int total;
  final int size;
  final int current;
  final List<OrderItem> orders;
  final bool optimizeCountSql;
  final bool searchCount;
  final bool optimizeJoinOfCountSql;
  final int maxLimit;
  final String countId;

  const BusinessRecordPageData({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.orders,
    required this.optimizeCountSql,
    required this.searchCount,
    required this.optimizeJoinOfCountSql,
    required this.maxLimit,
    required this.countId,
  });

  factory BusinessRecordPageData.fromJson(Map<String, dynamic> json) =>
      _$BusinessRecordPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessRecordPageDataToJson(this);

  @override
  List<Object> get props => [
        records,
        total,
        size,
        current,
        orders,
        optimizeCountSql,
        searchCount,
        optimizeJoinOfCountSql,
        maxLimit,
        countId,
      ];
}

@JsonSerializable()
class ProjectRecordPageData extends Equatable {
  final List<ProjectRecord> records;
  final int total;
  final int size;
  final int current;
  final List<OrderItem> orders;
  final bool optimizeCountSql;
  final bool searchCount;
  final bool optimizeJoinOfCountSql;
  final int maxLimit;
  final String countId;
  final int? pages;

  const ProjectRecordPageData({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
    required this.orders,
    required this.optimizeCountSql,
    required this.searchCount,
    required this.optimizeJoinOfCountSql,
    required this.maxLimit,
    required this.countId,
    this.pages,
  });

  factory ProjectRecordPageData.fromJson(Map<String, dynamic> json) =>
      _$ProjectRecordPageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectRecordPageDataToJson(this);

  @override
  List<Object?> get props => [
        records,
        total,
        size,
        current,
        orders,
        optimizeCountSql,
        searchCount,
        optimizeJoinOfCountSql,
        maxLimit,
        countId,
        pages,
      ];
}

@JsonSerializable()
class BusinessRecordListResponse extends Equatable {
  final int code;
  final String msg;
  final int tc;
  final BusinessRecordPageData data;

  const BusinessRecordListResponse({
    required this.code,
    required this.msg,
    required this.tc,
    required this.data,
  });

  factory BusinessRecordListResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessRecordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessRecordListResponseToJson(this);

  @override
  List<Object> get props => [code, msg, tc, data];

  bool get isSuccess => code == 0;
}

@JsonSerializable()
class ProjectRecordListResponse extends Equatable {
  final int code;
  final String msg;
  final int tc;
  final ProjectRecordPageData data;
  final bool? success;

  const ProjectRecordListResponse({
    required this.code,
    required this.msg,
    required this.tc,
    required this.data,
    this.success,
  });

  factory ProjectRecordListResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectRecordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectRecordListResponseToJson(this);

  @override
  List<Object?> get props => [code, msg, tc, data, success];

  bool get isSuccess => code == 0;
}