// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/constants/styles.dart';
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
  String? selectedLanguage;
  late AnimationController _animationController;
  final pageController = PageController();
  int selectedIndex = 0;
  var currentLocation = AppConstants.myLocation;

  bool loading = false;

  late final MapController mapController;

  List<MapMarker> mapMarkers = [];

  @override
  void initState() {
    _getData();
    super.initState();
    selectedLanguage = 'en';
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    mapController = MapController();
    mapController.mapEventStream
        .where((event) => event is MapEventMoveEnd)
        .listen((event) {});
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
        longitude = position.longitude;
        latitude = position.latitude;
      } else {
        longitude = 50.249198;
        latitude = 30.350024;
      }
    }
    mapMarkers = await getData(longitude, latitude, zoom);

    setState(() {
      loading = false;
      currentLocation = LatLng(latitude, longitude);
    });
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    await FlutterI18n.refresh(context, Locale(languageCode));
    Navigator.of(context).pop(); // Close the drawer
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                '${FlutterI18n.translate(context, 'language')}:',
                style: const TextStyle(color: Styles.descriptionColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: DropdownButton<String>(
                value: selectedLanguage,
                items: AppConstants.languages,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLanguage = newValue;
                  });
                  _changeLanguage(context, newValue!);
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Styles.backgroundColor,
        title: const Row(
          children: [
            Text(AppConstants.appTitle),
          ],
        ),
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
                    initialZoom: 11,
                    initialCenter: currentLocation,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.urlTemplate,
                      userAgentPackageName: 'com.it-pragmat.plant',
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
                                _animatedMapMove(
                                    currentLocation, mapController.camera.zoom);
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
                      _animatedMapMove(
                          currentLocation, mapController.camera.zoom);
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
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.25,
                        right: MediaQuery.of(context).size.width * 0.25),
                    child: FloatingActionButton.extended(
                      backgroundColor: Styles.backgroundColor,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        size: 24.0,
                        color: Colors.white,
                      ),
                      label: Text(
                        FlutterI18n.translate(context, 'search_in_this_area'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: MediaQuery.of(context).size.height * 0.01,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          //Navigator.pushNamed(context, '/create-master');
                          Navigator.pushNamed(context, '/map-picker');
                        },
                        backgroundColor: Styles.backgroundColor,
                        child: const Icon(Icons.add_location_alt_outlined),
                      ),
                    ],
                  ),
                ),
                // Додати кнопки масштабування
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 + 30,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          final zoom = mapController.camera.zoom + 1;
                          mapController.move(mapController.camera.center, zoom);
                        },
                        backgroundColor: Styles.backgroundColor,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {
                          final zoom = mapController.camera.zoom - 1;
                          mapController.move(mapController.camera.center, zoom);
                        },
                        backgroundColor: Styles.backgroundColor,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: mapController.camera.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.camera.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: mapController.camera.zoom, end: destZoom);

    Animation<double> animation = CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn);

    _animationController.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    _animationController.forward(from: 0.0);
  }
}
