/*
 * @Author: LeeZB
 * @Date: 2025-07-22 15:31:03
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 16:46:18
 * @copyright: Copyright © 2025 高新供水.
 */
/// 通用的枚举基类（为后续扩展 MaterialType、ProjectType 等做准备）
abstract class EnumModel<T> {
  final T value;
  final String name;

  const EnumModel(this.value, this.name);

  /// 根据 int 或 string 构建枚举
  static E? fromValue<E extends EnumModel>(Iterable<E> values, dynamic value) {
    for (final v in values) {
      if (v.value == value) return v;
    }
    return null;
  }
}

/// 材料类型枚举（与 /enum/material/type 接口适配）
class MaterialType extends EnumModel<int> {
  const MaterialType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<MaterialType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => MaterialType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static MaterialType? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory MaterialType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? MaterialType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return MaterialType(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 MaterialType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 材料大类枚举，与/enum/material/group 接口适配）
class MaterialGroup extends EnumModel<int> {
  const MaterialGroup(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<MaterialGroup> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => MaterialGroup(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static MaterialGroup? fromInt(int value) =>
      EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory MaterialGroup.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? MaterialGroup(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return MaterialGroup(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 MaterialGroup 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 待办类型枚举（与 /enum/todo/type 接口适配）
class TodoType extends EnumModel<int> {
  const TodoType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<TodoType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => TodoType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static TodoType? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory TodoType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? TodoType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return TodoType(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 TodoType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 待办类型枚举（与 /enum/accept/status 接口适配）
class AcceptStatus extends EnumModel<int> {
  const AcceptStatus(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<AcceptStatus> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => AcceptStatus(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static AcceptStatus? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory AcceptStatus.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? AcceptStatus(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return AcceptStatus(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 AcceptStatus 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 待办类型枚举（与 /enum/business/type 接口适配）
class BusinessType extends EnumModel<int> {
  const BusinessType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<BusinessType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => BusinessType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static BusinessType? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory BusinessType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? BusinessType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return BusinessType(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 BusinessType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 项目状态枚举（与 /enum/project/status 接口适配）
class ProjectStatus extends EnumModel<int> {
  const ProjectStatus(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<ProjectStatus> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => ProjectStatus(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static ProjectStatus? fromInt(int value) =>
      EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory ProjectStatus.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? ProjectStatus(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return ProjectStatus(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 ProjectStatus 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 甲乙供材类型枚举（与 /enum/projectsupply/type 接口适配）
class ProjectSupplyType extends EnumModel<int> {
  const ProjectSupplyType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<ProjectSupplyType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => ProjectSupplyType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static ProjectSupplyType? fromInt(int value) =>
      EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory ProjectSupplyType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? ProjectSupplyType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return ProjectSupplyType(
        json['code'] as int,
        json['msg'] as String? ?? '',
      );
    } else {
      throw ArgumentError('不支持的 ProjectSupplyType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 项目类型枚举（与 /enum/project/type 接口适配）
class ProjectType extends EnumModel<int> {
  const ProjectType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<ProjectType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => ProjectType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static ProjectType? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory ProjectType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? ProjectType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return ProjectType(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 ProjectType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 退库类型枚举（与 /enum/return/type 接口适配）
class ReturnType extends EnumModel<int> {
  const ReturnType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<ReturnType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => ReturnType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static ReturnType? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory ReturnType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? ReturnType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return ReturnType(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 ReturnType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}
