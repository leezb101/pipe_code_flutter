/*
 * @Author: LeeZB
 * @Date: 2025-07-01 17:40:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-01 17:40:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:json_annotation/json_annotation.dart';

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