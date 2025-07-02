/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:42:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 17:42:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'project.g.dart';

/// 项目状态枚举
@JsonEnum()
enum ProjectStatus {
  @JsonValue(0)
  planning(0, "规划中"),
  
  @JsonValue(1)
  inProgress(1, "进行中"),
  
  @JsonValue(2)
  completed(2, "已完成"),
  
  @JsonValue(3)
  suspended(3, "已暂停"),
  
  @JsonValue(4)
  cancelled(4, "已取消");

  const ProjectStatus(this.value, this.displayName);

  final int value;
  final String displayName;

  static ProjectStatus fromValue(int value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProjectStatus.planning,
    );
  }
}

/// 项目模型
/// 定义水务管理项目的基本信息
@JsonSerializable()
class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.location,
    this.startDate,
    this.endDate,
    this.budget,
    this.contactPerson,
    this.contactPhone,
    this.remarks,
  });

  /// 项目唯一标识
  final String id;
  
  /// 项目名称
  final String name;
  
  /// 项目描述
  final String description;
  
  /// 项目状态
  final ProjectStatus status;
  
  /// 项目位置/地址
  final String? location;
  
  /// 项目开始日期
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  
  /// 项目结束日期
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  
  /// 项目预算
  final double? budget;
  
  /// 联系人
  @JsonKey(name: 'contact_person')
  final String? contactPerson;
  
  /// 联系电话
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  
  /// 创建时间
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  /// 备注信息
  final String? remarks;

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? contactPerson,
    String? contactPhone,
    DateTime? createdAt,
    String? remarks,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      remarks: remarks ?? this.remarks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    location,
    startDate,
    endDate,
    budget,
    contactPerson,
    contactPhone,
    createdAt,
    remarks,
  ];

  /// 判断项目是否处于活跃状态
  bool get isActive {
    return status == ProjectStatus.inProgress || status == ProjectStatus.planning;
  }

  /// 判断项目是否已结束
  bool get isFinished {
    return status == ProjectStatus.completed || 
           status == ProjectStatus.cancelled;
  }

  /// 获取项目进度百分比（简单实现，实际可能需要更复杂的计算）
  double get progressPercentage {
    if (startDate == null || endDate == null) return 0.0;
    
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return 0.0;
    if (now.isAfter(endDate!)) return 100.0;
    
    final totalDuration = endDate!.difference(startDate!).inDays;
    final elapsedDuration = now.difference(startDate!).inDays;
    
    return (elapsedDuration / totalDuration * 100).clamp(0.0, 100.0);
  }
}