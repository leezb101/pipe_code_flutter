import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class QmapEvent extends Equatable {
  const QmapEvent();

  @override
  List<Object?> get props => [];
}

class CameraViewChanged extends QmapEvent {
  final LatLng center;
  final double radiusMeters;

  const CameraViewChanged({required this.center, required this.radiusMeters});

  @override
  List<Object?> get props => [center, radiusMeters];
}

class MarkerTapped extends QmapEvent {
  final String markerId;

  const MarkerTapped(this.markerId);

  @override
  List<Object?> get props => [markerId];
}
