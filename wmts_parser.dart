import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;

/// 解析 WMTS Capabilities 并生成 crs_xxxx.dart 文件
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('用法: dart wmts_parser.dart <WMTSCapabilities.xml路径>');
    exit(1);
  }

  final xmlFile = File(args[0]);
  if (!xmlFile.existsSync()) {
    print('错误: 找不到文件 ${xmlFile.path}');
    exit(1);
  }

  final xmlContent = await xmlFile.readAsString();
  final document = XmlDocument.parse(xmlContent);

  // 1. 解析 EPSG 编码
  final supportedCRS = document
      .findAllElements('ows:SupportedCRS')
      .first
      .text
      .replaceAll('urn:ogc:def:crs:EPSG::', '');
  final epsgCode = supportedCRS;

  // 2. 解析 TopLeftCorner
  final topLeftCorner = document.findAllElements('TopLeftCorner').first.text;
  final parts = topLeftCorner.split(' ');
  final originX = double.parse(parts[0]);
  final originY = double.parse(parts[1]);

  // 3. 解析所有 ScaleDenominator
  final scaleDenominators = document.findAllElements('ScaleDenominator');
  final resolutions = <double>[];
  for (final scaleNode in scaleDenominators) {
    final scale = double.parse(scaleNode.text);
    resolutions.add(scale * 0.00028);
  }

  // 4. 构造 crs_xxxx.dart 文件内容
  final dartFileName = 'crs_$epsgCode.dart';
  final buffer = StringBuffer();

  buffer.writeln("import 'dart:math';");
  buffer.writeln("import 'package:flutter_map/flutter_map.dart';");
  buffer.writeln("import 'package:proj4dart/proj4dart.dart';\n");
  buffer.writeln("/// 自动生成的 EPSG:$epsgCode CRS 配置");
  buffer.writeln("final Projection epsg$epsgCode = Projection.add(");
  buffer.writeln("  'EPSG:$epsgCode',");
  buffer.writeln(
    "  '+proj=tmerc +lat_0=0 +lon_0=111 +k=1 +x_0=$originX +y_0=0 +ellps=GRS80 +units=m +no_defs',",
  );
  buffer.writeln(");\n");

  buffer.writeln("final List<double> resolutions$epsgCode = [");
  for (var i = 0; i < resolutions.length; i++) {
    buffer.writeln("  ${resolutions[i]}, // z=$i");
  }
  buffer.writeln("];\n");

  buffer.writeln("final Proj4Crs crs$epsgCode = Proj4Crs.fromFactory(");
  buffer.writeln("  code: 'EPSG:$epsgCode',");
  buffer.writeln("  proj4Projection: epsg$epsgCode,");
  buffer.writeln("  resolutions: resolutions$epsgCode,");
  buffer.writeln("  origin: const Point($originX, $originY),");
  buffer.writeln(");\n");

  // 5. 写入文件
  final outputFile = File(p.join(p.current, dartFileName));
  await outputFile.writeAsString(buffer.toString());

  print('✅ 已生成 $dartFileName');
}
