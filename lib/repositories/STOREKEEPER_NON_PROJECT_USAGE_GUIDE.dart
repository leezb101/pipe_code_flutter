/*
 * @Author: LeeZB
 * @Date: 2025-08-23 16:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 16:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// StorekeeperNonProjectRepository 使用指南
///
/// 本文档说明如何在Bloc层中使用 StorekeeperNonProjectRepository 来实现
/// "仓管员非项目入库"功能的完整业务流程。

/// ## 1. Repository功能概述
///
/// StorekeeperNonProjectRepository 提供以下核心功能：
///
/// ### 1.1 仓库管理
/// - `getStorekeeperWarehouses()`: 获取仓管员管理的仓库列表
///
/// ### 1.2 物料扫码处理
/// - `processScannedMaterials()`: 处理扫码操作，支持三种模式：
///   - **初次扫码** (QrScanOperation.initial): 第一次扫码添加物料
///   - **追加扫码** (QrScanOperation.append): 在已有物料基础上追加新物料，自动去重
///   - **移除扫码** (QrScanOperation.remove): 从已有物料中移除指定物料
///
/// ### 1.3 数据校验
/// - `validateSubmissionData()`: 校验提交数据的完整性
///
/// ### 1.4 入库提交
/// - `submitNonProjectEntry()`: 提交非项目入库请求

/// ## 2. 在Bloc中的使用示例
///
/// ```dart
/// class StorekeeperNonProjectBloc extends Bloc<StorekeeperNonProjectEvent, StorekeeperNonProjectState> {
///   final StorekeeperNonProjectRepository _repository;
///   final QrScanFlowService _qrScanFlowService;
///
///   StorekeeperNonProjectBloc({
///     required StorekeeperNonProjectRepository repository,
///     required QrScanFlowService qrScanFlowService,
///   }) : _repository = repository,
///        _qrScanFlowService = qrScanFlowService,
///        super(const StorekeeperNonProjectState()) {
///     on<LoadWarehouses>(_onLoadWarehouses);
///     on<SelectWarehouse>(_onSelectWarehouse);
///     on<StartScanning>(_onStartScanning);
///     on<ProcessScannedCodes>(_onProcessScannedCodes);
///     on<UploadImage>(_onUploadImage);
///     on<UpdateDescription>(_onUpdateDescription);
///     on<SubmitEntry>(_onSubmitEntry);
///   }
///
///   /// 加载仓库列表
///   Future<void> _onLoadWarehouses(
///     LoadWarehouses event,
///     Emitter<StorekeeperNonProjectState> emit,
///   ) async {
///     emit(state.copyWith(status: StorekeeperNonProjectStatus.loading));
///
///     final result = await _repository.getStorekeeperWarehouses();
///
///     if (result.isSuccess) {
///       emit(state.copyWith(
///         status: StorekeeperNonProjectStatus.success,
///         warehouses: result.data ?? [],
///       ));
///     } else {
///       emit(state.copyWith(
///         status: StorekeeperNonProjectStatus.failure,
///         errorMessage: result.msg,
///       ));
///     }
///   }
///
///   /// 处理扫码结果
///   Future<void> _onProcessScannedCodes(
///     ProcessScannedCodes event,
///     Emitter<StorekeeperNonProjectState> emit,
///   ) async {
///     emit(state.copyWith(status: StorekeeperNonProjectStatus.processing));
///
///     final result = await _repository.processScannedMaterials(
///       event.codes,
///       event.operation,
///       state.materials,
///     );
///
///     if (result.isSuccess) {
///       final processResult = result.data!;
///
///       emit(state.copyWith(
///         status: StorekeeperNonProjectStatus.success,
///         materials: processResult.processedMaterials,
///         lastOperationSummary: processResult.getOperationSummary(),
///       ));
///
///       // 如果有需要提示的信息，显示Toast
///       if (processResult.hasNotifications) {
///         _showNotifications(processResult);
///       }
///     } else {
///       emit(state.copyWith(
///         status: StorekeeperNonProjectStatus.failure,
///         errorMessage: result.msg,
///       ));
///     }
///   }
///
///   /// 提交入库
///   Future<void> _onSubmitEntry(
///     SubmitEntry event,
///     Emitter<StorekeeperNonProjectState> emit,
///   ) async {
///     emit(state.copyWith(status: StorekeeperNonProjectStatus.submitting));
///
///     final result = await _repository.submitNonProjectEntry(
///       warehouseId: state.selectedWarehouse!.id,
///       materials: state.materials,
///       imageUrl: state.imageUrl!,
///       description: state.description,
///     );
///
///     if (result.isSuccess) {
///       emit(state.copyWith(
///         status: StorekeeperNonProjectStatus.submitSuccess,
///       ));
///     } else {
///       emit(state.copyWith(
///         status: StorekeeperNonProjectStatus.failure,
///         errorMessage: result.msg,
///       ));
///     }
///   }
///
///   void _showNotifications(MaterialProcessResult result) {
///     // 显示重复物料提示
///     if (result.duplicateCount > 0) {
///       // 显示Toast: "忽略了 X 个重复物料"
///     }
///
///     // 显示跳过物料提示
///     if (result.skippedCount > 0) {
///       // 显示Toast: "跳过了 X 个不存在的物料"
///     }
///
///     // 显示错误信息
///     if (result.errorMessages.isNotEmpty) {
///       // 显示Toast: 错误详情
///     }
///   }
/// }
/// ```

/// ## 3. 与QrScanFlowService的集成
///
/// Repository与QrScanFlowService配合使用，实现完整的扫码流程：
///
/// ```dart
/// // 在页面中启动扫码
/// Future<void> _startScanning(QrScanOperation operation) async {
///   final request = QrScanFlowRequest(
///     operation: operation,
///     currentCodes: state.materials.map((m) => m.baseInfo.materialCode ?? '').where((code) => code.isNotEmpty).toList(),
///     batch: true,
///     title: _getScanTitle(operation),
///     skipValidation: false,
///   );
///
///   final config = _qrScanFlowService.buildConfig(request);
///
///   // 导航到扫码页面
///   final result = await Navigator.pushNamed(context, '/qr-scan', arguments: config);
///
///   if (result != null) {
///     final flowResult = _qrScanFlowService.normalize(request, result as List<dynamic>);
///
///     // 将扫码结果传递给Bloc处理
///     bloc.add(ProcessScannedCodes(
///       codes: flowResult.rawResults.map((r) => r.code).toList(),
///       operation: operation,
///     ));
///   }
/// }
///
/// String _getScanTitle(QrScanOperation operation) {
///   switch (operation) {
///     case QrScanOperation.initial:
///       return '扫码入库';
///     case QrScanOperation.append:
///       return '追加扫码';
///     case QrScanOperation.remove:
///       return '扫码剔除';
///   }
/// }
/// ```

/// ## 4. 完整的页面流程
///
/// ### 4.1 页面初始化
/// 1. 调用 `getStorekeeperWarehouses()` 获取仓库列表
/// 2. 用户选择仓库
///
/// ### 4.2 物料管理
/// 1. **初次扫码**: 用户点击"扫码入库"，使用 `QrScanOperation.initial`
/// 2. **追加物料**: 用户点击"扫码入库"，使用 `QrScanOperation.append`
/// 3. **移除物料**: 用户点击"扫码剔除"，使用 `QrScanOperation.remove`
///
/// ### 4.3 数据完善
/// 1. 用户上传图片 (使用 ImageUploadWidget)
/// 2. 用户填写描述信息
///
/// ### 4.4 提交入库
/// 1. 系统自动校验数据完整性
/// 2. 调用 `submitNonProjectEntry()` 提交入库
///
/// ## 5. 错误处理
///
/// Repository提供了完善的错误处理机制：
///
/// - **网络错误**: 通过Result的isFailure属性判断，展示用户友好的错误信息
/// - **数据校验错误**: validateSubmissionData()提供详细的校验失败原因
/// - **业务逻辑错误**: MaterialProcessResult包含详细的操作结果和错误信息
///
/// ## 6. 性能优化建议
///
/// - **物料去重**: Repository内部使用Set进行O(1)时间复杂度的去重操作
/// - **批量处理**: 扫码支持批量模式，一次处理多个二维码
/// - **状态管理**: 合理使用Bloc状态，避免不必要的UI重建
///
/// ## 7. 测试建议
///
/// - **单元测试**: 针对Repository的各个方法编写单元测试
/// - **集成测试**: 测试Repository与QrScanFlowService的集成
/// - **UI测试**: 测试完整的用户交互流程

void main() {
  // 本文件仅用于文档说明，不包含可执行代码
}
