import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/utils/logger.dart';

import 'qmap_event.dart';
import 'qmap_state.dart';

class QmapBloc extends Bloc<QmapEvent, QmapBlocState> {
  final MapApiService apiService;

  QmapBloc({required this.apiService}) : super(const QmapBlocState()) {
    on<CameraViewChanged>(_onCameraViewChanged);
    on<MarkerTapped>(_onMarkerTapped);
  }

  Future<void> _onCameraViewChanged(
    CameraViewChanged event,
    Emitter<QmapBlocState> emit,
  ) async {
    emit(state.copyWith(status: QmapStatus.loading, effect: null));
    try {
      final lat = event.center.latitude;
      final lng = event.center.longitude;
      final radius = event.radiusMeters;

      // 并行调用两个 API
      final results = await Future.wait([
        apiService.fetchMapWarehouses(lat, lng, radius),
        apiService.fetchMapProjects(lat, lng, radius),
      ]);

      final warehouseResult = results[0];
      final projectResult = results[1];
      // 处理 warehouse 数据
      List<Map<String, dynamic>> newStores = [];
      List<Map<String, dynamic>> storesToAdd = [];
      List<String> storeIdsToRemove = [];
      String? warehouseError;

      if (warehouseResult.isSuccess) {
        final raw = warehouseResult.data is List
            ? (warehouseResult.data as List)
            : <dynamic>[];
        Logger.debug('Fetched warehouses: $raw');
        // Normalize & deduplicate new stores by id (as string)
        final Map<String, Map<String, dynamic>> newStoreMap = {};
        for (final e in raw) {
          final idVal = e is Map ? e['id'] : null;
          final id = idVal?.toString();
          if (id == null || id.isEmpty) continue;
          final latStr = (e as Map)['lat']?.toString();
          final lngStr = e['lng']?.toString();
          final name = e['name']?.toString() ?? '';
          newStoreMap[id] = {
            'id': id,
            'lat': double.tryParse(latStr ?? '0') ?? 0,
            'lng': double.tryParse(lngStr ?? '0') ?? 0,
            'title': name, // 保留现有字段
            'name': name, // 增加 name 字段，与 title 等价
            'address': e['address']?.toString() ?? '',
            'isRealWarehouse': e['isRealWarehouse'] ?? false,
            // 保留所有原始字段
            ...e,
          };
        }

        // Build old map from state.stores
        final Map<String, Map<String, dynamic>> oldStoreMap = {
          for (final s in state.stores)
            if (s['id'] != null && s['id'].toString().isNotEmpty)
              s['id'].toString(): s,
        };

        // Compute diff
        // Add: in new but not in old
        newStoreMap.forEach((id, store) {
          if (!oldStoreMap.containsKey(id)) {
            storesToAdd.add(store);
          }
        });

        // Remove: in old but not in new
        oldStoreMap.forEach((id, _) {
          if (!newStoreMap.containsKey(id)) {
            storeIdsToRemove.add(id);
          }
        });

        newStores = newStoreMap.values.toList();
      } else {
        Logger.error('Failed to fetch warehouses: ${warehouseResult.msg}');
        warehouseError = warehouseResult.msg;
        newStores = state.stores; // 保持原有数据
      }

      // 处理 project 数据
      List<Map<String, dynamic>> newProjects = [];
      List<Map<String, dynamic>> projectsToAdd = [];
      List<String> projectIdsToRemove = [];
      String? projectError;

      if (projectResult.isSuccess) {
        final raw = projectResult.data is List
            ? (projectResult.data as List)
            : <dynamic>[];
        Logger.debug('Fetched projects: $raw');
        // Normalize & deduplicate new projects by id (as string)
        final Map<String, Map<String, dynamic>> newProjectMap = {};
        for (final e in raw) {
          final idVal = e is Map ? e['id'] : null;
          final id = idVal?.toString();
          if (id == null || id.isEmpty) continue;
          final latStr = (e as Map)['lat']?.toString();
          final lngStr = e['lng']?.toString();
          final name = e['name']?.toString() ?? '';
          newProjectMap[id] = {
            'id': id,
            'lat': double.tryParse(latStr ?? '0') ?? 0,
            'lng': double.tryParse(lngStr ?? '0') ?? 0,
            'title': name, // 保留现有字段
            'name': name, // 增加 name 字段，与 title 等价
            // 保留所有原始字段
            ...e,
          };
        }

        // Build old map from state.projects
        final Map<String, Map<String, dynamic>> oldProjectMap = {
          for (final p in state.projects)
            if (p['id'] != null && p['id'].toString().isNotEmpty)
              p['id'].toString(): p,
        };

        // Compute diff
        // Add: in new but not in old
        newProjectMap.forEach((id, project) {
          if (!oldProjectMap.containsKey(id)) {
            projectsToAdd.add(project);
          }
        });

        // Remove: in old but not in new
        oldProjectMap.forEach((id, _) {
          if (!newProjectMap.containsKey(id)) {
            projectIdsToRemove.add(id);
          }
        });

        newProjects = newProjectMap.values.toList();
      } else {
        Logger.error('Failed to fetch projects: ${projectResult.msg}');
        projectError = projectResult.msg;
        newProjects = state.projects; // 保持原有数据
      }

      // 构建最终的效果和状态
      final hasErrors = warehouseError != null || projectError != null;
      final List<String> errorMessages = [];
      if (warehouseError != null) errorMessages.add('仓库数据: $warehouseError');
      if (projectError != null) errorMessages.add('项目数据: $projectError');

      emit(
        state.copyWith(
          status: hasErrors ? QmapStatus.failure : QmapStatus.success,
          stores: newStores,
          projects: newProjects,
          errorMessage: errorMessages.isEmpty ? null : errorMessages.join('; '),
          effect: QmapEffect(
            storesToAdd: storesToAdd.isEmpty ? null : storesToAdd,
            storeIdsToRemove: storeIdsToRemove.isEmpty
                ? null
                : storeIdsToRemove,
            projectsToAdd: projectsToAdd.isEmpty ? null : projectsToAdd,
            projectIdsToRemove: projectIdsToRemove.isEmpty
                ? null
                : projectIdsToRemove,
            toastMessage: errorMessages.isEmpty
                ? null
                : errorMessages.join('; '),
            error: hasErrors,
          ),
        ),
      );
    } catch (e) {
      Logger.error('Error fetching map data: $e');
      emit(
        state.copyWith(
          status: QmapStatus.failure,
          errorMessage: e.toString(),
          effect: QmapEffect(
            toastMessage: 'Error fetching map data: $e',
            error: true,
          ),
        ),
      );
    }
  }

  void _onMarkerTapped(MarkerTapped event, Emitter<QmapBlocState> emit) {
    final id = event.markerId;
    if (id.startsWith('project_')) {
      final projectId = id.replaceFirst('project_', '');
      Logger.debug('Tapped on project marker: $projectId');
      // 不发出 toast 效果，只记录日志
    } else if (id.startsWith('store_')) {
      final storeId = id.replaceFirst('store_', '');
      Logger.debug('Tapped on store marker: $storeId');
      // 不发出 toast 效果，只记录日志
    } else {
      Logger.debug('Tapped on unknown marker: $id');
      // 对于未知类型的 marker，可以考虑发出错误 toast
      emit(
        state.copyWith(
          effect: QmapEffect(
            toastMessage: 'Unknown marker type: $id',
            error: true,
          ),
        ),
      );
    }
  }
}
