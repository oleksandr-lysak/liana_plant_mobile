import 'package:flutter_map/flutter_map.dart';
import 'package:liana_plant/models/master.dart';

class LianaMarker extends Marker {
  final Master master;

  const LianaMarker({
    required super.point,
    required super.child,
    required this.master,
    super.width = 40.0,
    super.height = 40.0,
  });
}
