/*
 * @Author: LeeZB
 * @Date: 2025-08-22 22:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-22 22:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'material_categories.g.dart';

/// 物料分类列表，用于处理 API 返回的 data 字段
/// data 字段是一个 `List<MaterialCategory>`
class MaterialCategoriesList extends Equatable {
  /// 物料分类列表
  final List<MaterialCategory> categories;

  const MaterialCategoriesList({required this.categories});

  /// 从 `List<dynamic>` 创建 MaterialCategoriesList
  factory MaterialCategoriesList.fromList(List<dynamic> list) {
    return MaterialCategoriesList(
      categories: list
          .map(
            (item) => MaterialCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// 从 JSON 创建 MaterialCategoriesList
  /// 注意：这里的 json 参数直接是 data 字段的内容（`List<dynamic>`）
  factory MaterialCategoriesList.fromJson(List<dynamic> json) {
    return MaterialCategoriesList(
      categories: json
          .map(
            (item) => MaterialCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  List<dynamic> toJson() =>
      categories.map((category) => category.toJson()).toList();

  // 转换为下拉组件的选项列表
  List<Map<String, dynamic>> toDropdownOptions() {
    return categories.map((category) {
      return {'label': category.name, 'value': category.group};
    }).toList();
  }

  /// 根据组别获取分类
  MaterialCategory? getCategoryByGroup(int group) {
    try {
      return categories.firstWhere((category) => category.group == group);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有物料类型（扁平化）
  List<MaterialType> getAllMaterialTypes() {
    return categories.expand((category) => category.types).toList();
  }

  /// 根据类型编号获取物料类型
  MaterialType? getMaterialTypeByType(int type) {
    for (final category in categories) {
      try {
        return category.types.firstWhere(
          (materialType) => materialType.type == type,
        );
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// 获取所有检索字段（扁平化）
  List<RetrieveBack> getAllRetrieveBacks() {
    return categories
        .expand((category) => category.types)
        .expand((type) => type.retrieveBacks)
        .toList();
  }

  @override
  List<Object> get props => [categories];
}

/// 物料分类
@JsonSerializable()
class MaterialCategory extends Equatable {
  /// 组别
  final int group;

  /// 分类名称
  final String name;

  /// 物料类型列表
  final List<MaterialType> types;

  const MaterialCategory({
    required this.group,
    required this.name,
    required this.types,
  });

  factory MaterialCategory.fromJson(Map<String, dynamic> json) =>
      _$MaterialCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialCategoryToJson(this);

  /// 根据类型编号获取物料类型
  MaterialType? getMaterialTypeByType(int type) {
    try {
      return types.firstWhere((materialType) => materialType.type == type);
    } catch (e) {
      return null;
    }
  }

  /// 获取该分类下的所有检索字段
  List<RetrieveBack> getAllRetrieveBacks() {
    return types.expand((type) => type.retrieveBacks).toList();
  }

  @override
  List<Object> get props => [group, name, types];
}

/// 物料类型
@JsonSerializable()
class MaterialType extends Equatable {
  /// 物料类型名称
  final String name;

  /// 检索字段列表
  final List<RetrieveBack> retrieveBacks;

  /// 类型编号
  final int type;

  const MaterialType({
    required this.name,
    required this.retrieveBacks,
    required this.type,
  });

  factory MaterialType.fromJson(Map<String, dynamic> json) =>
      _$MaterialTypeFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialTypeToJson(this);

  /// 根据key获取检索字段
  RetrieveBack? getRetrieveBackByKey(String key) {
    try {
      return retrieveBacks.firstWhere(
        (retrieveBack) => retrieveBack.key == key,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取所有检索字段的键
  List<String> get retrieveBackKeys =>
      retrieveBacks.map((rb) => rb.key).toList();

  /// 获取所有检索字段的名称
  List<String> get retrieveBackNames =>
      retrieveBacks.map((rb) => rb.name).toList();

  @override
  List<Object> get props => [name, retrieveBacks, type];
}

/// 检索字段
@JsonSerializable()
class RetrieveBack extends Equatable {
  /// 字段键
  final String key;

  /// 字段名称
  final String name;

  /// 字段值（可为空）
  final String? value;

  const RetrieveBack({required this.key, required this.name, this.value});

  factory RetrieveBack.fromJson(Map<String, dynamic> json) =>
      _$RetrieveBackFromJson(json);

  Map<String, dynamic> toJson() => _$RetrieveBackToJson(this);

  /// 创建带有新值的副本
  RetrieveBack copyWithValue(String? newValue) {
    return RetrieveBack(key: key, name: name, value: newValue);
  }

  /// 判断是否有值
  bool get hasValue => value != null && value!.isNotEmpty;

  @override
  List<Object?> get props => [key, name, value];

  @override
  String toString() => '$name: ${value ?? "未填写"}';
}

/// 用于下拉组件的选项类型
class MaterialCategoryOption extends Equatable {
  final int group;
  final String name;

  const MaterialCategoryOption({required this.group, required this.name});

  factory MaterialCategoryOption.fromMaterialCategory(
    MaterialCategory category,
  ) {
    return MaterialCategoryOption(group: category.group, name: category.name);
  }

  @override
  List<Object> get props => [group, name];

  @override
  String toString() => name;
}

/// 用于下拉组件的物料类型选项
class MaterialTypeOption extends Equatable {
  final int type;
  final String name;

  const MaterialTypeOption({required this.type, required this.name});

  factory MaterialTypeOption.fromMaterialType(MaterialType materialType) {
    return MaterialTypeOption(type: materialType.type, name: materialType.name);
  }

  @override
  List<Object> get props => [type, name];

  @override
  String toString() => name;
}
