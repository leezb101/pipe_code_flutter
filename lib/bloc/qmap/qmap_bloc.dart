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
      final result = await apiService.fetchMapWarehouses(lat, lng, radius);
      if (result.isSuccess) {
        final raw = result.data is List ? (result.data as List) : <dynamic>[];
        Logger.debug('Fetched warehouses: $raw');
        // Normalize & deduplicate new stores by id (as string)
        final Map<String, Map<String, dynamic>> newStoreMap = {};
        for (final e in raw) {
          final idVal = e is Map ? e['id'] : null;
          final id = idVal?.toString();
          if (id == null || id.isEmpty) continue;
          final latStr = (e as Map)['lat']?.toString();
          final lngStr = e['lng']?.toString();
          newStoreMap[id] = {
            'id': id,
            'lat': double.tryParse(latStr ?? '0') ?? 0,
            'lng': double.tryParse(lngStr ?? '0') ?? 0,
            'title': e['name']?.toString() ?? '',
          };
        }

        // Build old map from state.stores
        final Map<String, Map<String, dynamic>> oldStoreMap = {
          for (final s in state.stores)
            if (s['id'] != null && s['id'].toString().isNotEmpty)
              s['id'].toString(): s,
        };

        // Compute diff
        final List<Map<String, dynamic>> toAdd = [];
        final List<String> toRemove = [];

        // Add: in new but not in old
        newStoreMap.forEach((id, store) {
          if (!oldStoreMap.containsKey(id)) {
            toAdd.add(store);
          }
        });

        // Remove: in old but not in new
        oldStoreMap.forEach((id, _) {
          if (!newStoreMap.containsKey(id)) {
            toRemove.add(id);
          }
        });

        final newStores = newStoreMap.values.toList();

        emit(
          state.copyWith(
            status: QmapStatus.success,
            stores: newStores,
            effect: QmapEffect(storesToAdd: toAdd, storeIdsToRemove: toRemove),
          ),
        );
      } else {
        Logger.error('Failed to fetch warehouses: ${result.msg}');
        emit(
          state.copyWith(
            status: QmapStatus.failure,
            errorMessage: result.msg,
            effect: QmapEffect(
              toastMessage: 'Failed to fetch warehouses: ${result.msg}',
              error: true,
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error('Error fetching warehouses: $e');
      emit(
        state.copyWith(
          status: QmapStatus.failure,
          errorMessage: e.toString(),
          effect: QmapEffect(
            toastMessage: 'Error fetching warehouses: $e',
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
      emit(
        state.copyWith(
          effect: QmapEffect(
            toastMessage: 'Tapped on project marker: $projectId',
          ),
        ),
      );
    } else if (id.startsWith('store_')) {
      final storeId = id.replaceFirst('store_', '');
      emit(
        state.copyWith(
          effect: QmapEffect(toastMessage: 'Tapped on store marker: $storeId'),
        ),
      );
    } else {
      Logger.debug('Tapped on unknown marker: $id');
    }
  }
}
