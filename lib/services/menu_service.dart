/*
 * @Author: LeeZB
 * @Date: 2025-07-29 16:30:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-30 11:45:00
 * @copyright: Copyright © 2025 高新供水.
 */
import '../models/menu/menu_config.dart';
import '../models/user/user_role.dart';
import '../models/user/user_role_menu_ext.dart';

/// 菜单服务 - 根据用户角色动态生成菜单配置
/// 现在直接使用 UserRole 扩展方法，确保菜单项完全一致
class MenuService {
  /// 根据用户角色获取菜单项列表
  /// 直接使用 UserRole 扩展方法，确保与 user_role_menu_ext.dart 完全一致
  static List<MenuItem> getMenuItemsByRole(UserRole role, {bool isExpired = false}) {
    return role.getMenuItemsWithExpireState(isExpired);
  }
}