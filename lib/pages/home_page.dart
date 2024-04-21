// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/map_marker_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:liana_plant/widgets/map_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final pageController = PageController();
  int selectedIndex = 0;
  var currentLocation = AppConstants.myLocation;

  bool loading = false;

  late final MapController mapController;

  var mapMarkers = [];

  @override
  void initState() {
    _getData();
    super.initState();
    mapController = MapController();
    mapController.mapEventStream
        .where((event) => event is MapEventMoveEnd)
        .listen((event) {
    });
  }

  void _getData([
    double longitude = 0.00,
    double latitude = 0.00,
    double zoom = 11,
  ]) async {
    if (longitude == 0.00 && latitude == 0.00) {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        if (longitude == 0.00 || latitude == 0.00) {
          longitude = position.longitude;
          latitude = position.latitude;
        }
      } else {
        longitude = 50.249198;
        latitude = 30.350024;
      }
    }

    setState(() {
      loading = false; //make loading true to show progressindicator
    });

    mapMarkers = await getData(longitude, latitude, zoom);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    late List<Marker> markers;
    late int pointIndex;
    List<LatLng> points = [
      const LatLng(51.5, -0.09),
      const LatLng(49.8566, 3.3522),
    ];
    pointIndex = 0;
    String mapStyleId = AppConstants.mapBoxStyleId;
    String accessToken = AppConstants.mapBoxAccessToken;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 32, 32),
        title: const Text('Liana best'),
      ),
      body: loading
          ? const CircularProgressIndicator()
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    minZoom: 2,
                    maxZoom: 18,
                    zoom: 11,
                    initialZoom: 11,
                    center: currentLocation,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/rotting/$mapStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=$accessToken",
                      userAgentPackageName: 'com.it-pragmat.plant',
                      // Plenty of other options available!
                    ),
                    MarkerLayer(
                      markers: [
                        for (int i = 0; i < mapMarkers.length; i++)
                          Marker(
                            height: 40,
                            width: 40,
                            point: mapMarkers[i].location ??
                                AppConstants.myLocation,
                            child: GestureDetector(
                              onTap: () {
                                pageController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                selectedIndex = i;
                                currentLocation = mapMarkers[i].location ??
                                    AppConstants.myLocation;
                                _animatedMapMove(currentLocation, 11.5);
                                setState(() {});
                              },
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 500),
                                scale: selectedIndex == i ? 1 : 0.7,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: selectedIndex == i ? 1 : 0.5,
                                  child: SvgPicture.asset(
                                    'assets/icons/map_marker.svg',
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 2,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      selectedIndex = value;
                      currentLocation =
                          mapMarkers[value].location ?? AppConstants.myLocation;
                      _animatedMapMove(currentLocation, 15);
                      setState(() {});
                    },
                    itemCount: mapMarkers.length,
                    itemBuilder: (_, index) {
                      final item = mapMarkers[index];
                      return MapCard(item: item);
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 10,
                  height: 30,
                  //width: 20,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.25,
                        right: MediaQuery.of(context).size.width * 0.25),
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.black,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        size: 24.0,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Search in this area',
                        style: TextStyle(color: Colors.white),
                      ), // <-- Text
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}
