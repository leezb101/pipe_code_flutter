/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: LeeZB
 * @LastEditTime: 2025-08-03
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/acceptance/material_vo.dart';
import 'package:pipe_code_flutter/models/scrap/scrap_models.dart';
import 'package:pipe_code_flutter/models/material/sync_vendor_data_error.dart';

abstract class ScrapState extends Equatable {
  const ScrapState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class ScrapInitial extends ScrapState {
  const ScrapInitial();
}

/// 加载中状态
class ScrapLoading extends ScrapState {
  const ScrapLoading();
}

/// 报废详情加载成功（查看详情页面使用）
class ScrapDetailLoaded extends ScrapState {
  final ScrapDetailVO scrapDetail;

  const ScrapDetailLoaded({required this.scrapDetail});

  @override
  List<Object?> get props => [scrapDetail];
}

/// 报废申请准备状态（提交申请页面使用）
class ScrapSubmissionReady extends ScrapState {
  final List<MaterialVO> materialList;
  final List<SyncVendorDataError> errorMaterials;
  final List<String> photoUrls;
  final bool isSubmitting;
  final String? errorMessage; // 一次性错误信息

  const ScrapSubmissionReady({
    this.materialList = const [],
    this.errorMaterials = const [],
    this.photoUrls = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    materialList,
    errorMaterials,
    photoUrls,
    isSubmitting,
    errorMessage,
  ];

  ScrapSubmissionReady copyWith({
    List<MaterialVO>? materialList,
    List<SyncVendorDataError>? errorMaterials,
    List<String>? photoUrls,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ScrapSubmissionReady(
      materialList: materialList ?? this.materialList,
      errorMaterials: errorMaterials ?? this.errorMaterials,
      photoUrls: photoUrls ?? this.photoUrls,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

/// 提交成功状态
class ScrapSubmitted extends ScrapState {
  final String message;

  const ScrapSubmitted({this.message = '报废申请提交成功'});

  @override
  List<Object?> get props => [message];
}

class ScrapFatalError extends ScrapState {
  final String message;
  const ScrapFatalError({required this.message});

  @override
  List<Object?> get props => [message];
}
