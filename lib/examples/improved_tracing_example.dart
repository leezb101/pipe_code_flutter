// // 这是一个示例文件，展示如何使用改进后的 TracingManager
// // 文件位置：lib/bloc/acceptance/acceptance_bloc_improved.dart

// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../services/tracing/improved_tracing_manager.dart';
// import '../../utils/logger.dart';
// import 'acceptance_event.dart';
// import 'acceptance_state.dart';

// class ImprovedAcceptanceBloc extends Bloc<AcceptanceEvent, AcceptanceState> {
//   final ImprovedTracingManager _tracingManager;

//   ImprovedAcceptanceBloc(
//     this._tracingManager,
//     // ... 其他依赖
//   ) : super(const AcceptanceInitial()) {
//     on<LoadAcceptanceUsers>(_onLoadAcceptanceUsersImproved);
//     on<LoadWarehouseList>(_onLoadWarehouseListImproved);
//   }

//   /// 改进版本：支持并发的用户加载
//   Future<void> _onLoadAcceptanceUsersImproved(
//     LoadAcceptanceUsers event,
//     Emitter<AcceptanceState> emit,
//   ) async {
//     // 创建增强的追踪上下文
//     final operationContext = _tracingManager.createOperationContext(
//       source: 'acceptance_page',
//       action: 'load_users',
//       description: '验收申请 - 加载验收用户',
//       // 可以添加更多上下文信息
//       entityId: event.projectId.toString(),
//     );

//     await _tracingManager.scopeOperation(operationContext, () async {
//       try {
//         emit(const AcceptanceUsersLoading());
        
//         Logger.info(
//           'Loading acceptance users for project: ${event.projectId}',
//           tag: 'ImprovedAcceptanceBloc',
//         );

//         // 模拟网络请求
//         // final result = await _repository.getAcceptanceUsers(
//         //   projectId: event.projectId,
//         // );

//         // 模拟数据
//         await Future.delayed(const Duration(milliseconds: 500));
        
//         // if (result.isSuccess && result.data != null) {
//         //   emit(AcceptanceUsersLoaded(acceptUserInfo: result.data!));
//         // } else {
//         //   emit(AcceptanceError(message: result.msg));
//         // }
        
//         Logger.info('Acceptance users loaded successfully', tag: 'ImprovedAcceptanceBloc');
//       } catch (e) {
//         Logger.error('Error loading acceptance users: $e', tag: 'ImprovedAcceptanceBloc');
//         emit(AcceptanceError(message: '加载验收用户失败：$e'));
//       }
//     });
//   }

//   /// 改进版本：支持并发的仓库列表加载
//   Future<void> _onLoadWarehouseListImproved(
//     LoadWarehouseList event,
//     Emitter<AcceptanceState> emit,
//   ) async {
//     // 创建增强的追踪上下文
//     final operationContext = _tracingManager.createOperationContext(
//       source: 'acceptance_page',
//       action: 'load_warehouses',
//       description: '验收申请 - 加载仓库列表',
//     );

//     await _tracingManager.scopeOperation(operationContext, () async {
//       try {
//         emit(const WarehouseListLoading());
        
//         Logger.info('Loading warehouse list', tag: 'ImprovedAcceptanceBloc');

//         // 模拟网络请求
//         // final result = await _repository.getWarehouseList();

//         // 模拟数据
//         await Future.delayed(const Duration(milliseconds: 800));
        
//         // if (result.isSuccess && result.data != null) {
//         //   emit(WarehouseListLoaded(warehouseList: result.data!));
//         // } else {
//         //   emit(AcceptanceError(message: result.msg));
//         // }
        
//         Logger.info('Warehouse list loaded successfully', tag: 'ImprovedAcceptanceBloc');
//       } catch (e) {
//         Logger.error('Error loading warehouse list: $e', tag: 'ImprovedAcceptanceBloc');
//         emit(AcceptanceError(message: '获取仓库列表失败：$e'));
//       }
//     });
//   }

//   /// 示例：并发执行多个操作
//   Future<void> loadInitialDataConcurrently(
//     int projectId,
//     Emitter<AcceptanceState> emit,
//   ) async {
//     // 创建父操作上下文
//     final parentContext = _tracingManager.createOperationContext(
//       source: 'acceptance_page',
//       action: 'load_initial_data',
//       description: '验收申请 - 初始化数据加载',
//     );

//     await _tracingManager.scopeOperation(parentContext, () async {
//       // 并发执行子操作
//       final futures = [
//         // 加载用户数据
//         _tracingManager.scopeOperation(
//           _tracingManager.createOperationContext(
//             source: 'acceptance_page',
//             action: 'load_users',
//             description: '验收申请 - 加载验收用户',
//             parentId: parentContext.id, // 设置父操作ID
//             entityId: projectId.toString(),
//           ),
//           () async {
//             // 用户加载逻辑
//             await Future.delayed(const Duration(milliseconds: 500));
//             Logger.info('Users loaded in concurrent operation', tag: 'ImprovedAcceptanceBloc');
//           },
//         ),
        
//         // 加载仓库列表
//         _tracingManager.scopeOperation(
//           _tracingManager.createOperationContext(
//             source: 'acceptance_page',
//             action: 'load_warehouses',
//             description: '验收申请 - 加载仓库列表',
//             parentId: parentContext.id, // 设置父操作ID
//           ),
//           () async {
//             // 仓库加载逻辑
//             await Future.delayed(const Duration(milliseconds: 800));
//             Logger.info('Warehouses loaded in concurrent operation', tag: 'ImprovedAcceptanceBloc');
//           },
//         ),
//       ];

//       // 等待所有操作完成
//       await Future.wait(futures);
      
//       Logger.info('All initial data loaded successfully', tag: 'ImprovedAcceptanceBloc');
//     });
//   }
// }

// /// 示例：页面级别的使用
// class ImprovedAcceptancePageExample {
//   final ImprovedTracingManager _tracingManager = ImprovedTracingManager();

//   Future<void> handleUserAction(String actionTitle) async {
//     // 方式1：使用便利方法
//     await _tracingManager.scopeActionWithTitle(actionTitle, () async {
//       // 执行具体的操作逻辑
//       await Future.delayed(const Duration(milliseconds: 200));
//     });

//     // 方式2：创建自定义上下文
//     final context = _tracingManager.createOperationContext(
//       source: 'acceptance_page',
//       action: 'custom_action',
//       description: '验收申请 - $actionTitle',
//       entityId: 'user123',
//     );

//     await _tracingManager.scopeOperation(context, () async {
//       // 执行具体的操作逻辑
//       await Future.delayed(const Duration(milliseconds: 300));
//     });
//   }

//   /// 获取性能统计信息
//   void printPerformanceStats() {
//     final stats = _tracingManager.getPerformanceStats();
//     print('Performance Stats: $stats');
//   }

//   /// 查看操作链
//   void printOperationChain(String operationId) {
//     final chain = _tracingManager.getOperationChain(operationId);
//     print('Operation Chain for $operationId:');
//     for (final context in chain) {
//       print('  - ${context.description} (${context.duration?.inMilliseconds}ms)');
//     }
//   }
// }
