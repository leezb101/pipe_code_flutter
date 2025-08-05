/*
 * @Author: LeeZB
 * @Date: 2025-08-03
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-04 19:00:00
 * @copyright: Copyright © 2025 高新供水.
 */
import 'package:equatable/equatable.dart';
import 'package:pipe_code_flutter/models/material/material_info_for_business.dart';

sealed class ScrapEvent extends Equatable {
  const ScrapEvent();

  @override
  List<Object?> get props => [];
}

/// 加载报废详情（用于查看报废详情页面）
class LoadScrapDetail extends ScrapEvent {
  final int scrapId;

  const LoadScrapDetail({required this.scrapId});

  @override
  List<Object?> get props => [scrapId];
}

/// 初始化报废申请（从MaterialInfoForBusiness初始化）
class InitializeScrapSubmission extends ScrapEvent {
  final MaterialInfoForBusiness materialInfoForBusiness;

  const InitializeScrapSubmission({required this.materialInfoForBusiness});

  @override
  List<Object?> get props => [materialInfoForBusiness];
}

/// 从扫码列表初始化报废申请
class InitializeScrapFromCodes extends ScrapEvent {
  final List<String> codes;

  const InitializeScrapFromCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// 从扫码列表追加材料到现有报废申请
class AppendMaterialsFromCodes extends ScrapEvent {
  final List<String> codes;

  const AppendMaterialsFromCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// 通过扫码删除材料
class RemoveMaterialsFromCodes extends ScrapEvent {
  final List<String> codes;

  const RemoveMaterialsFromCodes({required this.codes});

  @override
  List<Object?> get props => [codes];
}

/// 更新整个照片列表
class UpdateScrapPhotos extends ScrapEvent {
  final List<String> photoPaths;

  const UpdateScrapPhotos({required this.photoPaths});

  @override
  List<Object?> get props => [photoPaths];
}

/// 更新物料数量
class UpdateMaterialQuantity extends ScrapEvent {
  final int materialId;
  final int quantity;

  const UpdateMaterialQuantity({
    required this.materialId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [materialId, quantity];
}

/// 提交报废申请
class SubmitScrap extends ScrapEvent {
  const SubmitScrap();
}

/// 清空所有数据，重置状态
class ClearScrapData extends ScrapEvent {
  const ClearScrapData();
}