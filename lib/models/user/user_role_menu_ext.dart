/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-09 22:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/constants/menu_actions.dart';
import '../menu/menu_config.dart';
import 'user_role.dart';

/// UserRole的菜单权限扩展
/// 根据角色直接获取对应的完整菜单项，支持过期状态处理
extension UserRoleMenuExtension on UserRole {
  /// 获取角色对应的菜单项列表，支持过期状态
  /// [isExpired] 如果为true，除了扫码识别外的菜单项都会被禁用
  List<MenuItem> getMenuItemsWithExpireState(bool isExpired) {
    switch (this) {
      case UserRole.construction:
        return [
          _createMenuItem(
            id: 'project_initiation',
            title: '立项',
            type: MenuItemType.page,
            icon: 'add_business',
            route: '/project-initiation',
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.action,
            icon: 'inventory',
            action: 'inventory',
            route: '/inventory',
            order: 2,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 5,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];

      case UserRole.supervisor:
        return [
          _createMenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 2,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 3,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];

      case UserRole.builder:
        return [
          _createMenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: '/spare-code',
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inbound',
            title: '入库',
            type: MenuItemType.page,
            icon: 'input',
            route: '/inbound',
            order: 2,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'outbound',
            title: '出库',
            type: MenuItemType.page,
            icon: 'output',
            route: '/outbound',
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 5,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: '/cut-pipe',
            order: 6,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.page,
            icon: 'delete_forever',
            route: '/scrap',
            order: 7,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 8,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'temporary_auth',
            title: '临时授权',
            type: MenuItemType.page,
            icon: 'admin_panel_settings',
            route: '/temporary-auth',
            order: 9,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 10,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];

      case UserRole.builderSub:
        return [
          _createMenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: '/spare-code',
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inbound',
            title: '入库',
            type: MenuItemType.page,
            icon: 'input',
            route: '/inbound',
            order: 2,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'outbound',
            title: '出库',
            type: MenuItemType.page,
            icon: 'output',
            route: '/outbound',
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 5,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: '/cut-pipe',
            order: 6,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.page,
            icon: 'delete_forever',
            route: '/scrap',
            order: 7,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 8,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'temporary_auth',
            title: '临时授权',
            type: MenuItemType.page,
            icon: 'admin_panel_settings',
            route: '/temporary-auth',
            order: 9,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 10,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];

      case UserRole.laborer:
        return [
          _createMenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: '/spare-code',
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inbound',
            title: '入库',
            type: MenuItemType.action,
            icon: 'input',
            action: MenuActions.qrScanInbound,
            order: 2,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'outbound',
            title: '出库',
            type: MenuItemType.page,
            icon: 'output',
            route: '/outbound',
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.page,
            icon: 'keyboard_return',
            route: '/return',
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            type: MenuItemType.page,
            icon: 'swap_horiz',
            route: '/transfer',
            order: 5,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: '/cut-pipe',
            order: 6,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.page,
            icon: 'delete_forever',
            route: '/scrap',
            order: 7,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 8,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 9,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];

      case UserRole.playgoer:
      case UserRole.suppliers:
      case UserRole.check:
        return [
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 1,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];
    }
  }

  /// 创建菜单项的辅助方法
  MenuItem _createMenuItem({
    required String id,
    required String title,
    required MenuItemType type,
    required String icon,
    required int order,
    required bool isEnabled,
    String? route,
    String? action,
  }) {
    return MenuItem(
      id: id,
      title: title,
      type: type,
      icon: icon,
      route: route,
      action: action,
      order: order,
      isEnabled: isEnabled,
    );
  }

  /// 检查是否有指定菜单项
  bool hasMenuItem(String menuId) {
    return getMenuItemsWithExpireState(false).any((item) => item.id == menuId);
  }

  /// 根据ID获取菜单项
  MenuItem? getMenuItemById(String menuId, {bool isExpired = false}) {
    try {
      return getMenuItemsWithExpireState(isExpired).firstWhere((item) => item.id == menuId);
    } catch (e) {
      return null;
    }
  }

  /// 获取启用的菜单项
  List<MenuItem> getEnabledMenuItems({bool isExpired = false}) {
    return getMenuItemsWithExpireState(isExpired)
        .where((item) => item.isEnabled)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取页面类型的菜单项
  List<MenuItem> getPageMenuItems({bool isExpired = false}) {
    return getMenuItemsWithExpireState(isExpired)
        .where((item) => item.type == MenuItemType.page)
        .toList();
  }

  /// 获取操作类型的菜单项
  List<MenuItem> getActionMenuItems({bool isExpired = false}) {
    return getMenuItemsWithExpireState(isExpired)
        .where((item) => item.type == MenuItemType.action)
        .toList();
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