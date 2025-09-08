import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pipe_code_flutter/utils/crs_4547.dart';
import 'package:proj4dart/proj4dart.dart';

class ArcgisPage extends StatefulWidget {
  const ArcgisPage({Key? key}) : super(key: key);

  @override
  State<ArcgisPage> createState() => _ArcgisPageState();
}

class _ArcgisPageState extends State<ArcgisPage> {
  final MapController _mapController = MapController();

  /// 如果你想用 GPS 经纬度设置中心点，必须先投影到 EPSG:4547
  LatLng _projectGpsTo4547(double lon, double lat) {
    final projected = epsg4547.forward(Point(x: lon, y: lat));
    return LatLng(projected.y, projected.x);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          crs: crs4547, // 使用 EPSG:4547 坐标系
          initialCenter: _projectGpsTo4547(110.45, 0.31), // GPS转EPSG4547
          initialZoom: 1, // 对应TileMatrix 1级别
          maxZoom: 12,
          minZoom: 0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://10.1.119.10:8886/arcgis/rest/services/dt/zztdt_wp/MapServer/WMTS/tile/1.0.0/dt_zztdt_wp/default/default028mm/{z}/{y}/{x}.png',
            maxNativeZoom: 12,
            minNativeZoom: 0,
          ),
        ],
      ),
    );
  }
}
