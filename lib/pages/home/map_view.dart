import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:liana_plant/models/cluster.dart';
import 'package:liana_plant/services/log_service.dart';
import '../../constants/app_constants.dart';
import '../../models/map_marker_model.dart';
import '../../services/language_service.dart';
import '../../services/location_service.dart';
import '../../widgets/loading.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'map_view/location_floating_buttons.dart';
import 'map_view/map_card.dart';
import 'map_view/master_dialog.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with OSMMixinObserver {
  MapController mapController = MapController(
    initMapWithUserPosition: const UserTrackingOption(
      unFollowUser: false,
    ),
  );
  late PageController pageController;
  List<MapMarker> mapMarkers = [];
  LatLng currentLocation = const LatLng(0, 0);
  int selectedIndex = 0;
  bool loading = true;
  int currentPage = 1;
  int totalPages = 1;
  bool moveMap = false;
  List<Cluster> clusters = [];

  @override
  void initState() {
    super.initState();
    pageController = PageController();

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LatLng position = await LocationService.getCurrentLocation();

      setState(() {
        currentLocation = position;
        mapController = mapController;
        loading = false;
      });

      _loadMapData();
    } catch (e, s) {
      LogService.log(s.toString());
      LogService.log('Error getting current location: $e');
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    try {
      final location = await LocationService.getCurrentLocation();
      double zoom = await mapController.getZoom();

      if (totalPages == 1) {
        await _fetchMarkers(
            location.longitude, location.latitude, currentPage, zoom);
      }

      if (totalPages > 1) {
        List<Future<List<MapMarker>>> fetchRequests = [];

        for (int page = 2; page <= totalPages; page++) {
          fetchRequests
              .add(getData(location.longitude, location.latitude, page, zoom));
        }

        List<List<MapMarker>> results = await Future.wait(fetchRequests);

        for (var markers in results) {
          mapMarkers.addAll(markers);
        }
      }

      setState(() {
        _addMarkersToMap(mapMarkers);
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _fetchMarkers(
      double longitude, double latitude, int page, double zoom) async {
    final markers = await getData(longitude, latitude, page, zoom);
    setState(() {
      mapMarkers.addAll(markers);
      if (page == 1) {
        totalPages = markers.isNotEmpty ? apiData["meta"]["last_page"] : 1;
      }
    });
  }

  Future<List<MapMarker>> getData(
      double longitude, double latitude, int page, double zoom) async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await Geolocator.checkPermission();
    }

    String serverUrl = AppConstants.serverUrl;
    final String locale = await LanguageService.getLanguage() ?? 'en';
    String url =
        '${serverUrl}masters?lng=$longitude&lat=$latitude&zoom=$zoom&page=$page&locale=$locale';

    Response response = await dio.get(url);
    apiData = response.data;
    print('Got data from page $page');
    var tagObjsJson = apiData["data"] as List;
    List<MapMarker> tagObjs =
        tagObjsJson.map((tagJson) => MapMarker.fromJson(tagJson)).toList();

    return tagObjs;
  }

  void _addMarkersToMap(List<MapMarker> markers) async {
    double zoom = await mapController.getZoom();
    BoundingBox visibleBounds = await mapController.bounds;
    clusters = Cluster.createClusters(markers, zoom, visibleBounds);
    for (var cluster in clusters) {
      int markerCount = cluster.markers.length;
      if (cluster.markers.length > 1) {
        Color gradientColor = Theme.of(context).primaryColor;
        if (cluster.markers.length > 100) {
          gradientColor = Colors.green;
        } else if (cluster.markers.length > 50) {
          gradientColor = Colors.red;
        } else if (cluster.markers.length > 20) {
          gradientColor = Colors.orange;
        }
        RadialGradient gradient = RadialGradient(
          colors: [
            gradientColor.withOpacity(1), // Основний колір
            gradientColor.withOpacity(0.0), // Прозорий колір для розмивання
          ],
          radius: 1.0,
        );
        print('Adding cluster marker, lat: ${cluster.position.latitude}'
            'lng: ${cluster.position.longitude}, '
            'count: ${cluster.markers.length}');

        mapController.addMarker(
          GeoPoint(
              latitude: cluster.position.latitude,
              longitude: cluster.position.longitude),
          markerIcon: MarkerIcon(
            iconWidget: GestureDetector(
              onTap: () {
                _onClusterTap(cluster);
              },
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 50.0,
                      spreadRadius: 4.0,
                    ),
                  ],
                ),
                alignment: Alignment.center, // Центрує текст
                child: Text(
                  '$markerCount',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
              ),
            ),
          ),
        );
      } else {
        // Відобразити одиночний маркер
        var marker = cluster.markers.first;
        mapController.addMarker(
          GeoPoint(
            latitude: marker.location!.latitude,
            longitude: marker.location!.longitude,
          ),
          markerIcon: MarkerIcon(
            iconWidget: GestureDetector(
              onTap: () {
                _onMarkerTap(
                    markers.indexOf(marker)); // Взаємодія з одиночним маркером
              },
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 34,
              ),
            ),
          ),
        );
      }
    }
  }

  void _onClusterTap(Cluster cluster) async {
    // Обробка натиску на кластер
    // Виберіть окремі маркери з кластера
    mapController.zoomIn();

    await mapController.removeMarker(GeoPoint(
        latitude: cluster.position.latitude,
        longitude: cluster.position.longitude));

    for (var marker in cluster.markers) {
      await mapController.addMarker(
        GeoPoint(
          latitude: marker.location!.latitude,
          longitude: marker.location!.longitude,
        ),
        markerIcon: MarkerIcon(
          iconWidget: Icon(
            Icons.location_on,
            color: Theme.of(context).primaryColor,
            size: 34,
          ),
        ),
      );
    }
    setState(() {});
  }

  void _onMarkerTap(int index) async {
    selectedIndex = index;
    currentLocation = mapMarkers[index].location ?? AppConstants.myLocation;
    if (moveMap) {
      await mapController.moveTo(
        GeoPoint(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude),
        animate: true,
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: Loading())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                FlutterI18n.translate(context, 'map_view.title'),
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6, color: Colors.black),
                  onPressed: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                OSMFlutter(
                  controller: mapController,
                  osmOption: const OSMOption(
                    enableRotationByGesture: false,
                    showZoomController: true,
                  ),
                  onGeoPointClicked: (p0) {
                    _handleGeoPointClick(p0);
                  },
                  mapIsLoading: Loading(),
                  onMapMoved: (geoPoint) async {
                    if (geoPoint != null) {
                      // List<GeoPoint> geoPoints = await mapController.geopoints;
                      // mapController.removeMarkers(geoPoints);
                      // _addMarkersToMap(mapMarkers);
                    }
                  },
                  onMapIsReady: mapIsReady,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 2,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      setState(() {
                        moveMap = true;
                      });
                      _onMarkerTap(value);
                      setState(() {
                        moveMap = false;
                      });
                    },
                    itemCount: mapMarkers.length,
                    itemBuilder: (_, index) => MapCard(item: mapMarkers[index]),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 + 30,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () async {
                          mapController.zoomIn();
                          List<GeoPoint> geoPoints =
                              await mapController.geopoints;
                          mapController.removeMarkers(geoPoints);
                          _addMarkersToMap(mapMarkers);
                        },
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        elevation: 10.0,
                        child: Icon(Icons.zoom_in,
                            color: Theme.of(context).indicatorColor),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () async {
                          double zoom = await mapController.getZoom();
                          if (zoom > 6) {
                            mapController.zoomOut();
                            List<GeoPoint> geoPoints =
                                await mapController.geopoints;
                            mapController.removeMarkers(geoPoints);
                            _addMarkersToMap(mapMarkers);
                          }
                        },
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        elevation: 10.0,
                        child: Icon(Icons.zoom_out,
                            color: Theme.of(context).indicatorColor),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 + 165,
                  child: FloatingActionButton(
                    onPressed: () {
                      showMasterDialog(context);
                    },
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 10.0,
                    child: Icon(Icons.add_location_alt_outlined,
                        color: Theme.of(context).indicatorColor),
                  ),
                ),
              ],
            ),
          );
  }

  void _handleGeoPointClick(GeoPoint p0) async {
    for (int i = 0; i < clusters.length; i++) {
      Cluster cluster = clusters[i];
      if (cluster.position.latitude == p0.latitude &&
          cluster.position.longitude == p0.longitude) {
        if (cluster.markers.length > 1) {
          mapController.zoomIn();
          List<GeoPoint> geoPoints = await mapController.geopoints;
          mapController.removeMarkers(geoPoints);
          _addMarkersToMap(mapMarkers);
        }
        break;
      }
    }
    for (int j = 0; j < mapMarkers.length; j++) {
      if (mapMarkers[j].location!.latitude == p0.latitude &&
          mapMarkers[j].location!.longitude == p0.longitude) {
        _onMarkerTap(j);
        await pageController.animateToPage(j,
            duration: const Duration(seconds: 1), curve: Curves.ease);
        break;
      }
    }
  }

  mapIsReady(bool isReady) async {
    // TODO: implement mapIsReady
    if (isReady) {
      mapController.moveTo(
        GeoPoint(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
        ),
        animate: true,
      );
      mapController.setZoom(zoomLevel: 6.0, stepZoom: 0.5);
    }
  }
}
