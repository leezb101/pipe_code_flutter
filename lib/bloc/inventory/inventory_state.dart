import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/inventory/inventory_models.dart';
import 'package:pipe_code_flutter/models/material/material_info_base.dart';

enum DataStatus { initial, loading, success, failure }

enum SubmissionStatus { initial, loading, success, failure }

class InventoryState extends Equatable {
  // 列表状态
  final DataStatus listStatus;
  final List<InventoryListItemVO> inventoryList;
  final int totalTasks;
  final bool hasReachedMax;
  final int currentPage;

  // 详情状态
  final DataStatus detailStatus;
  final InventoryDetailInfoVO? inventoryDetail;

  // 盘点比对状态
  final DataStatus comparisonStatus;
  final List<MaterialInfo> surplusMaterials; // 盘盈的物料
  final Set<int> matchedMaterialIds; // 已匹配的原始物料ID

  // 附件和提交状态
  final String? photo1;
  final String? photo2;
  final SubmissionStatus submissionStatus;
  final String? errorMessage;

  const InventoryState({
    this.listStatus = DataStatus.initial,
    this.inventoryList = const [],
    this.totalTasks = 0,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.detailStatus = DataStatus.initial,
    this.inventoryDetail,
    this.comparisonStatus = DataStatus.initial,
    this.surplusMaterials = const [],
    this.matchedMaterialIds = const {},
    this.photo1,
    this.photo2,
    this.submissionStatus = SubmissionStatus.initial,
    this.errorMessage,
  });

  InventoryState copyWith({
    DataStatus? listStatus,
    List<InventoryListItemVO>? inventoryList,
    int? totalTasks,
    bool? hasReachedMax,
    int? currentPage,
    DataStatus? detailStatus,
    InventoryDetailInfoVO? inventoryDetail,
    DataStatus? comparisonStatus,
    List<MaterialInfo>? surplusMaterials,
    Set<int>? matchedMaterialIds,
    String? photo1,
    String? photo2,
    SubmissionStatus? submissionStatus,
    String? errorMessage,
    bool resetPhotos = false, // 用于清空照片
  }) {
    return InventoryState(
      listStatus: listStatus ?? this.listStatus,
      inventoryList: inventoryList ?? this.inventoryList,
      totalTasks: totalTasks ?? this.totalTasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      detailStatus: detailStatus ?? this.detailStatus,
      inventoryDetail: inventoryDetail ?? this.inventoryDetail,
      comparisonStatus: comparisonStatus ?? this.comparisonStatus,
      surplusMaterials: surplusMaterials ?? this.surplusMaterials,
      matchedMaterialIds: matchedMaterialIds ?? this.matchedMaterialIds,
      photo1: resetPhotos ? null : photo1 ?? this.photo1,
      photo2: resetPhotos ? null : photo2 ?? this.photo2,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    inventoryList,
    totalTasks,
    hasReachedMax,
    currentPage,
    detailStatus,
    inventoryDetail,
    comparisonStatus,
    surplusMaterials,
    matchedMaterialIds,
    photo1,
    photo2,
    submissionStatus,
    errorMessage,
  ];
}
