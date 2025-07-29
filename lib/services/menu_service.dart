/*
 * @Author: LeeZB
 * @Date: 2025-07-29 16:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-29 16:30:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/menu/menu_config.dart';
import '../models/user/user_role.dart';
import '../constants/menu_actions.dart';

/// 菜单服务 - 根据用户角色动态生成菜单配置
class MenuService {
  /// 根据用户角色获取菜单项列表
  static List<MenuItem> getMenuItemsByRole(UserRole role, {bool isExpired = false}) {
    // 如果用户已过期，只显示基本信息菜单
    if (isExpired) {
      return _getExpiredUserMenuItems();
    }

    switch (role) {
      case UserRole.suppliers:
        return _getSuppliersMenuItems();
      case UserRole.construction:
        return _getConstructionMenuItems();
      case UserRole.supervisor:
        return _getSupervisorMenuItems();
      case UserRole.builder:
        return _getBuilderMenuItems();
      case UserRole.check:
        return _getCheckMenuItems();
      case UserRole.builderSub:
        return _getBuilderSubMenuItems();
      case UserRole.laborer:
        return _getLaborerMenuItems();
      case UserRole.playgoer:
        return _getPlaygoerMenuItems();
      case UserRole.storekeeper:
        return _getStorekeeperMenuItems();
    }
  }

  /// 供应商菜单
  static List<MenuItem> _getSuppliersMenuItems() {
    return [
      const MenuItem(
        id: 'product_management',
        title: '产品管理',
        type: MenuItemType.page,
        icon: 'inventory',
        route: '/product-management',
        description: '管理产品信息和库存',
        order: 1,
      ),
      const MenuItem(
        id: 'order_management',
        title: '订单管理',
        type: MenuItemType.page,
        icon: 'assignment',
        route: '/order-management',
        description: '处理和跟踪订单',
        order: 2,
      ),
      const MenuItem(
        id: 'delivery_tracking',
        title: '配送跟踪',
        type: MenuItemType.page,
        icon: 'local_shipping',
        route: '/delivery-tracking',
        description: '跟踪配送状态',
        order: 3,
      ),
    ];
  }

  /// 施工方菜单
  static List<MenuItem> _getConstructionMenuItems() {
    return [
      const MenuItem(
        id: 'project_overview',
        title: '项目概览',
        type: MenuItemType.page,
        icon: 'dashboard',
        route: '/project-overview',
        description: '查看项目整体情况',
        order: 1,
      ),
      const MenuItem(
        id: 'contract_management',
        title: '合同管理',
        type: MenuItemType.page,
        icon: 'description',
        route: '/contract-management',
        description: '管理项目合同',
        order: 2,
      ),
      const MenuItem(
        id: 'progress_monitoring',
        title: '进度监控',
        type: MenuItemType.page,
        icon: 'timeline',
        route: '/progress-monitoring',
        description: '监控施工进度',
        order: 3,
      ),
      const MenuItem(
        id: 'quality_control',
        title: '质量控制',
        type: MenuItemType.page,
        icon: 'verified',
        route: '/quality-control',
        description: '质量管理和控制',
        order: 4,
      ),
    ];
  }

  /// 监理方菜单
  static List<MenuItem> _getSupervisorMenuItems() {
    return [
      const MenuItem(
        id: 'inspection_tasks',
        title: '巡检任务',
        type: MenuItemType.page,
        icon: 'search',
        route: '/inspection-tasks',
        description: '执行巡检任务',
        order: 1,
      ),
      const MenuItem(
        id: 'quality_reports',
        title: '质量报告',
        type: MenuItemType.page,
        icon: 'assessment',
        route: '/quality-reports',
        description: '生成质量报告',
        order: 2,
      ),
      const MenuItem(
        id: 'acceptance_management',
        title: '验收管理',
        type: MenuItemType.page,
        icon: 'check_circle',
        route: '/acceptance-management',
        description: '管理验收流程',
        order: 3,
      ),
    ];
  }

  /// 施工员菜单
  static List<MenuItem> _getBuilderMenuItems() {
    return [
      const MenuItem(
        id: 'construction_tasks',
        title: '施工任务',
        type: MenuItemType.page,
        icon: 'build',
        route: '/construction-tasks',
        description: '查看和执行施工任务',
        order: 1,
      ),
      const MenuItem(
        id: 'material_management',
        title: '物料管理',
        type: MenuItemType.page,
        icon: 'inventory_2',
        route: '/material-management',
        description: '管理施工物料',
        order: 2,
      ),
      const MenuItem(
        id: 'safety_records',
        title: '安全记录',
        type: MenuItemType.page,
        icon: 'security',
        route: '/safety-records',
        description: '记录安全情况',
        order: 3,
      ),
      const MenuItem(
        id: 'qr_operations',
        title: '二维码操作',
        type: MenuItemType.group,
        icon: 'qr_code',
        description: '二维码相关操作',
        order: 4,
        children: [
          const MenuItem(
            id: 'qr_scan_signout',
            title: '出库扫码',
            type: MenuItemType.action,
            icon: 'output',
            action: MenuActions.qrScanSignout,
            description: '扫码出库物料',
          ),
          const MenuItem(
            id: 'qr_scan_transfer',
            title: '调拨扫码',
            type: MenuItemType.action,
            icon: 'swap_horiz',
            action: MenuActions.qrScanTransfer,
            description: '扫码调拨物料',
          ),
          const MenuItem(
            id: 'qr_scan_acceptance',
            title: '验收扫码',
            type: MenuItemType.action,
            icon: 'check_circle',
            action: MenuActions.qrScanAcceptance,
            description: '扫码验收物料',
          ),
        ],
      ),
    ];
  }

  /// 质检员菜单
  static List<MenuItem> _getCheckMenuItems() {
    return [
      const MenuItem(
        id: 'quality_inspection',
        title: '质量检测',
        type: MenuItemType.page,
        icon: 'fact_check',
        route: '/quality-inspection',
        description: '执行质量检测',
        order: 1,
      ),
      const MenuItem(
        id: 'test_reports',
        title: '检测报告',
        type: MenuItemType.page,
        icon: 'lab_profile',
        route: '/test-reports',
        description: '生成检测报告',
        order: 2,
      ),
    ];
  }

  /// 分包方菜单
  static List<MenuItem> _getBuilderSubMenuItems() {
    return [
      const MenuItem(
        id: 'sub_task_allocation',
        title: '子任务分配',
        type: MenuItemType.page,
        icon: 'assignment_ind',
        route: '/sub-task-allocation',
        description: '分配子任务',
        order: 1,
      ),
      const MenuItem(
        id: 'team_management',
        title: '团队管理',
        type: MenuItemType.page,
        icon: 'groups',
        route: '/team-management',
        description: '管理施工团队',
        order: 2,
      ),
    ];
  }

  /// 劳务方菜单
  static List<MenuItem> _getLaborerMenuItems() {
    return [
      const MenuItem(
        id: 'work_tasks',
        title: '工作任务',
        type: MenuItemType.page,
        icon: 'work',
        route: '/work-tasks',
        description: '查看工作任务',
        order: 1,
      ),
      const MenuItem(
        id: 'delegate_operations',
        title: '委托操作',
        type: MenuItemType.group,
        icon: 'support_agent',
        description: '委托相关操作',
        order: 2,
        children: [
          const MenuItem(
            id: 'delegate_harvest',
            title: '委托收货',
            type: MenuItemType.action,
            icon: 'input',
            action: MenuActions.delegateHarvest,
            description: '委托收货操作',
          ),
          const MenuItem(
            id: 'delegate_accept',
            title: '委托验收',
            type: MenuItemType.action,
            icon: 'check_circle',
            action: MenuActions.delegateAccept,
            description: '委托验收操作',
          ),
        ],
      ),
    ];
  }

  /// 旁站方菜单
  static List<MenuItem> _getPlaygoerMenuItems() {
    return [
      const MenuItem(
        id: 'basic_info',
        title: '基本信息',
        type: MenuItemType.page,
        icon: 'info',
        route: '/basic-info',
        description: '查看基本信息',
        order: 1,
      ),
      const MenuItem(
        id: 'feedback',
        title: '意见反馈',
        type: MenuItemType.page,
        icon: 'feedback',
        route: '/feedback',
        description: '提交意见反馈',
        order: 2,
      ),
    ];
  }

  /// 仓管员菜单
  static List<MenuItem> _getStorekeeperMenuItems() {
    return [
      const MenuItem(
        id: 'inventory',
        title: '库存管理',
        type: MenuItemType.page,
        icon: 'inventory',
        route: '/inventory',
        description: '管理库存',
        order: 1,
      ),
      const MenuItem(
        id: 'signout',
        title: '出库管理',
        type: MenuItemType.page,
        icon: 'output',
        route: '/signout',
        description: '管理出库',
        order: 2,
      ),
      const MenuItem(
        id: 'return',
        title: '退库管理',
        type: MenuItemType.page,
        icon: 'keyboard_return',
        route: '/return',
        description: '管理退库',
        order: 3,
      ),
      const MenuItem(
        id: 'transfer',
        title: '调拨管理',
        type: MenuItemType.page,
        icon: 'swap_horiz',
        route: '/transfer',
        description: '管理调拨',
        order: 4,
      ),
    ];
  }

  /// 过期用户菜单（权限受限）
  static List<MenuItem> _getExpiredUserMenuItems() {
    return [
      const MenuItem(
        id: 'basic_info',
        title: '基本信息',
        type: MenuItemType.page,
        icon: 'info',
        route: '/basic-info',
        description: '查看基本信息',
        order: 1,
        isEnabled: false,
      ),
      const MenuItem(
        id: 'contact_admin',
        title: '联系管理员',
        type: MenuItemType.page,
        icon: 'support_agent',
        route: '/contact-admin',
        description: '联系项目管理员',
        order: 2,
      ),
    ];
  }
}