import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'todo_task.dart';

part 'page_todo_task.g.dart';

@JsonSerializable()
class PageTodoTask extends Equatable {
  const PageTodoTask({
    required this.records,
    required this.total,
    required this.size,
    required this.current,
  });

  @JsonKey(name: 'records')
  final List<TodoTask> records;
  
  @JsonKey(name: 'total')
  final int total;
  
  @JsonKey(name: 'size')
  final int size;
  
  @JsonKey(name: 'current')
  final int current;

  factory PageTodoTask.fromJson(Map<String, dynamic> json) => _$PageTodoTaskFromJson(json);
  
  Map<String, dynamic> toJson() => _$PageTodoTaskToJson(this);

  @override
  List<Object?> get props => [records, total, size, current];
}