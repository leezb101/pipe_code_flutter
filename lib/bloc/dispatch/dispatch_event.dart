part of 'dispatch_bloc.dart';

abstract class DispatchEvent extends Equatable {
  const DispatchEvent();

  @override
  List<Object> get props => [];
}

abstract class TracableDispatchEvent extends DispatchEvent {
  const TracableDispatchEvent(this.tracingContext);

  final TracingContext tracingContext;

  @override
  List<Object> get props => [tracingContext];
}

/// 加载调拨详情 (用于详情页, 确认页, 入库页)
class LoadDispatchDetail extends TracableDispatchEvent {
  final int dispatchId;

  const LoadDispatchDetail(this.dispatchId, super.tracingContext);

  @override
  List<Object> get props => [dispatchId, ...super.props];
}

class InitializeMaterialsFromCodes extends TracableDispatchEvent {
  final List<String> codes;

  const InitializeMaterialsFromCodes({
    required this.codes,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [codes, ...super.props];
}

/// 加载调拨申请页所需的前置数据
class LoadApplicationData extends TracableDispatchEvent {
  final List<MaterialVO> materials;

  const LoadApplicationData({
    required this.materials,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [materials, ...super.props];
}

/// 提交调拨申请
class SubmitDispatchApplication extends TracableDispatchEvent {
  final DoDispatchApplyVo request;

  const SubmitDispatchApplication({
    required this.request,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [request, ...super.props];
}

/// 提交调拨后入库
class SubmitDispatchSignIn extends TracableDispatchEvent {
  final DoDispatchSignInVo request;

  const SubmitDispatchSignIn({
    required this.request,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [request, ...super.props];
}

/// (入库页) 更新从扫码页返回的物料列表
class UpdateScannedMaterials extends DispatchEvent {
  final List<MaterialVO> scannedMaterials;

  const UpdateScannedMaterials(this.scannedMaterials);

  @override
  List<Object> get props => [scannedMaterials];
}

/// (入库页) 匹配扫码物料
class MatchScannedMaterial extends DispatchEvent {
  final MaterialInfoForBusiness scannedMaterial;

  const MatchScannedMaterial({required this.scannedMaterial});

  @override
  List<Object> get props => [scannedMaterial];
}

class UpdateWarehouseUsersList extends TracableDispatchEvent {
  final int warehouseId;

  const UpdateWarehouseUsersList({
    required this.warehouseId,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [warehouseId, ...super.props];
}

/// (申请页) 更新物料列表（追加扫码）
class UpdateApplicationMaterialWithAppendCodes extends TracableDispatchEvent {
  final List<String> appendingCodes;

  const UpdateApplicationMaterialWithAppendCodes({
    required this.appendingCodes,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [appendingCodes, ...super.props];
}

/// (申请页) 更新物料列表（移除扫码）
class UpdateApplicationMaterialWithRemoveCodes extends TracableDispatchEvent {
  final List<String> removingCodes;

  const UpdateApplicationMaterialWithRemoveCodes({
    required this.removingCodes,
    required TracingContext tracingContext,
  }) : super(tracingContext);

  @override
  List<Object> get props => [removingCodes, ...super.props];
}

/// (入库页) 通过批量二维码“继续扫码”追加匹配的物料
class AppendSigninMatchedByCodes extends TracableDispatchEvent {
  final List<String> codes;

  const AppendSigninMatchedByCodes(this.codes, super.tracingContext);

  @override
  List<Object> get props => [codes, ...super.props];
}

/// (入库页) 通过批量二维码“扫码剔除”移除已匹配的物料
class RemoveSigninMatchedByCodes extends TracableDispatchEvent {
  final List<String> codes;
  const RemoveSigninMatchedByCodes(this.codes, super.tracingContext);

  @override
  List<Object> get props => [codes, ...super.props];
}
