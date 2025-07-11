/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:48:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 21:34:29
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../user/user_role.dart';

part 'menu_config.g.dart';

/// 菜单项类型枚举
@JsonEnum()
enum MenuItemType {
  @JsonValue('action')
  action('action', "操作菜单"),

  @JsonValue('page')
  page('page', "页面菜单"),

  @JsonValue('group')
  group('group', "菜单组"),

  @JsonValue('divider')
  divider('divider', "分隔符");

  const MenuItemType(this.value, this.displayName);

  final String value;
  final String displayName;
}

/// 菜单项模型
@JsonSerializable()
class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.title,
    required this.type,
    this.icon,
    this.route,
    this.action,
    this.description,
    this.badge,
    this.isEnabled = true,
    this.children,
    this.order = 0,
  });

  /// 菜单项唯一标识
  final String id;

  /// 菜单标题
  final String title;

  /// 菜单类型
  final MenuItemType type;

  /// 菜单图标
  final String? icon;

  /// 路由地址（用于页面菜单）
  final String? route;

  /// 操作标识（用于操作菜单）
  final String? action;

  /// 菜单描述
  final String? description;

  /// 徽章文本
  final String? badge;

  /// 是否启用
  @JsonKey(name: 'is_enabled')
  final bool isEnabled;

  /// 子菜单项
  final List<MenuItem>? children;

  /// 排序权重
  final int order;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  MenuItem copyWith({
    String? id,
    String? title,
    MenuItemType? type,
    String? icon,
    String? route,
    String? action,
    String? description,
    String? badge,
    bool? isEnabled,
    List<MenuItem>? children,
    int? order,
  }) {
    return MenuItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      action: action ?? this.action,
      description: description ?? this.description,
      badge: badge ?? this.badge,
      isEnabled: isEnabled ?? this.isEnabled,
      children: children ?? this.children,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    icon,
    route,
    action,
    description,
    badge,
    isEnabled,
    children,
    order,
  ];

  /// 判断是否有子菜单
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// 判断是否是页面菜单
  bool get isPageMenu => type == MenuItemType.page;

  /// 判断是否是操作菜单
  bool get isActionMenu => type == MenuItemType.action;
}

/// 角色菜单配置
@JsonSerializable()
class RoleMenuConfig extends Equatable {
  const RoleMenuConfig({
    required this.role,
    required this.menuItems,
    this.isDefault = false,
  });

  /// 角色类型
  final UserRole role;

  /// 该角色可访问的菜单项列表
  @JsonKey(name: 'menu_items')
  final List<MenuItem> menuItems;

  /// 是否是默认配置
  @JsonKey(name: 'is_default')
  final bool isDefault;

  factory RoleMenuConfig.fromJson(Map<String, dynamic> json) =>
      _$RoleMenuConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RoleMenuConfigToJson(this);

  RoleMenuConfig copyWith({
    UserRole? role,
    List<MenuItem>? menuItems,
    bool? isDefault,
  }) {
    return RoleMenuConfig(
      role: role ?? this.role,
      menuItems: menuItems ?? this.menuItems,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [role, menuItems, isDefault];

  /// 获取启用的菜单项
  List<MenuItem> get enabledMenuItems {
    return menuItems.where((item) => item.isEnabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 根据ID查找菜单项
  MenuItem? findMenuItemById(String id) {
    MenuItem? findInList(List<MenuItem> items) {
      for (final item in items) {
        if (item.id == id) return item;
        if (item.hasChildren) {
          final found = findInList(item.children!);
          if (found != null) return found;
        }
      }
      return null;
    }

    return findInList(menuItems);
  }

  /// 检查是否有指定的菜单权限
  bool hasMenuPermission(String menuId) {
    return findMenuItemById(menuId) != null;
  }
}
