/*
 * @Author: LeeZB
 * @Date: 2025-07-09 22:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-03 11:59:27
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:pipe_code_flutter/constants/menu_actions.dart';
import '../menu/menu_config.dart';
import 'user_role.dart';
import 'current_user_on_project_role_info.dart';

/// UserRole的菜单权限扩展
/// 根据角色直接获取对应的完整菜单项，支持过期状态处理
extension UserRoleMenuExtension on UserRole {
  /// 获取角色对应的菜单项列表，支持过期状态和供材类型
  /// [isExpired] 如果为true，除了扫码识别外的菜单项都会被禁用
  /// [supplyType] 项目供材类型，用于控制验收菜单的启用状态
  List<MenuItem> getMenuItemsWithExpireState(
    bool isExpired, {
    ProjectSupplyType? supplyType,
  }) {
    switch (this) {
      case UserRole.construction:
        return [
          _createMenuItem(
            id: 'project_initiation',
            title: '立项',
            type: MenuItemType.page,
            icon: 'add_business',
            route: 'project-initiation',
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'acceptance',
            title: '验收',
            type: MenuItemType.action,
            icon: 'check_circle',
            action: MenuActions.qrScanJsfAcceptance,
            order: 2,
            isEnabled:
                !isExpired &&
                (supplyType == null ||
                    _isAcceptanceEnabledForSupplyType(supplyType)),
          ),
          // _createMenuItem(
          //   id: 'inventory',
          //   title: '盘点',
          //   type: MenuItemType.action,
          //   icon: 'inventory',
          //   action: 'inventory',
          //   route: '/inventory',
          //   order: 2,
          //   isEnabled: !isExpired,
          // ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'swap_horiz',
            // route: '/transfer',
            action: MenuActions.qrScanTransfer,
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'keyboard_return',
            // route: '/return',
            action: MenuActions.qrScanReturnMaterial,
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 0,
            topMain: true,
            isEnabled: true, // 扫码识别始终可用
          ),
          _createMenuItem(
            id: 'recovery',
            title: '异常码找回',
            type: MenuItemType.page,
            icon: 'recovery',
            route: 'recovery',
            order: 6,
            isEnabled: true,
          ),
        ];

      case UserRole.supervisor:
        return [
          // _createMenuItem(
          //   id: 'inventory',
          //   title: '盘点',
          //   type: MenuItemType.page,
          //   icon: 'inventory',
          //   route: '/inventory',
          //   order: 1,
          //   isEnabled: !isExpired,
          // ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.action,
            icon: 'keyboard_return',
            action: MenuActions.qrScanReturnMaterial,
            order: 1,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'recovery',
            title: '异常码找回',
            type: MenuItemType.page,
            icon: 'recovery',
            route: 'recovery',
            order: 2,
            isEnabled: true,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 0,
            topMain: true,
            isEnabled: true, // 扫码识别始终可用
          ),
        ];

      case UserRole.builder:
        return [
          _createMenuItem(
            id: 'acceptance',
            title: '验收',
            type: MenuItemType.action,
            icon: 'check_circle',
            action: MenuActions.qrScanAcceptance,
            order: 1,
            isEnabled:
                !isExpired &&
                (supplyType == null ||
                    _isAcceptanceEnabledForSupplyType(supplyType)),
          ),
          _createMenuItem(
            id: 'signout',
            title: '出库',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'output',
            // route: '/signout',
            action: MenuActions.qrScanSignout,
            order: 2,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'install',
            title: '安装',
            type: MenuItemType.page,
            icon: 'build',
            route: 'install',
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'swap_horiz',
            // route: '/transfer',
            action: MenuActions.qrScanTransfer,
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: 'cut-pipe',
            order: 5,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'inventory',
            title: '盘点',
            type: MenuItemType.page,
            icon: 'inventory',
            route: '/inventory',
            order: 6,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.action,
            icon: 'keyboard_return',
            action: MenuActions.qrScanReturnMaterial,
            order: 7,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'scrap',
            title: '报废',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'delete_forever',
            // route: '/scrap',
            action: MenuActions.qrScanScrap,
            order: 8,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: 'spare-qr',
            order: 9,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'recovery',
            title: '异常码找回',
            type: MenuItemType.page,
            icon: 'recovery',
            route: 'recovery',
            order: 10,
            isEnabled: true,
          ),
          _createMenuItem(
            id: 'temporary_auth',
            title: '授权他人',
            type: MenuItemType.page,
            icon: 'admin_panel_settings',
            route: 'temporary-auth',
            order: 11,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 0,
            isEnabled: true, // 扫码识别始终可用
            topMain: true,
          ),
        ];

      case UserRole.builderSub:
        return [
          _createMenuItem(
            id: 'spare_qr',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: 'spare-qr',
            order: 1,
            isEnabled: !isExpired,
          ),
          // 入库菜单暂时禁用
          // _createMenuItem(
          //   id: 'inbound',
          //   title: '入库',
          //   type: MenuItemType.action,
          //   icon: 'input',
          //   action: MenuActions.qrScanInbound,
          //   order: 2,
          //   isEnabled: !isExpired,
          // ),
          _createMenuItem(
            id: 'acceptance',
            title: '验收',
            type: MenuItemType.action,
            icon: 'check_circle',
            action: MenuActions.qrScanAcceptance,
            order: 2,
            isEnabled:
                !isExpired &&
                (supplyType == null ||
                    _isAcceptanceEnabledForSupplyType(supplyType)),
          ),
          _createMenuItem(
            id: 'signout',
            title: '出库',
            type: MenuItemType.action,
            icon: 'output',
            // route: '/signout',
            action: MenuActions.qrScanSignout,
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'install',
            title: '安装',
            type: MenuItemType.page,
            icon: 'build',
            route: 'install',
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.action,
            icon: 'keyboard_return',
            action: MenuActions.qrScanReturnMaterial,
            order: 5,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'swap_horiz',
            // route: '/transfer',
            action: MenuActions.qrScanTransfer,
            order: 6,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: 'cut-pipe',
            order: 7,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.action,
            icon: 'delete_forever',
            action: MenuActions.qrScanScrap,
            order: 8,
            isEnabled: !isExpired,
          ),
          // _createMenuItem(
          //   id: 'inventory',
          //   title: '盘点',
          //   type: MenuItemType.page,
          //   icon: 'inventory',
          //   route: '/inventory',
          //   order: 9,
          //   isEnabled: !isExpired,
          // ),
          _createMenuItem(
            id: 'recovery',
            title: '异常码找回',
            type: MenuItemType.page,
            icon: 'recovery',
            route: 'recovery',
            order: 9,
            isEnabled: true,
          ),
          _createMenuItem(
            id: 'temporary_auth',
            title: '授权他人',
            type: MenuItemType.page,
            icon: 'admin_panel_settings',
            route: 'temporary-auth',
            order: 10,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 0,
            isEnabled: true, // 扫码识别始终可用
            topMain: true,
          ),
        ];

      case UserRole.laborer:
        return [
          _createMenuItem(
            id: 'spare_code',
            title: '备用码',
            type: MenuItemType.page,
            icon: 'code',
            route: 'spare-qr',
            order: 1,
            isEnabled: !isExpired,
          ),
          // 入库菜单暂时禁用
          // _createMenuItem(
          //   id: 'inbound',
          //   title: '入库',
          //   type: MenuItemType.action,
          //   icon: 'input',
          //   action: MenuActions.qrScanInbound,
          //   order: 2,
          //   isEnabled: !isExpired,
          // ),
          _createMenuItem(
            id: 'acceptance',
            title: '验收',
            type: MenuItemType.action,
            icon: 'check_circle',
            action: MenuActions.qrScanAcceptance,
            order: 2,
            isEnabled:
                !isExpired &&
                (supplyType == null ||
                    _isAcceptanceEnabledForSupplyType(supplyType)),
          ),
          _createMenuItem(
            id: 'signout',
            title: '出库',
            type: MenuItemType.action,
            icon: 'output',
            // route: '/signout',
            action: MenuActions.qrScanSignout,
            order: 3,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'install',
            title: '安装',
            type: MenuItemType.page,
            icon: 'build',
            route: 'install',
            order: 4,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'return',
            title: '退库',
            type: MenuItemType.action,
            icon: 'keyboard_return',
            action: MenuActions.qrScanReturnMaterial,
            order: 5,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'transfer',
            title: '调拨',
            // type: MenuItemType.page,
            type: MenuItemType.action,
            icon: 'swap_horiz',
            // route: '/transfer',
            action: MenuActions.qrScanTransfer,
            order: 6,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'cut_pipe',
            title: '截管',
            type: MenuItemType.page,
            icon: 'content_cut',
            route: 'cut-pipe',
            order: 7,
            isEnabled: !isExpired,
          ),
          _createMenuItem(
            id: 'scrap',
            title: '报废',
            type: MenuItemType.action,
            icon: 'delete_forever',
            action: MenuActions.qrScanScrap,
            order: 8,
            isEnabled: !isExpired,
          ),
          // _createMenuItem(
          //   id: 'inventory',
          //   title: '盘点',
          //   type: MenuItemType.page,
          //   icon: 'inventory',
          //   route: '/inventory',
          //   order: 9,
          //   isEnabled: !isExpired,
          // ),
          _createMenuItem(
            id: 'recovery',
            title: '异常码找回',
            type: MenuItemType.page,
            icon: 'recovery',
            route: 'recovery',
            order: 9,
            isEnabled: true,
          ),
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 0,
            isEnabled: true, // 扫码识别始终可用
            topMain: true,
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
            order: 0,
            isEnabled: true, // 扫码识别始终可用
            topMain: true,
          ),
        ];
      case UserRole.storekeeper:
        return [
          _createMenuItem(
            id: 'qr_identify',
            title: '扫码识别',
            type: MenuItemType.action,
            icon: 'qr_code_scanner',
            action: 'qr_identify',
            order: 0,
            isEnabled: true, // 扫码识别始终可用
            topMain: true,
          ),
          _createMenuItem(
            id: 'recovery',
            title: '异常码找回',
            type: MenuItemType.page,
            icon: 'recovery',
            route: 'recovery',
            order: 2,
            isEnabled: true,
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
    bool? topMain,
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
      topMain: topMain ?? false,
    );
  }

  /// 根据项目供材类型和用户角色判断验收功能是否可用
  /// Rules:
  /// - 甲供材: 建设方验收可用，施工方验收不可用
  /// - 乙供材: 施工方验收可用，建设方验收不可用
  /// - 甲乙混供: 双方验收都可用
  bool _isAcceptanceEnabledForSupplyType(ProjectSupplyType supplyType) {
    switch (supplyType) {
      case ProjectSupplyType.jiaGongCai: // 甲供材
        return _isConstructionSide(); // 只有建设方可用
      case ProjectSupplyType.yiGongCai: // 乙供材
        return _isConstructionWorker(); // 只有施工方可用
      case ProjectSupplyType.jiaYiHunGong: // 甲乙混供
        return true; // 双方都可用
    }
  }

  /// 判断是否为建设方角色
  bool _isConstructionSide() {
    return this == UserRole.construction;
  }

  /// 判断是否为施工方角色（包括所有施工相关角色）
  bool _isConstructionWorker() {
    switch (this) {
      case UserRole.builder:
      case UserRole.builderSub:
      case UserRole.laborer:
        return true;
      default:
        return false;
    }
  }

  /// 检查是否有指定菜单项
  bool hasMenuItem(String menuId) {
    return getMenuItemsWithExpireState(false).any((item) => item.id == menuId);
  }

  /// 根据ID获取菜单项
  MenuItem? getMenuItemById(
    String menuId, {
    bool isExpired = false,
    ProjectSupplyType? supplyType,
  }) {
    try {
      return getMenuItemsWithExpireState(
        isExpired,
        supplyType: supplyType,
      ).firstWhere((item) => item.id == menuId);
    } catch (e) {
      return null;
    }
  }

  /// 获取启用的菜单项
  List<MenuItem> getEnabledMenuItems({
    bool isExpired = false,
    ProjectSupplyType? supplyType,
  }) {
    return getMenuItemsWithExpireState(
        isExpired,
        supplyType: supplyType,
      ).where((item) => item.isEnabled).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// 获取页面类型的菜单项
  List<MenuItem> getPageMenuItems({
    bool isExpired = false,
    ProjectSupplyType? supplyType,
  }) {
    return getMenuItemsWithExpireState(
      isExpired,
      supplyType: supplyType,
    ).where((item) => item.type == MenuItemType.page).toList();
  }

  /// 获取操作类型的菜单项
  List<MenuItem> getActionMenuItems({
    bool isExpired = false,
    ProjectSupplyType? supplyType,
  }) {
    return getMenuItemsWithExpireState(
      isExpired,
      supplyType: supplyType,
    ).where((item) => item.type == MenuItemType.action).toList();
  }

  /// 获取角色的核心业务权限描述
  String get permissionDescription {
    switch (this) {
      case UserRole.construction:
        return '建设单位：项目立项、库存管理(盘点/调拨/退库)、扫码识别';

      case UserRole.supervisor:
        return '监理单位：库存管理(盘点/退库)、扫码识别';

      case UserRole.builder:
        return '施工单位：验收管理、出库/退库/调拨、施工操作(备用码/截管/报废)、授权他人、扫码识别';

      case UserRole.builderSub:
        return '施工单位二级负责人：验收管理、出库/退库/调拨、施工操作(备用码/截管/报废)、授权他人、扫码识别';

      case UserRole.laborer:
        return '劳务人员：验收管理、出库/退库/调拨、施工操作(备用码/截管/报废，除授权他人)、扫码识别';

      case UserRole.playgoer:
        return '热心群众：扫码识别';

      case UserRole.suppliers:
        return '供应商：扫码识别';

      case UserRole.check:
        return '质检部门：扫码识别';
      case UserRole.storekeeper:
        return '仓库管理员：扫码识别、项目外入库';
    }
  }
}
