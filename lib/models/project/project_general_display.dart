import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_general_display.g.dart';

@JsonSerializable()
class ProjectGeneralDisplay extends Equatable {
  /// 耗材总数量
  final int? totalCount;

  /// 验收数量
  final int? acceptedCount;

  /// 安装数量
  final int? installedCount;

  /// 截断数量
  final int? cutPipeCount;

  /// 不合格退库数量
  final int? rejectedCount;

  /// 多余退库数量
  final int? surplusReturnedCount;

  /// 二维码丢失替换数量
  final int? qrCodeLostCount;

  /// 已损毁数量
  final int? damageCount;

  const ProjectGeneralDisplay({
    this.totalCount,
    this.acceptedCount,
    this.installedCount,
    this.cutPipeCount,
    this.rejectedCount,
    this.surplusReturnedCount,
    this.qrCodeLostCount,
    this.damageCount,
  });

  factory ProjectGeneralDisplay.fromJson(Map<String, dynamic> json) =>
      _$ProjectGeneralDisplayFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectGeneralDisplayToJson(this);

  @override
  List<Object?> get props => [
    totalCount,
    acceptedCount,
    installedCount,
    cutPipeCount,
    rejectedCount,
    surplusReturnedCount,
    qrCodeLostCount,
    damageCount,
  ];
}
