import 'package:json_annotation/json_annotation.dart';

/// 材料分组枚举
/// 用于解析扫描二维码获得的材料类型数据的大类枚举
@JsonEnum()
enum MaterialGroupEnum {
  @JsonValue(0)
  pipe(0, "第一类：管材"),

  @JsonValue(1)
  fittings(1, "第二类：管件"),

  @JsonValue(2)
  repair(2, "第三类：抢修材料");

  const MaterialGroupEnum(this.code, this.message);

  /// 材料分组代码
  final int code;

  /// 材料分组描述信息
  final String message;

  /// 从代码获取材料分组
  static MaterialGroupEnum fromCode(int code) {
    return MaterialGroupEnum.values.firstWhere(
      (group) => group.code == code,
      orElse: () => MaterialGroupEnum.pipe,
    );
  }

  /// 从JSON获取材料分组（支持int类型的code）
  static MaterialGroupEnum fromJson(dynamic json) {
    if (json is int) {
      return fromCode(json);
    }
    return MaterialGroupEnum.pipe;
  }

  /// 用于JSON序列化
  int toJson() => code;
}