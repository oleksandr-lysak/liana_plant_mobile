import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:liana_plant/models/master.dart';

class LianaMarker extends Marker {
  final Master master;

  const LianaMarker({
    required LatLng point,
    required Widget child,
    required this.master,
    double width = 40.0,
    double height = 40.0,
  }) : super(
          point: point,
          width: width,
          height: height,
          child: child,
        );
}
