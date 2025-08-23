/*
 * @Author: LeeZB
 * @Date: 2025-08-23 17:00:00
 * @LastEditors: Leezb101 leezb101@126.com
 * @LastEditTime: 2025-08-23 17:00:00
 * @copyright: Copyright © 2025 高新供水.
 */

/// # 仓管员非项目入库 Bloc 使用指南
///
/// 本文档详细说明如何在UI层中使用 StorekeeperNonProjectBloc 来实现
/// 完整的仓管员非项目入库功能，特别关注错误处理和QR扫码状态管理。

/// ## 1. 核心设计理念
///
/// ### 1.1 优雅的错误处理
/// - **errorMessage字段**: 用于一次性错误提示，显示后可清除
/// - **operationMessage字段**: 用于操作结果提示（如"新增3个物料"）
/// - **主状态保持**: 错误不会破坏主要的业务状态
///
/// ### 1.2 QR扫码状态管理
/// - **状态快照**: 扫码前保存当前状态
/// - **取消恢复**: 用户取消扫码时恢复到之前状态
/// - **无缝体验**: 避免pending状态的用户体验问题

/// ## 2. 基本页面结构示例
///
/// ```dart
/// class StorekeeperNonProjectPage extends StatefulWidget {
///   @override
///   _StorekeeperNonProjectPageState createState() => _StorekeeperNonProjectPageState();
/// }
///
/// class _StorekeeperNonProjectPageState extends State<StorekeeperNonProjectPage> {
///   late StorekeeperNonProjectBloc _bloc;
///
///   @override
///   void initState() {
///     super.initState();
///     _bloc = BlocProvider.of<StorekeeperNonProjectBloc>(context);
///     // 页面初始化时加载仓库列表
///     _bloc.add(const LoadWarehouses());
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('非项目入库')),
///       body: BlocConsumer<StorekeeperNonProjectBloc, StorekeeperNonProjectState>(
///         listener: _handleStateChanges,
///         builder: _buildContent,
///       ),
///     );
///   }
///
///   /// 处理状态变化（错误提示、成功提示等）
///   void _handleStateChanges(BuildContext context, StorekeeperNonProjectState state) {
///     // 处理错误消息
///     if (state.hasErrorMessage) {
///       _showErrorMessage(context, state.errorMessage!);
///       // 显示后立即清除错误消息
///       _bloc.add(const ClearErrorMessage());
///     }
///
///     // 处理操作消息
///     if (state.hasOperationMessage) {
///       _showSuccessMessage(context, state.operationMessage!);
///       // 延迟清除操作消息
///       Future.delayed(Duration(seconds: 2), () {
///         _bloc.add(const ClearOperationMessage());
///       });
///     }
///
///     // 处理提交成功
///     if (state.status == StorekeeperNonProjectStatus.submitSuccess) {
///       _showSuccessDialog(context);
///     }
///   }
///
///   /// 构建页面内容
///   Widget _buildContent(BuildContext context, StorekeeperNonProjectState state) {
///     switch (state.status) {
///       case StorekeeperNonProjectStatus.initial:
///       case StorekeeperNonProjectStatus.loadingWarehouses:
///         return _buildLoadingWidget();
///
///       case StorekeeperNonProjectStatus.warehousesLoaded:
///         return _buildWarehouseSelection(state);
///
///       case StorekeeperNonProjectStatus.ready:
///       case StorekeeperNonProjectStatus.materialsUpdated:
///       case StorekeeperNonProjectStatus.imageUploaded:
///         return _buildMainContent(state);
///
///       case StorekeeperNonProjectStatus.scanning:
///         return _buildScanningIndicator();
///
///       case StorekeeperNonProjectStatus.processingScannedMaterials:
///         return _buildProcessingIndicator();
///
///       case StorekeeperNonProjectStatus.submitting:
///         return _buildSubmittingIndicator();
///
///       default:
///         return _buildMainContent(state);
///     }
///   }
/// }
/// ```

/// ## 3. 错误处理实现
///
/// ### 3.1 错误消息显示和清除
/// ```dart
/// void _showErrorMessage(BuildContext context, String message) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(
///       content: Text(message),
///       backgroundColor: Colors.red,
///       action: SnackBarAction(
///         label: '知道了',
///         textColor: Colors.white,
///         onPressed: () {
///           // SnackBar被手动关闭时也要清除错误消息
///           _bloc.add(const ClearErrorMessage());
///         },
///       ),
///     ),
///   );
/// }
///
/// void _showSuccessMessage(BuildContext context, String message) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(
///       content: Text(message),
///       backgroundColor: Colors.green,
///       duration: Duration(seconds: 2),
///     ),
///   );
/// }
/// ```

/// ## 4. QR扫码集成
///
/// ### 4.1 启动扫码流程
/// ```dart
/// Future<void> _startScanning(QrScanOperation operation) async {
///   // 1. 通知Bloc开始扫码（保存当前状态）
///   _bloc.add(StartScanning(operation));
///
///   // 2. 构建扫码配置
///   final config = _bloc.buildQrScanConfig(operation);
///
///   // 3. 导航到扫码页面
///   final result = await Navigator.pushNamed(
///     context,
///     '/qr-scan',
///     arguments: config,
///   );
///
///   // 4. 处理扫码结果
///   if (result != null && result is List<dynamic>) {
///     // 用户完成了扫码
///     final qrResults = result.whereType<QrScanResult>().toList();
///     final codes = qrResults.map((r) => r.code).toList();
///
///     _bloc.add(ProcessScannedCodes(
///       codes: codes,
///       operation: operation,
///     ));
///   } else {
///     // 用户取消了扫码
///     _bloc.add(const CancelScanning());
///   }
/// }
/// ```
///
/// ### 4.2 扫码按钮实现
/// ```dart
/// Widget _buildScanButtons(StorekeeperNonProjectState state) {
///   return Column(
///     children: [
///       // 主扫码按钮
///       ElevatedButton.icon(
///         onPressed: state.status == StorekeeperNonProjectStatus.scanning
///             ? null
///             : () => _startScanning(
///                 state.hasMaterials
///                     ? QrScanOperation.append
///                     : QrScanOperation.initial
///               ),
///         icon: Icon(Icons.qr_code_scanner),
///         label: Text(state.hasMaterials ? '追加扫码' : '扫码入库'),
///       ),
///
///       // 移除扫码按钮（仅在有物料时显示）
///       if (state.hasMaterials) ...[
///         SizedBox(height: 8),
///         ElevatedButton.icon(
///           onPressed: state.status == StorekeeperNonProjectStatus.scanning
///               ? null
///               : () => _startScanning(QrScanOperation.remove),
///           icon: Icon(Icons.remove_circle),
///           label: Text('扫码剔除'),
///           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
///         ),
///       ],
///     ],
///   );
/// }
/// ```

/// ## 5. 完整的UI状态管理
///
/// ### 5.1 仓库选择
/// ```dart
/// Widget _buildWarehouseSelection(StorekeeperNonProjectState state) {
///   return Column(
///     children: [
///       Text('请选择仓库'),
///       if (state.warehouses.isEmpty)
///         Text('暂无可用仓库')
///       else
///         ...state.warehouses.map((warehouse) =>
///           ListTile(
///             title: Text(warehouse.name ?? '未知仓库'),
///             subtitle: Text(warehouse.address ?? ''),
///             onTap: () => _bloc.add(SelectWarehouse(warehouse)),
///           ),
///         ),
///     ],
///   );
/// }
/// ```
///
/// ### 5.2 物料列表显示
/// ```dart
/// Widget _buildMaterialsList(StorekeeperNonProjectState state) {
///   if (!state.hasMaterials) {
///     return Center(child: Text('暂无物料，请扫码添加'));
///   }
///
///   return ListView.builder(
///     itemCount: state.materials.length,
///     itemBuilder: (context, index) {
///       final material = state.materials[index];
///       return ListTile(
///         title: Text(material.baseInfo.prodNm ?? '未知物料'),
///         subtitle: Text('规格: ${material.baseInfo.spec ?? '未知'}'),
///         trailing: IconButton(
///           icon: Icon(Icons.delete, color: Colors.red),
///           onPressed: () => _bloc.add(RemoveMaterial(material)),
///         ),
///       );
///     },
///   );
/// }
/// ```
///
/// ### 5.3 图片上传集成
/// ```dart
/// Widget _buildImageUpload(StorekeeperNonProjectState state) {
///   return ImageUploadWidget(
///     title: '上传现场照片',
///     states: state.imageUrl != null
///         ? [FileUploadState(/* ... */)]
///         : [],
///     onAdd: (files) => _handleImageUpload(files),
///     onRemove: (id) => _bloc.add(const RemoveImage()),
///     onRetry: (id) => _handleImageRetry(id),
///     maxImages: 1,
///     requiredPhotoCount: 1,
///   );
/// }
///
/// void _handleImageUpload(List<File> files) async {
///   if (files.isEmpty) return;
///
///   _bloc.add(const StartImageUpload());
///
///   try {
///     // 上传图片逻辑
///     final imageUrl = await uploadImage(files.first);
///     _bloc.add(ImageUploadCompleted(imageUrl));
///   } catch (e) {
///     _bloc.add(ImageUploadFailed(e.toString()));
///   }
/// }
/// ```

/// ## 6. 状态指示器
///
/// ### 6.1 加载状态
/// ```dart
/// Widget _buildLoadingWidget() {
///   return Center(
///     child: Column(
///       mainAxisAlignment: MainAxisAlignment.center,
///       children: [
///         CircularProgressIndicator(),
///         SizedBox(height: 16),
///         Text('加载中...'),
///       ],
///     ),
///   );
/// }
///
/// Widget _buildScanningIndicator() {
///   return Center(
///     child: Column(
///       mainAxisAlignment: MainAxisAlignment.center,
///       children: [
///         CircularProgressIndicator(),
///         SizedBox(height: 16),
///         Text('扫码中...'),
///         TextButton(
///           onPressed: () => _bloc.add(const CancelScanning()),
///           child: Text('取消扫码'),
///         ),
///       ],
///     ),
///   );
/// }
/// ```

/// ## 7. 提交流程
///
/// ### 7.1 提交按钮和验证
/// ```dart
/// Widget _buildSubmitButton(StorekeeperNonProjectState state) {
///   return ElevatedButton(
///     onPressed: state.canSubmit && state.status != StorekeeperNonProjectStatus.submitting
///         ? () => _bloc.add(const SubmitEntry())
///         : null,
///     child: state.status == StorekeeperNonProjectStatus.submitting
///         ? Row(
///             mainAxisSize: MainAxisSize.min,
///             children: [
///               SizedBox(
///                 width: 20,
///                 height: 20,
///                 child: CircularProgressIndicator(strokeWidth: 2),
///               ),
///               SizedBox(width: 8),
///               Text('提交中...'),
///             ],
///           )
///         : Text('提交入库'),
///   );
/// }
///
/// void _showSuccessDialog(BuildContext context) {
///   showDialog(
///     context: context,
///     barrierDismissible: false,
///     builder: (context) => AlertDialog(
///       title: Text('入库成功'),
///       content: Text('物料已成功入库'),
///       actions: [
///         TextButton(
///           onPressed: () {
///             Navigator.of(context).pop();
///             // 重置状态准备下一次入库
///             _bloc.add(const ResetState());
///           },
///           child: Text('继续入库'),
///         ),
///         TextButton(
///           onPressed: () {
///             Navigator.of(context).pop();
///             Navigator.of(context).pop(); // 返回上一页
///           },
///           child: Text('完成'),
///         ),
///       ],
///     ),
///   );
/// }
/// ```

/// ## 8. 最佳实践
///
/// ### 8.1 生命周期管理
/// - 在initState中加载初始数据
/// - 在dispose中清理资源
/// - 合理使用BlocConsumer的listener
///
/// ### 8.2 错误处理
/// - 及时清除错误消息避免重复显示
/// - 区分错误消息和操作消息的显示方式
/// - 提供用户友好的错误提示
///
/// ### 8.3 状态管理
/// - 利用状态快照功能处理复杂交互
/// - 合理使用canSubmit等计算属性
/// - 避免在UI中进行复杂的状态计算
///
/// ### 8.4 性能优化
/// - 使用BlocBuilder只在必要时重建UI
/// - 合理分割Widget减小重建范围
/// - 避免在listener中进行耗时操作

void main() {
  // 本文件仅用于文档说明，不包含可执行代码
}
