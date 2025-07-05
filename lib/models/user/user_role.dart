/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:40:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 17:40:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import 'package:pipe_code_flutter/constants/menu_actions.dart';
import '../menu/menu_config.dart';

/// 用户角色枚举
/// 定义用户在项目中可能拥有的不同角色类型
@JsonEnum()
enum UserRole {
  @JsonValue(0)
  suppliers(0, "供应商"),

  @JsonValue(1)
  construction(1, "建设单位"),

  @JsonValue(2)
  supervisor(2, "监理单位"),

  @JsonValue(3)
  builder(3, "施工单位"),

  @JsonValue(4)
  check(4, "质检部门"),

  @JsonValue(5)
  builderSub(5, "施工单位二级负责人"),

  @JsonValue(6)
  laborer(6, "劳务人员(允许代理收获和代理验收)"),

  @JsonValue(7)
  playgoer(7, "热心群众,无组织,游客");

  const UserRole(this.value, this.displayName);

  /// 角色的数值标识
  final int value;

  /// 角色的显示名称
  final String displayName;

  /// 从数值获取角色
  static UserRole fromValue(int value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.playgoer,
    );
  }

  /// 获取角色的权限级别（数值越小权限越高）
  int get authorityLevel => value;

  /// 判断是否是管理类角色
  bool get isManagementRole {
    switch (this) {
      case UserRole.construction:
      case UserRole.supervisor:
      case UserRole.check:
        return true;
      default:
        return false;
    }
  }

  /// 判断是否是施工类角色
  bool get isConstructionRole {
    switch (this) {
      case UserRole.builder:
      case UserRole.builderSub:
      case UserRole.laborer:
        return true;
      default:
        return false;
    }
  }

  /// 判断是否允许代理操作
  bool get canDelegate {
    switch (this) {
      case UserRole.laborer:
        return true;
      default:
        return false;
    }
  }

  /// 判断是否有质检权限
  bool get hasQualityCheckPermission {
    switch (this) {
      case UserRole.check:
      case UserRole.supervisor:
        return true;
      default:
        return false;
    }
  }
}

/// UserRole的菜单权限扩展
/// 根据角色直接获取对应的完整菜单项，无需关联其他模型
extension UserRoleMenuPermissions on UserRole {
  /// 获取角色对应的菜单项列表，包含完整的业务信息
  List<MenuItem> get menuItems {
    switch (this) {
      case UserRole.construction:
        return [
          const MenuItem(
            id: 'project_create',
            title: '立项',
            type: MenuItemType.page,
            icon: 'add_business',
            route: '/project-create',
            order: 1,
          ),
          const MenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.action,
            icon: 'inventory',
            action: 'inventory',
            route: '/inventory',
            order: 2,
          ),
          const MenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 3,
          ),
          const MenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
          ),
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 5,
          ),
        ];

      case UserRole.supervisor:
        return [
          const MenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 1,
          ),
          const MenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 2,
          ),
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 3,
          ),
        ];

      case UserRole.builder:
        return [
          const MenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: '/spare-code',
            order: 1,
          ),
          const MenuItem(
            id: 'inbound',
            title: '入库',
            type: MenuItemType.page,
            icon: 'input',
            route: '/inbound',
            order: 2,
          ),
          const MenuItem(
            id: 'outbound',
            title: '出库',
            type: MenuItemType.page,
            icon: 'output',
            route: '/outbound',
            order: 3,
          ),
          const MenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
          ),
          const MenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 5,
          ),
          const MenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: '/cut-pipe',
            order: 6,
          ),
          const MenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.page,
            icon: 'delete_forever',
            route: '/scrap',
            order: 7,
          ),
          const MenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 8,
          ),
          const MenuItem(
            id: 'temporary_auth',
            title: '临时授权',
            type: MenuItemType.page,
            icon: 'admin_panel_settings',
            route: '/temporary-auth',
            order: 9,
          ),
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 10,
          ),
        ];

      case UserRole.builderSub:
        return [
          const MenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: '/spare-code',
            order: 1,
          ),
          const MenuItem(
            id: 'inbound',
            title: '入库',
            type: MenuItemType.page,
            icon: 'input',
            route: '/inbound',
            order: 2,
          ),
          const MenuItem(
            id: 'outbound',
            title: '出库',
            type: MenuItemType.page,
            icon: 'output',
            route: '/outbound',
            order: 3,
          ),
          const MenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
          ),
          const MenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 5,
          ),
          const MenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: '/cut-pipe',
            order: 6,
          ),
          const MenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.page,
            icon: 'delete_forever',
            route: '/scrap',
            order: 7,
          ),
          const MenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 8,
          ),
          const MenuItem(
            id: 'temporary_auth',
            title: '临时授权',
            type: MenuItemType.page,
            icon: 'admin_panel_settings',
            route: '/temporary-auth',
            order: 9,
          ),
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 10,
          ),
        ];

      case UserRole.laborer:
        return [
          const MenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: '/spare-code',
            order: 1,
          ),
          const MenuItem(
            id: 'inbound',
            title: '入库',
            type: MenuItemType.action,
            icon: 'input',
            action: MenuActions.qrScanInbound,
            order: 2,
          ),
          const MenuItem(
            id: 'outbound',
            title: '出库',
            type: MenuItemType.page,
            icon: 'output',
            route: '/outbound',
            order: 3,
          ),
          const MenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
          ),
          const MenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 5,
          ),
          const MenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: '/cut-pipe',
            order: 6,
          ),
          const MenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.page,
            icon: 'delete_forever',
            route: '/scrap',
            order: 7,
          ),
          const MenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 8,
          ),
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 9,
          ),
        ];

      case UserRole.playgoer:
        return [
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 1,
          ),
        ];

      case UserRole.suppliers:
        return [
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 1,
          ),
        ];

      case UserRole.check:
        return [
          const MenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 1,
          ),
        ];
    }
  }

  /// 检查是否有指定菜单项
  bool hasMenuItem(String menuId) {
    return menuItems.any((item) => item.id == menuId);
  }

  /// 根据ID获取菜单项
  MenuItem? getMenuItemById(String menuId) {
    try {
      return menuItems.firstWhere((item) => item.id == menuId);
    } catch (e) {
      return null;
    }
  }

  /// 获取启用的菜单项
  List<MenuItem> get enabledMenuItems {
    return menuItems.where((item) => item.isEnabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取页面类型的菜单项
  List<MenuItem> get pageMenuItems {
    return menuItems.where((item) => item.type == MenuItemType.page).toList();
  }

  /// 获取操作类型的菜单项
  List<MenuItem> get actionMenuItems {
    return menuItems.where((item) => item.type == MenuItemType.action).toList();
  }

  /// 获取角色的核心业务权限描述
  String get permissionDescription {
    switch (this) {
      case UserRole.construction:
        return '建设单位：项目立项、库存管理(盘点/调拨/退库)、扫码识别';

      case UserRole.supervisor:
        return '监理单位：库存管理(盘点/退库)、扫码识别';

      case UserRole.builder:
        return '施工单位：全库存管理、施工操作(备用码/截管/报废)、临时授权、扫码识别';

      case UserRole.builderSub:
        return '施工单位二级负责人：全库存管理、施工操作(备用码/截管/报废)、临时授权、扫码识别';

      case UserRole.laborer:
        return '劳务人员：库存管理、施工操作(备用码/截管/报废，除临时授权)、扫码识别';

      case UserRole.playgoer:
        return '热心群众：扫码识别';

      case UserRole.suppliers:
        return '供应商：扫码识别';

      case UserRole.check:
        return '质检部门：扫码识别';
    }
  }
}
