import 'tracing_info.dart';

const String homeTabRouteName = 'main/home';
const String recordsTabRouteName = 'main/records';
const String profileTabRouteName = 'main/profile';
const String adminHomeTabRouteName = 'main/admin_home';

final Map<String, TracingInfo> tracingRouteMappings = {
  /// ==== 主要功能模块 ====
  'boot': const TracingInfo(source: 'boot_page', description: '启动页'),
  'login': const TracingInfo(source: 'login_page', description: '登录页'),
  'register': const TracingInfo(source: 'register_page', description: '注册页'),
  'main': const TracingInfo(source: 'main_page', description: '主页面'),
  homeTabRouteName: const TracingInfo(
    source: 'home_tab_page',
    description: '首页',
  ),
  recordsTabRouteName: const TracingInfo(
    source: 'records_tab_page',
    description: '业务记录',
  ),
  profileTabRouteName: const TracingInfo(
    source: 'profile_tab_page',
    description: '我的',
  ),
  adminHomeTabRouteName: const TracingInfo(
    source: 'admin_home_tab_page',
    description: '管理员首页',
  ),
  // 业务流程
  'dispatch-application': const TracingInfo(
    source: 'dispatch_application_page',
    description: '调拨申请',
  ),
  'dispatch-confirmation': const TracingInfo(
    source: 'dispatch_confirmation_page',
    description: '调拨确认',
  ),
  'dispatch-detail': const TracingInfo(
    source: 'dispatch_detail_page',
    description: '调拨详情',
  ),
  'dispatch-after-signin': const TracingInfo(
    source: 'dispatch_after_signin_page',
    description: '调拨后入库',
  ),

  'acceptance': const TracingInfo(
    source: 'acceptance_page',
    description: '验收申请',
  ),
  'acceptance-detail': const TracingInfo(
    source: 'acceptance_detail_page',
    description: '验收详情',
  ),
  'acceptance-confirmation': const TracingInfo(
    source: 'acceptance_confirmation_page',
    description: '验收确认',
  ),
  'acceptance-after-signin': const TracingInfo(
    source: 'acceptance_after_signin_page',
    description: '验收后入库',
  ),

  'signin-detail': const TracingInfo(
    source: 'signin_detail_page',
    description: '入库详情',
  ),

  'signout': const TracingInfo(source: 'signout_page', description: '出库'),
  'signout-audit': const TracingInfo(
    source: 'signout_audit_page',
    description: '出库确认',
  ),
  'signout-detail': const TracingInfo(
    source: 'signout_detail_page',
    description: '出库详情',
  ),

  'return-material': const TracingInfo(
    source: 'return_page',
    description: '退库',
  ),
  'return-detail': const TracingInfo(
    source: 'return_detail_page',
    description: '退库详情',
  ),

  'install': const TracingInfo(source: 'install_page', description: '安装'),
  'install-detail': const TracingInfo(
    source: 'install_detail_page',
    description: '安装详情',
  ),

  'records': const TracingInfo(
    source: 'records_list_page',
    description: '业务记录列表',
  ),

  'recovery': const TracingInfo(source: 'recovery_page', description: '破损码恢复'),

  'qr-scan': const TracingInfo(source: 'qr_scan_page', description: '扫码'),
  'spare-qr': const TracingInfo(source: 'spare_qr_page', description: '备用二维码'),

  'material-detail': const TracingInfo(
    source: 'material_detail_page',
    description: '物料详情',
  ),
  'material-detail/pipe-cutting-record': const TracingInfo(
    source: 'pipe_cutting_record_page',
    description: '截管记录',
  ),
  'material-detail/material-lifecycle': const TracingInfo(
    source: 'material_lifecycle_page',
    description: '物料生命周期',
  ),

  'project-initiation': const TracingInfo(
    source: 'project_initiation_form_page',
    description: '立项表单',
  ),
  'material-selection': const TracingInfo(
    source: 'material_selection_page',
    description: '立项物料选择',
  ),

  'cut-pipe': const TracingInfo(source: 'cut_pipe_page', description: '截管'),

  'inventory': const TracingInfo(
    source: 'inventory_list_page',
    description: '盘点任务列表',
  ),
  'inventory-apply': const TracingInfo(
    source: 'inventory_apply_page',
    description: '盘点处理',
  ),
  'inventory-detail': const TracingInfo(
    source: 'inventory_detail_page',
    description: '盘点详情',
  ),

  'scrap': const TracingInfo(source: 'scrap_page', description: '报废'),
  'scrap-detail': const TracingInfo(
    source: 'scrap_detail_page',
    description: '报废详情',
  ),

  'temporary-auth': const TracingInfo(
    source: 'temporary_auth_page',
    description: '临时授权',
  ),

  'qmap': const TracingInfo(source: 'qmap_page', description: '地图'),
  'warehouseDetail': const TracingInfo(
    source: 'warehouse_detail_page',
    description: '地图仓库详情',
  ),
  'projectDetail': const TracingInfo(
    source: 'project_detail_page',
    description: '地图项目详情',
  ),

  // 其他功能
  'developer-settings': const TracingInfo(
    source: 'developer_settings_page',
    description: '开发者设置',
  ),
  'pending-todo': const TracingInfo(
    source: 'pending_todo_list_page',
    description: '待办事项',
  ),
  'pdf-preview': const TracingInfo(
    source: 'pdf_previewer_page',
    description: 'PDF预览',
  ),
  'storekeeper-non-project': const TracingInfo(
    source: 'storekeeper_non_project_page',
    description: '仓管首页',
  ),
  'change-password': const TracingInfo(
    source: 'change_password_page',
    description: '修改密码',
  ),
};
