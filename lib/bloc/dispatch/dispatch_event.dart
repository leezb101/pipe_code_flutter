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
