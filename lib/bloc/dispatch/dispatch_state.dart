part of 'dispatch_bloc.dart';

enum DispatchStatus {
  initial, // 初始状态
  loading, // 通用加载中
  loadingSourceInfo, // 申请页正在加载发出方信息（不阻塞主UI）
  success, // 通用成功
  failure, // 通用失败
  applySuccess, // 调拨申请提交成功
  signInSuccess, // 调拨入库成功
}

class DispatchState extends Equatable {
  const DispatchState({
    this.status = DispatchStatus.initial,
    this.dispatchDetail,
    this.materialList,
    this.materialIds,
    this.errorMaterials = const [], // 错误材料列表
    this.sourceProject,
    this.sourceWarehouse,
    this.availableProjects = const [],
    this.availableWarehouses = const [],
    this.availableWarehouseUsers = const [],
    this.scannedMaterials,
    this.matchedMaterials = const {},
    this.matchMessage,
    this.errorMessage,
    this.sourceProjectError,
    this.sourceWarehouseError,
    this.availableProjectsError,
    this.availableWarehousesError,
  });

  // 当前状态
  final DispatchStatus status;
  // 调拨详情 (详情页, 确认页, 入库页)
  final DispatchDetailVo? dispatchDetail;
  // 申请的物料列表 (申请页)
  final List<MaterialVO>? materialList;
  // 发出方项目信息 (申请页)
  final ProjectSimpleVo? sourceProject;
  final Set<int>? materialIds;
  // 错误材料列表 (申请页)
  final List<dynamic> errorMaterials;
  // 发出方仓库信息 (申请页)
  final WarehouseVO? sourceWarehouse;
  // 可选的目标项目列表 (申请页)
  final List<ProjectSimpleVo> availableProjects;
  // 可选的目标仓库列表 (申请页)
  final List<WarehouseVO> availableWarehouses;
  // 可选的发出方仓库管理员 (申请页)
  final List<CommonUserVO> availableWarehouseUsers;
  // 调拨入库时扫描的物料 (入库页)
  final List<MaterialVO>? scannedMaterials;
  // 已匹配的物料 (入库页)
  final Set<MaterialVO> matchedMaterials;
  // 匹配消息 (入库页)
  final String? matchMessage;
  // 错误信息
  final String? errorMessage;
  // 各数据项的错误信息
  final String? sourceProjectError;
  final String? sourceWarehouseError;
  final String? availableProjectsError;
  final String? availableWarehousesError;

  DispatchState copyWith({
    DispatchStatus? status,
    DispatchDetailVo? dispatchDetail,
    List<MaterialVO>? materialList,
    Set<int>? materialIds,
    List<dynamic>? errorMaterials,
    ProjectSimpleVo? sourceProject,
    WarehouseVO? sourceWarehouse,
    List<ProjectSimpleVo>? availableProjects,
    List<WarehouseVO>? availableWarehouses,
    List<CommonUserVO>? availableWarehouseUsers,
    List<MaterialVO>? scannedMaterials,
    Set<MaterialVO>? matchedMaterials,
    String? matchMessage,
    String? errorMessage,
    String? sourceProjectError,
    String? sourceWarehouseError,
    String? availableProjectsError,
    String? availableWarehousesError,
  }) {
    return DispatchState(
      status: status ?? this.status,
      dispatchDetail: dispatchDetail ?? this.dispatchDetail,
      materialList: materialList ?? this.materialList,
      materialIds: materialIds ?? this.materialIds,
      errorMaterials: errorMaterials ?? this.errorMaterials,
      sourceProject: sourceProject ?? this.sourceProject,
      sourceWarehouse: sourceWarehouse ?? this.sourceWarehouse,
      availableProjects: availableProjects ?? this.availableProjects,
      availableWarehouses: availableWarehouses ?? this.availableWarehouses,
      availableWarehouseUsers:
          availableWarehouseUsers ?? this.availableWarehouseUsers,
      scannedMaterials: scannedMaterials ?? this.scannedMaterials,
      matchedMaterials: matchedMaterials ?? this.matchedMaterials,
      matchMessage: matchMessage ?? this.matchMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      sourceProjectError: sourceProjectError ?? this.sourceProjectError,
      sourceWarehouseError: sourceWarehouseError ?? this.sourceWarehouseError,
      availableProjectsError:
          availableProjectsError ?? this.availableProjectsError,
      availableWarehousesError:
          availableWarehousesError ?? this.availableWarehousesError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dispatchDetail,
    materialList,
    materialIds,
    errorMaterials,
    sourceProject,
    sourceWarehouse,
    availableProjects,
    availableWarehouses,
    availableWarehouseUsers,
    scannedMaterials,
    matchedMaterials,
    matchMessage,
    errorMessage,
    sourceProjectError,
    sourceWarehouseError,
    availableProjectsError,
    availableWarehousesError,
  ];
}
