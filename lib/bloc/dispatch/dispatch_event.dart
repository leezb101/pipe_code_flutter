part of 'dispatch_bloc.dart';

abstract class DispatchEvent extends Equatable {
  const DispatchEvent();

  @override
  List<Object> get props => [];
}

/// 加载调拨详情 (用于详情页, 确认页, 入库页)
class LoadDispatchDetail extends DispatchEvent {
  final int dispatchId;

  const LoadDispatchDetail(this.dispatchId);

  @override
  List<Object> get props => [dispatchId];
}

class InitializeMaterialsFromCodes extends DispatchEvent {
  final List<String> codes;

  const InitializeMaterialsFromCodes({required this.codes});

  @override
  List<Object> get props => [codes];
}

/// 加载调拨申请页所需的前置数据
class LoadApplicationData extends DispatchEvent {
  final List<MaterialVO> materials;

  const LoadApplicationData(this.materials);

  @override
  List<Object> get props => [materials];
}

/// 提交调拨申请
class SubmitDispatchApplication extends DispatchEvent {
  final DoDispatchApplyVo request;

  const SubmitDispatchApplication(this.request);

  @override
  List<Object> get props => [request];
}

/// 审核调拨请求
class AuditDispatch extends DispatchEvent {
  final CommonDoBusinessAuditVO request;

  const AuditDispatch(this.request);

  @override
  List<Object> get props => [request];
}

/// 提交调拨后入库
class SubmitDispatchSignIn extends DispatchEvent {
  final DoDispatchSignInVo request;

  const SubmitDispatchSignIn(this.request);

  @override
  List<Object> get props => [request];
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

class UpdateWarehouseUsersList extends DispatchEvent {
  final int warehouseId;
  const UpdateWarehouseUsersList(this.warehouseId);

  @override
  List<Object> get props => [warehouseId];
}

/// (申请页) 更新物料列表（追加扫码）
class UpdateApplicationMaterialWithAppendCodes extends DispatchEvent {
  final List<String> appendingCodes;
  const UpdateApplicationMaterialWithAppendCodes(this.appendingCodes);

  @override
  List<Object> get props => [appendingCodes];
}

/// (申请页) 更新物料列表（移除扫码）
class UpdateApplicationMaterialWithRemoveCodes extends DispatchEvent {
  final List<String> removingCodes;
  const UpdateApplicationMaterialWithRemoveCodes(this.removingCodes);

  @override
  List<Object> get props => [removingCodes];
}
