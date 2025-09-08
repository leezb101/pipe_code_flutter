import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

/// 自动生成的 EPSG:4547 CRS 配置
final proj4.Projection epsg4547 = proj4.Projection.add(
  'EPSG:4547',
  '+proj=tmerc +lat_0=0 +lon_0=111 +k=1 +x_0=10002100.0 +y_0=0 +ellps=GRS80 +units=m +no_defs',
);

final List<double> resolutions4547 = [
  152.87443908219228, // z=0
  76.43721954109614, // z=1
  38.21860977054807, // z=2
  19.109304885274035, // z=3
  9.554652442637018, // z=4
  4.777326221318509, // z=5
  2.3886631106592544, // z=6
  1.1943315553296272, // z=7
  0.5971657776648136, // z=8
  0.2984505969011562, // z=9
  0.1492252984505781, // z=10
  0.07461264922528905, // z=11
  0.03730632461264453, // z=12
];

final Proj4Crs crs4547 = Proj4Crs.fromFactory(
  code: 'EPSG:4547',
  proj4Projection: epsg4547,
  resolutions: resolutions4547,
  origins: [const Point(10002100.0, -5123200.0)],
);
