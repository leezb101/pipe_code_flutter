/*
 * @Author: LeeZB
 * @Date: 2025-07-22 15:24:04
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-07-22 16:51:51
 * @copyright: Copyright © 2025 高新供水.
 */
import 'common_enum_vo.dart';

/// 公司类型枚举（与 /enum/org/type 接口适配）
class OrgType extends EnumModel<int> {
  const OrgType(super.value, super.name);

  /// 扩展：所有已知公司类型枚举
  static List<OrgType> values = [];

  /// 可从接口返回的列表初始化所有枚举
  static void initFromList(List<dynamic> data) {
    values = data
        .map((e) => OrgType(e['code'] as int, e['msg'] as String))
        .toList();
  }

  /// 根据 int 获取枚举
  static OrgType? fromInt(int value) => EnumModel.fromValue(values, value);

  /// 用于反序列化 int 或 Map
  factory OrgType.fromJson(dynamic json) {
    if (json is int) {
      return fromInt(json) ?? OrgType(json, '未知类型'); // 容错：未定义类型
    } else if (json is Map) {
      return OrgType(json['code'] as int, json['msg'] as String? ?? '');
    } else {
      throw ArgumentError('不支持的 OrgType 格式: \$json');
    }
  }

  /// 输出 int，toJson 用于接口传参
  int toJson() => value;

  @override
  String toString() => '\$name(\$value)';
}

/// 简易公司数据模型，适配 /enum/orgs 接口
class SimpleOrg {
  final String code;
  final String name;
  final OrgType type;
  final String typeName;

  const SimpleOrg({
    required this.code,
    required this.name,
    required this.type,
    required this.typeName,
  });

  /// 工厂构造（适配接口协议）
  factory SimpleOrg.fromJson(Map<String, dynamic> json) => SimpleOrg(
    code: json['code'] as String,
    name: json['name'] as String,
    type: OrgType.fromJson(json['type']),
    typeName: json['typeName'] as String,
  );

  /// 转为 Map 便于 toJson
  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'type': type.toJson(), // int 类型适配后端协议
    'typeName': typeName,
  };

  @override
  String toString() =>
      'SimpleOrg(code: \$code, name: \$name, type: \$type, typeName: \$typeName)';
}
