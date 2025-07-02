// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_project_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProjectRole _$UserProjectRoleFromJson(Map<String, dynamic> json) =>
    UserProjectRole(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      assignedBy: json['assigned_by'] as String?,
      validFrom: json['valid_from'] == null
          ? null
          : DateTime.parse(json['valid_from'] as String),
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.parse(json['valid_until'] as String),
      isActive: json['is_active'] as bool? ?? true,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      project: json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProjectRoleToJson(UserProjectRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'project_id': instance.projectId,
      'role': _$UserRoleEnumMap[instance.role]!,
      'assigned_at': instance.assignedAt.toIso8601String(),
      'assigned_by': instance.assignedBy,
      'valid_from': instance.validFrom?.toIso8601String(),
      'valid_until': instance.validUntil?.toIso8601String(),
      'is_active': instance.isActive,
      'user': instance.user,
      'project': instance.project,
    };

const _$UserRoleEnumMap = {
  UserRole.suppliers: 0,
  UserRole.construction: 1,
  UserRole.supervisor: 2,
  UserRole.builder: 3,
  UserRole.check: 4,
  UserRole.builderSub: 5,
  UserRole.laborer: 6,
  UserRole.playgoer: 7,
};

UserProjectContext _$UserProjectContextFromJson(Map<String, dynamic> json) =>
    UserProjectContext(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      currentProject: Project.fromJson(
        json['currentProject'] as Map<String, dynamic>,
      ),
      currentRole: UserProjectRole.fromJson(
        json['currentRole'] as Map<String, dynamic>,
      ),
      allProjectRoles: (json['allProjectRoles'] as List<dynamic>)
          .map((e) => UserProjectRole.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserProjectContextToJson(UserProjectContext instance) =>
    <String, dynamic>{
      'user': instance.user,
      'currentProject': instance.currentProject,
      'currentRole': instance.currentRole,
      'allProjectRoles': instance.allProjectRoles,
    };
