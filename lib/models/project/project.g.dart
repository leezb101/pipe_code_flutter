// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$ProjectStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  location: json['location'] as String?,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  budget: (json['budget'] as num?)?.toDouble(),
  contactPerson: json['contact_person'] as String?,
  contactPhone: json['contact_phone'] as String?,
  remarks: json['remarks'] as String?,
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'status': _$ProjectStatusEnumMap[instance.status]!,
  'location': instance.location,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'budget': instance.budget,
  'contact_person': instance.contactPerson,
  'contact_phone': instance.contactPhone,
  'created_at': instance.createdAt.toIso8601String(),
  'remarks': instance.remarks,
};

const _$ProjectStatusEnumMap = {
  ProjectStatus.planning: 0,
  ProjectStatus.inProgress: 1,
  ProjectStatus.completed: 2,
  ProjectStatus.suspended: 3,
  ProjectStatus.cancelled: 4,
};
