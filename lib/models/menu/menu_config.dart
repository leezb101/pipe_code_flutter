/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:48:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-02 11:32:35
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

/// 菜单配置管理器
class MenuConfigManager {
  static final MenuConfigManager _instance = MenuConfigManager._internal();
  factory MenuConfigManager() => _instance;
  MenuConfigManager._internal();

  /// 所有角色的菜单配置
  static final Map<UserRole, RoleMenuConfig> _roleMenuConfigs = {
    UserRole.suppliers: _getSuppliersMenuConfig(),
    UserRole.construction: _getConstructionMenuConfig(),
    UserRole.supervisor: _getSupervisorMenuConfig(),
    UserRole.builder: _getBuilderMenuConfig(),
    UserRole.check: _getCheckMenuConfig(),
    UserRole.builderSub: _getBuilderSubMenuConfig(),
    UserRole.laborer: _getLaborerMenuConfig(),
    UserRole.playgoer: _getPlaygoerMenuConfig(),
  };

  /// 获取指定角色的菜单配置
  RoleMenuConfig? getMenuConfigForRole(UserRole role) {
    return _roleMenuConfigs[role];
  }

  /// 获取所有角色的菜单配置
  Map<UserRole, RoleMenuConfig> getAllMenuConfigs() {
    return Map.from(_roleMenuConfigs);
  }

  /// 供应商菜单配置
  static RoleMenuConfig _getSuppliersMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.suppliers,
      menuItems: [
        const MenuItem(
          id: 'product_management',
          title: '产品管理',
          type: MenuItemType.page,
          icon: 'inventory',
          route: '/products',
          order: 1,
        ),
        const MenuItem(
          id: 'order_management',
          title: '订单管理',
          type: MenuItemType.page,
          icon: 'assignment',
          route: '/orders',
          order: 2,
        ),
        const MenuItem(
          id: 'delivery_tracking',
          title: '发货跟踪',
          type: MenuItemType.page,
          icon: 'local_shipping',
          route: '/delivery',
          order: 3,
        ),
      ],
    );
  }

  /// 建设单位菜单配置
  static RoleMenuConfig _getConstructionMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.construction,
      menuItems: [
        const MenuItem(
          id: 'project_overview',
          title: '项目总览',
          type: MenuItemType.page,
          icon: 'dashboard',
          route: '/dashboard',
          order: 1,
        ),
        const MenuItem(
          id: 'contract_management',
          title: '合同管理',
          type: MenuItemType.page,
          icon: 'description',
          route: '/contracts',
          order: 2,
        ),
        const MenuItem(
          id: 'progress_monitoring',
          title: '进度监控',
          type: MenuItemType.page,
          icon: 'timeline',
          route: '/progress',
          order: 3,
        ),
        const MenuItem(
          id: 'quality_control',
          title: '质量控制',
          type: MenuItemType.page,
          icon: 'verified',
          route: '/quality',
          order: 4,
        ),
      ],
    );
  }

  /// 监理单位菜单配置
  static RoleMenuConfig _getSupervisorMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.supervisor,
      menuItems: [
        const MenuItem(
          id: 'inspection_tasks',
          title: '巡检任务',
          type: MenuItemType.page,
          icon: 'search',
          route: '/inspection',
          order: 1,
        ),
        const MenuItem(
          id: 'quality_reports',
          title: '质量报告',
          type: MenuItemType.page,
          icon: 'assessment',
          route: '/reports',
          order: 2,
        ),
        const MenuItem(
          id: 'acceptance_management',
          title: '验收管理',
          type: MenuItemType.page,
          icon: 'check_circle',
          route: '/acceptance',
          order: 3,
        ),
      ],
    );
  }

  /// 施工单位菜单配置
  static RoleMenuConfig _getBuilderMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.builder,
      menuItems: [
        const MenuItem(
          id: 'construction_tasks',
          title: '施工任务',
          type: MenuItemType.page,
          icon: 'build',
          route: '/construction',
          order: 1,
        ),
        const MenuItem(
          id: 'material_management',
          title: '材料管理',
          type: MenuItemType.page,
          icon: 'inventory_2',
          route: '/materials',
          order: 2,
        ),
        const MenuItem(
          id: 'safety_records',
          title: '安全记录',
          type: MenuItemType.page,
          icon: 'security',
          route: '/safety',
          order: 3,
        ),
        const MenuItem(
          id: 'qr_operations',
          title: 'QR操作',
          type: MenuItemType.group,
          icon: 'qr_code',
          order: 4,
          children: [
            MenuItem(
              id: 'qr_scan_inbound',
              title: 'QR入库扫码',
              type: MenuItemType.action,
              action: 'qr_scan_inbound',
              order: 1,
            ),
            MenuItem(
              id: 'qr_scan_outbound',
              title: 'QR出库扫码',
              type: MenuItemType.action,
              action: 'qr_scan_outbound',
              order: 2,
            ),
            MenuItem(
              id: 'qr_scan_transfer',
              title: 'QR调拨扫码',
              type: MenuItemType.action,
              action: 'qr_scan_transfer',
              order: 3,
            ),
            MenuItem(
              id: 'qr_scan_inventory',
              title: 'QR盘点扫码',
              type: MenuItemType.action,
              action: 'qr_scan_inventory',
              order: 4,
            ),
            MenuItem(
              id: 'qr_scan_pipe_copy',
              title: 'QR截管复制',
              type: MenuItemType.action,
              action: 'qr_scan_pipe_copy',
              order: 5,
            ),
          ],
        ),
      ],
    );
  }

  /// 质检部门菜单配置
  static RoleMenuConfig _getCheckMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.check,
      menuItems: [
        const MenuItem(
          id: 'quality_inspection',
          title: '质量检查',
          type: MenuItemType.page,
          icon: 'fact_check',
          route: '/quality-check',
          order: 1,
        ),
        const MenuItem(
          id: 'test_reports',
          title: '检测报告',
          type: MenuItemType.page,
          icon: 'lab_profile',
          route: '/test-reports',
          order: 2,
        ),
      ],
    );
  }

  /// 施工单位二级负责人菜单配置
  static RoleMenuConfig _getBuilderSubMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.builderSub,
      menuItems: [
        const MenuItem(
          id: 'sub_tasks',
          title: '分配任务',
          type: MenuItemType.page,
          icon: 'assignment_ind',
          route: '/sub-tasks',
          order: 1,
        ),
        const MenuItem(
          id: 'team_management',
          title: '团队管理',
          type: MenuItemType.page,
          icon: 'groups',
          route: '/team',
          order: 2,
        ),
      ],
    );
  }

  /// 劳务人员菜单配置
  static RoleMenuConfig _getLaborerMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.laborer,
      menuItems: [
        const MenuItem(
          id: 'work_tasks',
          title: '工作任务',
          type: MenuItemType.page,
          icon: 'work',
          route: '/work-tasks',
          order: 1,
        ),
        const MenuItem(
          id: 'delegate_operations',
          title: '代理操作',
          type: MenuItemType.group,
          icon: 'support_agent',
          order: 2,
          children: [
            MenuItem(
              id: 'delegate_harvest',
              title: '代理收获',
              type: MenuItemType.action,
              action: 'delegate_harvest',
              order: 1,
            ),
            MenuItem(
              id: 'delegate_accept',
              title: '代理验收',
              type: MenuItemType.action,
              action: 'delegate_accept',
              order: 2,
            ),
          ],
        ),
      ],
    );
  }

  /// 热心群众菜单配置
  static RoleMenuConfig _getPlaygoerMenuConfig() {
    return RoleMenuConfig(
      role: UserRole.playgoer,
      menuItems: [
        const MenuItem(
          id: 'basic_info',
          title: '基本信息',
          type: MenuItemType.page,
          icon: 'info',
          route: '/info',
          order: 1,
        ),
        const MenuItem(
          id: 'feedback',
          title: '意见反馈',
          type: MenuItemType.page,
          icon: 'feedback',
          route: '/feedback',
          order: 2,
        ),
      ],
    );
  }
}
