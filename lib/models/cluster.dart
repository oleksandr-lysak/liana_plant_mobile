import 'dart:math';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlong2/latlong.dart';
import 'map_marker_model.dart';

class Cluster {
  final List<MapMarker> markers;
  LatLng position;

  Cluster(this.markers) : position = LatLng(0, 0);

  static LatLng _calculateCenter(List<MapMarker> markers) {
    double x = 0.0;
    double y = 0.0;
    double z = 0.0;

    for (var marker in markers) {
      double latRad = marker.location!.latitude * (pi / 180);
      double lngRad = marker.location!.longitude * (pi / 180);

      x += cos(latRad) * cos(lngRad);
      y += cos(latRad) * sin(lngRad);
      z += sin(latRad);
    }

    int count = markers.length;
    if (count == 0) return LatLng(0.0, 0.0); // Немає маркерів

    x /= count;
    y /= count;
    z /= count;

    double lng = atan2(y, x);
    double hyp = sqrt(x * x + y * y);
    double lat = atan2(z, hyp);

    return LatLng(lat * (180 / pi), lng * (180 / pi));
  }

  static bool _isMarkerVisible(MapMarker marker, BoundingBox bounds) {
    return marker.location!.latitude >= bounds.south &&
        marker.location!.latitude <= bounds.north &&
        marker.location!.longitude >= bounds.west &&
        marker.location!.longitude <= bounds.east;
  }

  static List<Cluster> createClusters(
    List<MapMarker> markers,
    double zoom,
    BoundingBox visibleBounds,
  ) {
    num clusterRadius = _getClusterRadius(zoom);
    List<Cluster> clusters = [];

    print("Zoom: $zoom, Cluster Radius: $clusterRadius");
    List<MapMarker> visibleMarkers = markers.where((marker) {
      return _isMarkerVisible(marker, visibleBounds);
    }).toList();

    for (var marker in visibleMarkers) {
      bool addedToCluster = false;

      // Перевіряємо, чи можна додати маркер до існуючого кластеру
      for (var cluster in clusters) {
        if (distance(marker.location!, cluster.position) < clusterRadius) {
          cluster.markers.add(marker);
          addedToCluster = true;
          break;
        }
      }

      // Якщо маркер не підходить до жодного з існуючих кластерів
      if (!addedToCluster) {
        Cluster newCluster = Cluster([marker]);
        newCluster.position = _calculateCenter(newCluster.markers);
        clusters.add(newCluster);
      }
    }

    // Об'єднання кластерів, якщо відстань між ними менша за кластерний радіус
    for (var i = 0; i < clusters.length; i++) {
      for (var j = i + 1; j < clusters.length; j++) {
        if (distance(clusters[i].position, clusters[j].position) <
            clusterRadius) {
          clusters[i].markers.addAll(clusters[j].markers);
          clusters.removeAt(j);
          j--;
        }
      }
    }

    print("Total clusters created: ${clusters.length}");
    return clusters;
  }

  static num _getClusterRadius(double zoom) {
    // Залежність радіусу кластеризації від зуму
    double clusterRadius = 1000000 / zoom;
    if (zoom > 7) {
      clusterRadius = 0;
    }
    return clusterRadius;
  }

  static double distance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371e3; // радіус Землі в метрах

    double lat1Rad = point1.latitude * (pi / 180);
    double lat2Rad = point2.latitude * (pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Відстань в метрах
  }
}
