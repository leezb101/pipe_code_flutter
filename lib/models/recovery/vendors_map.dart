import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vendors_map.g.dart';

/// 供应商映射表，用于处理 API 返回的 data 字段
/// data 字段是一个 Map<String, String>，key 为供应商代码，value 为供应商名称
@JsonSerializable()
class VendorsMap extends Equatable {
  /// 供应商代码到名称的映射
  /// 例如: {"91130400104365768G": "新兴铸管", "XXXXXXXXXXXXXXXXXX": "熊猫铸管"}
  final Map<String, String> vendors;

  const VendorsMap({required this.vendors});

  /// 从 Map<String, String> 创建 VendorsMap
  factory VendorsMap.fromMap(Map<String, String> map) {
    return VendorsMap(vendors: map);
  }

  /// 从 JSON 创建 VendorsMap
  /// 注意：这里的 json 参数直接是 data 字段的内容（Map<String, String>）
  factory VendorsMap.fromJson(Map<String, dynamic> json) {
    return VendorsMap(vendors: Map<String, String>.from(json));
  }

  Map<String, dynamic> toJson() => vendors;

  /// 转换为下拉组件的选项列表
  List<VendorOption> toOptions() {
    return vendors.entries
        .map((entry) => VendorOption(code: entry.key, name: entry.value))
        .toList();
  }

  /// 根据代码获取供应商名称
  String? getVendorName(String code) {
    return vendors[code];
  }

  /// 获取所有供应商代码
  List<String> get codes => vendors.keys.toList();

  /// 获取所有供应商名称
  List<String> get names => vendors.values.toList();

  /// 是否包含指定的供应商代码
  bool containsCode(String code) => vendors.containsKey(code);

  @override
  List<Object> get props => [vendors];
}

/// 下拉组件选项模型
@JsonSerializable()
class VendorOption extends Equatable {
  /// 供应商代码
  final String code;

  /// 供应商名称
  final String name;

  const VendorOption({required this.code, required this.name});

  factory VendorOption.fromJson(Map<String, dynamic> json) =>
      _$VendorOptionFromJson(json);

  Map<String, dynamic> toJson() => _$VendorOptionToJson(this);

  @override
  List<Object> get props => [code, name];

  /// 用于下拉组件显示的文本
  @override
  String toString() => name;
}
