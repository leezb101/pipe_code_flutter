import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'material_vo.g.dart';

@JsonSerializable()
class MaterialVO extends Equatable {
  /// 材料ID（可选，用于兼容服务器数据缺失情况）
  final int? materialId;

  /// 材料名称（可选，用于兼容服务器数据缺失情况）
  final String? materialName;

  /// 数量（可选，用于兼容服务器数据缺失情况）
  final int? num;

  final String? installPileNo;
  final String? installImageUrl1;
  final String? installImageUrl2;
  final String? materialCode;
  final String? batchCode;
  final int? status;
  final String? statusName;

  /// 数据问题描述（记录缺失字段的中文名称）
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? issueDesc;

  const MaterialVO({
    this.materialId,
    this.materialName,
    this.num,
    this.installPileNo,
    this.installImageUrl1,
    this.installImageUrl2,
    this.materialCode,
    this.batchCode,
    this.status,
    this.statusName,
    this.issueDesc,
  });

  factory MaterialVO.fromJson(Map<String, dynamic> json) {
    final vo = _$MaterialVOFromJson(json);

    // 检查必填字段是否缺失
    final missingFields = <String>[];

    if (vo.materialId == null) {
      missingFields.add('材料ID');
    }
    if (vo.materialName == null || vo.materialName!.isEmpty) {
      missingFields.add('材料名称');
    }
    if (vo.num == null) {
      missingFields.add('数量');
    }

    // 如果有缺失字段，生成问题描述
    String? issueDesc;
    if (missingFields.isNotEmpty) {
      issueDesc = '数据异常：缺少${missingFields.join('、')}';
    }

    return MaterialVO(
      materialId: vo.materialId,
      materialName: vo.materialName,
      num: vo.num,
      installPileNo: vo.installPileNo,
      installImageUrl1: vo.installImageUrl1,
      installImageUrl2: vo.installImageUrl2,
      materialCode: vo.materialCode,
      batchCode: vo.batchCode,
      status: vo.status,
      statusName: vo.statusName,
      issueDesc: issueDesc,
    );
  }

  Map<String, dynamic> toJson() => _$MaterialVOToJson(this);

  /// 判断是否有数据问题
  bool get hasIssue => issueDesc != null && issueDesc!.isNotEmpty;

  /// 获取显示用的材料名称（如果为空则返回默认值）
  String get displayMaterialName => materialName ?? '未知材料';

  /// 获取显示用的材料ID（如果为空则返回默认值）
  String get displayMaterialId => materialId?.toString() ?? '无';

  /// 获取显示用的数量（如果为空则返回默认值）
  int get displayNum => num ?? 0;

  @override
  List<Object?> get props => [
    materialId,
    materialName,
    num,
    installPileNo,
    installImageUrl1,
    installImageUrl2,
    materialCode,
    batchCode,
    status,
    statusName,
    issueDesc,
  ];

  MaterialVO copyWith({
    int? materialId,
    String? materialName,
    int? num,
    String? installPileNo,
    String? installImageUrl1,
    String? installImageUrl2,
    String? materialCode,
    String? batchCode,
    int? status,
    String? statusName,
    String? issueDesc,
  }) {
    return MaterialVO(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      num: num ?? this.num,
      installPileNo: installPileNo ?? this.installPileNo,
      installImageUrl1: installImageUrl1 ?? this.installImageUrl1,
      installImageUrl2: installImageUrl2 ?? this.installImageUrl2,
      materialCode: materialCode ?? this.materialCode,
      batchCode: batchCode ?? this.batchCode,
      status: status ?? this.status,
      statusName: statusName ?? this.statusName,
      issueDesc: issueDesc ?? this.issueDesc,
    );
  }
}
