/*
 * @Author: LeeZB
 * @Date: 2025-10-07 14:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-10-07 14:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// 材料状态枚举
/// 硬编码的材料状态，用于业务逻辑判断
enum MaterialStatusEnum {
  /// 初始化 - 对应二维码已生成科*
  init(0, "初始化", "对应二维码已生成科*"),

  /// 已验收 - 已验收
  accepted(1, "已验收", "已验收"),

  /// 已入库 - 已入库
  signIn(10, "已入库", "已入库"),

  /// 已安装 - 已安装
  installed(2, "已安装", "已安装"),

  /// 数量不匹配退回 - 数量不匹配退回（退库）
  backNumError(3, "数量不匹配退回", "数量不匹配退回（退库）"),

  /// 质量问题退回 - 质量问题退回（退库）
  backQuality(4, "质量问题退回", "质量问题退回（退库）"),

  /// 已切割 - 已切割
  cut(5, "已切割", "已切割"),

  /// 已销毁 - 已销毁
  destroy(6, "已销毁", "已销毁"),

  /// 已出库 - 已出库
  signOut(7, "已出库", "已出库"),

  /// 已调度 - 已调度
  dispatch(8, "已调度", "已调度"),

  /// 非项目入库 - 非项目入库
  notProject(9, "非项目入库", "非项目入库");

  /// 状态码
  final int code;

  /// 状态名称
  final String name;

  /// 状态描述
  final String description;

  const MaterialStatusEnum(this.code, this.name, this.description);

  /// 根据状态码获取对应的枚举值
  static MaterialStatusEnum? fromCode(int code) {
    for (MaterialStatusEnum status in MaterialStatusEnum.values) {
      if (status.code == code) {
        return status;
      }
    }
    return null;
  }

  /// 根据状态码获取对应的枚举值，如果未找到则返回默认值
  static MaterialStatusEnum fromCodeWithDefault(
    int code, {
    MaterialStatusEnum defaultValue = MaterialStatusEnum.init,
  }) {
    return fromCode(code) ?? defaultValue;
  }

  /// 根据状态名称获取对应的枚举值
  static MaterialStatusEnum? fromName(String name) {
    for (MaterialStatusEnum status in MaterialStatusEnum.values) {
      if (status.name == name) {
        return status;
      }
    }
    return null;
  }

  /// 获取所有状态码列表
  static List<int> getAllCodes() {
    return MaterialStatusEnum.values.map((e) => e.code).toList();
  }

  /// 获取所有状态名称列表
  static List<String> getAllNames() {
    return MaterialStatusEnum.values.map((e) => e.name).toList();
  }

  /// 判断是否为退库状态
  bool get isReturnStatus {
    return this == MaterialStatusEnum.backNumError ||
        this == MaterialStatusEnum.backQuality;
  }

  /// 判断是否为正常流转状态（非退库、非销毁）
  bool get isNormalStatus {
    return !isReturnStatus && this != MaterialStatusEnum.destroy;
  }

  /// 判断是否为已入库状态（包含正常入库和非项目入库）
  bool get isInStorageStatus {
    return this == MaterialStatusEnum.signIn ||
        this == MaterialStatusEnum.notProject;
  }

  /// 判断是否为已出库状态
  bool get isOutStorageStatus {
    return this == MaterialStatusEnum.signOut;
  }

  /// 判断是否为终态（已安装、已销毁、已切割等）
  bool get isFinalStatus {
    return this == MaterialStatusEnum.installed ||
        this == MaterialStatusEnum.destroy ||
        this == MaterialStatusEnum.cut;
  }

  /// 获取可以从当前状态流转到的下一状态列表
  List<MaterialStatusEnum> getNextPossibleStatuses() {
    switch (this) {
      case MaterialStatusEnum.init:
        return [MaterialStatusEnum.accepted];
      case MaterialStatusEnum.accepted:
        return [
          MaterialStatusEnum.signIn,
          MaterialStatusEnum.backNumError,
          MaterialStatusEnum.backQuality,
        ];
      case MaterialStatusEnum.signIn:
        return [MaterialStatusEnum.signOut, MaterialStatusEnum.notProject];
      case MaterialStatusEnum.signOut:
        return [MaterialStatusEnum.installed, MaterialStatusEnum.dispatch];
      case MaterialStatusEnum.dispatch:
        return [MaterialStatusEnum.installed];
      case MaterialStatusEnum.installed:
        return [MaterialStatusEnum.cut];
      case MaterialStatusEnum.cut:
        return [MaterialStatusEnum.destroy];
      case MaterialStatusEnum.notProject:
        return [MaterialStatusEnum.destroy];
      case MaterialStatusEnum.backNumError:
      case MaterialStatusEnum.backQuality:
        return [MaterialStatusEnum.destroy];
      case MaterialStatusEnum.destroy:
        return [];
    }
  }

  /// 判断是否可以流转到指定状态
  bool canTransitionTo(MaterialStatusEnum targetStatus) {
    return getNextPossibleStatuses().contains(targetStatus);
  }

  @override
  String toString() => '$name($code)';
}
