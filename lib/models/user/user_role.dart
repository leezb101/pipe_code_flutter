/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:40:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-14 17:38:40
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';
import '../menu/menu_config.dart';
import 'user_role_menu_ext.dart';

/// 用户角色枚举
/// 定义用户在项目中可能拥有的不同角色类型
/// 完全匹配API文档中的角色字符串
@JsonEnum()
enum UserRole {
  @JsonValue(0)
  suppliers(0, "suppliers", "供应商"),

  @JsonValue(1)
  construction(1, "construction", "建设单位"),

  @JsonValue(2)
  supervisor(2, "supervisor", "监理单位"),

  @JsonValue(3)
  builder(3, "builder", "施工单位"),

  @JsonValue(4)
  check(4, "check", "质检部门"),

  @JsonValue(5)
  builderSub(5, "builder_sub", "施工单位二级负责人"),

  @JsonValue(6)
  laborer(6, "laborer", "劳务人员(允许代理收获和代理验收)"),

  @JsonValue(7)
  playgoer(7, "playgoer", "热心群众,无组织,游客");

  const UserRole(this.value, this.apiValue, this.displayName);

  /// 角色的原始int值
  final int value;

  /// 角色的API字符串标识
  final String apiValue;

  /// 角色的显示名称
  final String displayName;

  /// 从API字符串获取角色
  static UserRole fromApiValue(String apiValue) {
    return UserRole.values.firstWhere(
      (role) => role.apiValue == apiValue,
      orElse: () => UserRole.playgoer,
    );
  }

  /// 从int值获取角色
  static UserRole fromValue(int value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.playgoer,
    );
  }

  /// 兼容json序列化：支持int和string
  static UserRole fromJson(dynamic json) {
    if (json is int) {
      return fromValue(json);
    } else if (json is String) {
      // 兼容老数据
      return fromApiValue(json);
    }
    return UserRole.playgoer;
  }

  /// 用于json序列化
  int toJson() => value;

  /// 获取角色的权限级别（数值越小权限越高）
  int get authorityLevel {
    switch (this) {
      case UserRole.suppliers:
        return 0;
      case UserRole.construction:
        return 1;
      case UserRole.supervisor:
        return 2;
      case UserRole.builder:
        return 3;
      case UserRole.check:
        return 4;
      case UserRole.builderSub:
        return 5;
      case UserRole.laborer:
        return 6;
      case UserRole.playgoer:
        return 7;
    }
  }

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

  /// 向后兼容的menuItems属性，默认不过期
  List<MenuItem> get menuItems {
    return getMenuItemsWithExpireState(false);
  }
}
