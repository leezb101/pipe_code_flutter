// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_todo_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageTodoTask _$PageTodoTaskFromJson(Map<String, dynamic> json) => PageTodoTask(
  records: (json['records'] as List<dynamic>)
      .map((e) => TodoTask.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  current: (json['current'] as num).toInt(),
);

Map<String, dynamic> _$PageTodoTaskToJson(PageTodoTask instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
      'size': instance.size,
      'current': instance.current,
    };
