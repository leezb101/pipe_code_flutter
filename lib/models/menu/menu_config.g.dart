// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['id'] as String,
  title: json['title'] as String,
  type: $enumDecode(_$MenuItemTypeEnumMap, json['type']),
  icon: json['icon'] as String?,
  route: json['route'] as String?,
  action: json['action'] as String?,
  description: json['description'] as String?,
  badge: json['badge'] as String?,
  isEnabled: json['is_enabled'] as bool? ?? true,
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': _$MenuItemTypeEnumMap[instance.type]!,
  'icon': instance.icon,
  'route': instance.route,
  'action': instance.action,
  'description': instance.description,
  'badge': instance.badge,
  'is_enabled': instance.isEnabled,
  'children': instance.children,
  'order': instance.order,
};

const _$MenuItemTypeEnumMap = {
  MenuItemType.action: 'action',
  MenuItemType.page: 'page',
  MenuItemType.group: 'group',
  MenuItemType.divider: 'divider',
};

RoleMenuConfig _$RoleMenuConfigFromJson(Map<String, dynamic> json) =>
    RoleMenuConfig(
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      menuItems: (json['menu_items'] as List<dynamic>)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$RoleMenuConfigToJson(RoleMenuConfig instance) =>
    <String, dynamic>{
      'role': _$UserRoleEnumMap[instance.role]!,
      'menu_items': instance.menuItems,
      'is_default': instance.isDefault,
    };

const _$UserRoleEnumMap = {
  UserRole.suppliers: 'suppliers',
  UserRole.construction: 'construction',
  UserRole.supervisor: 'supervisor',
  UserRole.builder: 'builder',
  UserRole.check: 'check',
  UserRole.builderSub: 'builder_sub',
  UserRole.laborer: 'laborer',
  UserRole.playgoer: 'playgoer',
};
