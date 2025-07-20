import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'material_vo.dart';
import 'attachment_vo.dart';

part 'do_accept_vo.g.dart';

@JsonSerializable()
class DoAcceptVO extends Equatable {
  final List<MaterialVO> materiaList;
  final List<AttachmentVO> imageList;
  final String? sendAcceptUrl;
  final String? acceptReportUrl;
  final bool realWarehouse;
  final int warehouseId;
  final List<int> messageTo;

  const DoAcceptVO({
    required this.materiaList,
    required this.imageList,
    this.sendAcceptUrl,
    this.acceptReportUrl,
    required this.realWarehouse,
    required this.warehouseId,
    required this.messageTo,
  });

  factory DoAcceptVO.fromJson(Map<String, dynamic> json) =>
      _$DoAcceptVOFromJson(json);

  Map<String, dynamic> toJson() => _$DoAcceptVOToJson(this);

  @override
  List<Object?> get props => [
        materiaList,
        imageList,
        sendAcceptUrl,
        acceptReportUrl,
        realWarehouse,
        warehouseId,
        messageTo,
      ];

  DoAcceptVO copyWith({
    List<MaterialVO>? materiaList,
    List<AttachmentVO>? imageList,
    String? sendAcceptUrl,
    String? acceptReportUrl,
    bool? realWarehouse,
    int? warehouseId,
    List<int>? messageTo,
  }) {
    return DoAcceptVO(
      materiaList: materiaList ?? this.materiaList,
      imageList: imageList ?? this.imageList,
      sendAcceptUrl: sendAcceptUrl ?? this.sendAcceptUrl,
      acceptReportUrl: acceptReportUrl ?? this.acceptReportUrl,
      realWarehouse: realWarehouse ?? this.realWarehouse,
      warehouseId: warehouseId ?? this.warehouseId,
      messageTo: messageTo ?? this.messageTo,
    );
  }
}