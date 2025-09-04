import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ArcgisPage extends StatelessWidget {
  const ArcgisPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String arcgisUrlTemplate =
        'http://10.1.119.10:6080/arcgis/rest/services/dt/zztdt_wp/MapServer/WMTS/1.0.0/dt_zztdt_wp/default/default028mm/{z}/{y}/{x}.png';
    return Scaffold(
      appBar: AppBar(title: const Text('ArcGIS Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(34.75, 113.62),
          initialZoom: 14.0,
        ),
        children: [TileLayer(urlTemplate: arcgisUrlTemplate)],
      ),
    );
  }
}
