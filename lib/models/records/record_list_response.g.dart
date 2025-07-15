// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessRecordPageData _$BusinessRecordPageDataFromJson(
  Map<String, dynamic> json,
) => BusinessRecordPageData(
  records: (json['records'] as List<dynamic>)
      .map((e) => BusinessRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  current: (json['current'] as num).toInt(),
);

Map<String, dynamic> _$BusinessRecordPageDataToJson(
  BusinessRecordPageData instance,
) => <String, dynamic>{
  'records': instance.records,
  'total': instance.total,
  'size': instance.size,
  'current': instance.current,
};

ProjectRecordPageData _$ProjectRecordPageDataFromJson(
  Map<String, dynamic> json,
) => ProjectRecordPageData(
  records: (json['records'] as List<dynamic>)
      .map((e) => ProjectRecord.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  current: (json['current'] as num).toInt(),
  pages: (json['pages'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProjectRecordPageDataToJson(
  ProjectRecordPageData instance,
) => <String, dynamic>{
  'records': instance.records,
  'total': instance.total,
  'size': instance.size,
  'current': instance.current,
  'pages': instance.pages,
};

BusinessRecordListResponse _$BusinessRecordListResponseFromJson(
  Map<String, dynamic> json,
) => BusinessRecordListResponse(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String,
  data: BusinessRecordPageData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BusinessRecordListResponseToJson(
  BusinessRecordListResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'data': instance.data,
};

ProjectRecordListResponse _$ProjectRecordListResponseFromJson(
  Map<String, dynamic> json,
) => ProjectRecordListResponse(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String,
  data: ProjectRecordPageData.fromJson(json['data'] as Map<String, dynamic>),
  success: json['success'] as bool?,
);

Map<String, dynamic> _$ProjectRecordListResponseToJson(
  ProjectRecordListResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'data': instance.data,
  'success': instance.success,
};
