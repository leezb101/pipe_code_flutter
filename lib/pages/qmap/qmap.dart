import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// removed unused imports
import 'package:pipe_code_flutter/services/api/interfaces/map_api_service.dart';
import 'package:pipe_code_flutter/services/api_service_factory.dart';
import 'package:pipe_code_flutter/utils/logger.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:tencent_map_plus/tencent_map_plus.dart';
import 'package:haversine_distance/haversine_distance.dart' as haversine;
import 'package:pipe_code_flutter/bloc/qmap/qmap_bloc.dart';
import 'package:pipe_code_flutter/bloc/qmap/qmap_event.dart';
import 'package:pipe_code_flutter/bloc/qmap/qmap_state.dart';
import 'package:pipe_code_flutter/widgets/overlayed_dialog.dart';
import 'dart:async';

class Qmap extends StatefulWidget {
  const Qmap({super.key});

  @override
  QmapState createState() => QmapState();
}

class QmapState extends State<Qmap> {
  // late TencentMapController _mapController;
  late TencentMapController _mapController;
  // marker caches are not used currently, keeping behavior unchanged
  late MapApiService _apiservice;
  BuildContext? _blocCtx; // descendant context under BlocProvider
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    TencentMap.init(agreePrivacy: true);
    _apiservice = ApiServiceFactory.createMapApiService();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QmapBloc(apiService: _apiservice),
      child: Builder(
        builder: (ctx) {
          _blocCtx = ctx; // capture descendant context under provider
          return BlocListener<QmapBloc, QmapBlocState>(
            // Only react to effect changes for map marker updates and toasts
            listenWhen: (prev, curr) => prev.effect != curr.effect,
            listener: (context, state) {
              // Handle toast effects
              final effect = state.effect;
              if (effect?.toastMessage != null) {
                if (effect!.error) {
                  if (context.mounted) {
                    context.showErrorToast(effect.toastMessage!);
                  }
                } else {
                  if (context.mounted) {
                    context.showSuccessToast(effect.toastMessage!);
                  }
                }
              }
              // Incremental marker updates from effect
              if (effect?.storeIdsToRemove != null &&
                  effect!.storeIdsToRemove!.isNotEmpty) {
                _removeStoreMarkersByIds(effect.storeIdsToRemove!);
              }
              if (effect?.storesToAdd != null &&
                  effect!.storesToAdd!.isNotEmpty) {
                _addStoreMarkers(effect.storesToAdd!);
              }
              if (effect?.projectIdsToRemove != null &&
                  effect!.projectIdsToRemove!.isNotEmpty) {
                _removeProjectMarkersByIds(effect.projectIdsToRemove!);
              }
              if (effect?.projectsToAdd != null &&
                  effect!.projectsToAdd!.isNotEmpty) {
                _addProjectMarkers(effect.projectsToAdd!);
              }
            },
            child: Scaffold(
              appBar: AppBar(title: const Text('地图')),
              body: TencentMap(
                zoomGesturesEnabled: true,
                onMapCreated: (controller) => onMapCreated(controller, context),
                buildings3dEnabled: true,
                myLocationEnabled: true,
                onTapMarker: (markerId) => _onTapMarker(markerId),
                onCameraMoveEnd: (cameraPosition) =>
                    _onCameraMoveEndDebounced(cameraPosition),
              ),
              floatingActionButton: FloatingActionButton(
                elevation: 4.0,
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                onPressed: backToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> onMapCreated(
    TencentMapController controller,
    BuildContext context,
  ) async {
    {
      _mapController = controller;

      try {
        final location = await controller.getUserLocationWithRetry(
          maxRetries: 5,
          retryDelay: const Duration(seconds: 1),
        );
        _mapController.moveCamera(
          CameraPosition(position: location.position, zoom: 13),
        );

        // 获取当前视野范围
        final bounds = await _mapController.getVisibleRegion();
        Logger.debug('当前视野范围: $bounds');
      } catch (e) {
        if (context.mounted) {
          context.showErrorToast('获取位置失败: $e');
        }
      }
    }
  }

  void _onCameraMoveEnd(CameraPosition position) async {
    // 获取当前视野范围
    final bounds = await _mapController.getVisibleRegion();
    Logger.debug('当前视野范围: $bounds');
    final center = haversine.Location(
      bounds['center']['lat'],
      bounds['center']['lng'],
    );
    final sw = haversine.Location(bounds['sw']['lat'], bounds['sw']['lng']);
    final hDistance = haversine.HaversineDistance();
    final distance = hDistance.haversine(center, sw, haversine.Unit.METER);
    Logger.debug('当前视野半径: ${distance.toStringAsFixed(2)} 米');
    // 分发事件给 BLoC，由 BLoC 请求并规范化数据
    if (mounted && _blocCtx != null) {
      _blocCtx!.read<QmapBloc>().add(
        CameraViewChanged(
          center: LatLng(bounds['center']['lat'], bounds['center']['lng']),
          radiusMeters: distance,
        ),
      );
    }
  }

  void _onCameraMoveEndDebounced(CameraPosition position) {
    // 300ms 防抖，避免频繁请求
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _onCameraMoveEnd(position);
    });
  }

  Future<List?> fetchWarehouses(LatLng center, double r) async {
    final lat = center.latitude;
    final lng = center.longitude;
    final radius = r;

    try {
      final result = await _apiservice.fetchMapWarehouses(lat, lng, radius);
      if (result.isSuccess) {
        Logger.debug('Fetched warehouses: ${result.data}');
        return result.data;
      } else {
        Logger.error('Failed to fetch warehouses: ${result.msg}');
        if (!mounted) {
          return null;
        }
        context.showErrorToast('Failed to fetch warehouses: ${result.msg}');
      }
    } catch (e) {
      Logger.error('Error fetching warehouses: $e');
      if (!mounted) {
        return null;
      }
      context.showErrorToast('Error fetching warehouses: $e');
    }
    return null;
  }

  Future<List?> fetchProjects(LatLng center, double r) async {
    final lat = center.latitude;
    final lng = center.longitude;
    final radius = r;

    try {
      final result = await _apiservice.fetchMapProjects(lat, lng, radius);
      if (result.isSuccess) {
        Logger.debug('Fetched projects: ${result.data}');
        return result.data;
      } else {
        Logger.error('Failed to fetch projects: ${result.msg}');
        if (!mounted) {
          return null;
        }
        context.showErrorToast('Failed to fetch projects: ${result.msg}');
      }
    } catch (e) {
      Logger.error('Error fetching projects: $e');
      if (!mounted) {
        return null;
      }
      context.showErrorToast('Error fetching projects: $e');
    }
    return null;
  }

  void _onTapMarker(String markerId) {
    // 将点击事件交给 BLoC 触发同样的提示效果
    if (!mounted || _blocCtx == null) return;

    // 解析 markerId 确定类型和实际 ID
    final state = _blocCtx!.read<QmapBloc>().state;
    Widget? dialogContent;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    if (markerId.startsWith('store_marker_')) {
      final storeId = markerId.replaceFirst('store_marker_', '');
      final storeData = state.stores.firstWhere(
        (store) => store['id'].toString() == storeId,
        orElse: () => <String, dynamic>{},
      );

      if (storeData.isNotEmpty) {
        dialogContent = _buildStoreInfoDialog(
          storeData,
          () => overlayEntry.remove(),
        );
      }
    } else if (markerId.startsWith('project_marker_')) {
      final projectId = markerId.replaceFirst('project_marker_', '');
      final projectData = state.projects.firstWhere(
        (project) => project['id'].toString() == projectId,
        orElse: () => <String, dynamic>{},
      );

      if (projectData.isNotEmpty) {
        dialogContent = _buildProjectInfoDialog(
          projectData,
          () => overlayEntry.remove(),
        );
      }
    }

    // 如果找不到数据，显示默认信息
    dialogContent ??= Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Marker Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Marker ID: $markerId'),
        ],
      ),
    );
    overlayEntry = OverlayEntry(
      builder: (context) => OverlayedDialog(
        child: dialogContent!,
        onClose: () {
          overlayEntry.remove();
        },
      ),
    );
    overlay.insert(overlayEntry);
    _blocCtx!.read<QmapBloc>().add(MarkerTapped(markerId));
  }

  // 保留项目点位方法可按需恢复

  void _addStoreMarkers(List<Map<String, dynamic>> storeInfos) {
    for (var storeInfo in storeInfos) {
      var position = LatLng(
        double.tryParse(storeInfo['lat']?.toString() ?? '0') ?? 0,
        double.tryParse(storeInfo['lng']?.toString() ?? '0') ?? 0,
      );
      _mapController.addMarker(
        Marker(
          id: 'store_marker_${storeInfo['id']}',
          bizId: 'store_${storeInfo['id']}',
          title: storeInfo['title'],
          position: position,
          icon: Bitmap(asset: "images/store.png"),
        ),
      );
    }
  }

  void _removeStoreMarkersByIds(List<String> storeIds) {
    for (final id in storeIds) {
      // Remove by the marker id we assigned in addMarker
      _mapController.removeMarker('store_marker_$id');
      // If SDK requires removal by bizId instead, uncomment next line and adjust
      // _mapController.removeMarkerByBizId('store_$id');
    }
  }

  void _addProjectMarkers(List<Map<String, dynamic>> projectInfos) {
    for (var projectInfo in projectInfos) {
      var position = LatLng(
        double.tryParse(projectInfo['lat']?.toString() ?? '0') ?? 0,
        double.tryParse(projectInfo['lng']?.toString() ?? '0') ?? 0,
      );
      _mapController.addMarker(
        Marker(
          id: 'project_marker_${projectInfo['id']}',
          bizId: 'project_${projectInfo['id']}',
          title: projectInfo['title'],
          position: position,
          icon: Bitmap(asset: "images/proj.png"), // 使用不同的图标
        ),
      );
    }
  }

  void _removeProjectMarkersByIds(List<String> projectIds) {
    for (final id in projectIds) {
      // Remove by the marker id we assigned in addMarker
      _mapController.removeMarker('project_marker_$id');
      // If SDK requires removal by bizId instead, uncomment next line and adjust
      // _mapController.removeMarkerByBizId('project_$id');
    }
  }

  // 构建仓库信息弹窗
  Widget _buildStoreInfoDialog(
    Map<String, dynamic> storeData,
    VoidCallback? onClose,
  ) {
    final name =
        storeData['name']?.toString() ??
        storeData['title']?.toString() ??
        '未知仓库';
    final address = storeData['address']?.toString() ?? '地址未知';
    final isRealWarehouse = storeData['isRealWarehouse'] ?? false;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warehouse, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '仓库信息',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('名称', name),
          const SizedBox(height: 8),
          _buildInfoRow('地址', address),
          const SizedBox(height: 8),
          _buildInfoRow('类型', isRealWarehouse ? '实体仓库' : '虚拟仓库'),
          const SizedBox(height: 8),
          _buildDetailButton(storeData['id'] as int?, 'warehouse', onClose),
        ],
      ),
    );
  }

  // 构建项目信息弹窗
  Widget _buildProjectInfoDialog(
    Map<String, dynamic> projectData,
    VoidCallback? onClose,
  ) {
    final name =
        projectData['name']?.toString() ??
        projectData['title']?.toString() ??
        '未知项目';
    final id = projectData['id']?.toString() ?? '';

    return Container(
      width: 280,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.engineering, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '项目信息',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('项目名称', name),
          const SizedBox(height: 8),
          _buildInfoRow('项目ID', id),
          const SizedBox(height: 8),
          _buildDetailButton(projectData['id'] as int?, 'project', onClose),
        ],
      ),
    );
  }

  // 辅助方法：构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  // 辅助方法：构建查看详情按钮
  Widget _buildDetailButton(int? id, String type, VoidCallback? onClose) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          // 首先关闭弹窗
          onClose?.call();
          // 然后实现跳转到详情页的逻辑,传递 id 参数，但是需要区分仓库和项目
          if (id != null) {
            // 使用 GoRouter 进行路由跳转
            if (type == 'project') {
              context.pushNamed(
                'projectDetail',
                queryParameters: {'id': id.toString()},
              );
            } else {
              context.pushNamed(
                'warehouseDetail',
                queryParameters: {'id': id.toString()},
              );
            }
          }
        },
        child: const Text('查看详情'),
      ),
    );
  }

  void backToCurrentLocation() async {
    Location location = await _mapController.getUserLocation();
    // _mapController.moveCamera({'target': location.toMap(), 'zoom': 13});
    _mapController.moveCamera(
      CameraPosition(position: location.position, zoom: 13),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
