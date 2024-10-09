import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/map_marker_model.dart';
import 'package:liana_plant/widgets/animated_text_field.dart';
import 'package:liana_plant/widgets/buttons.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:liana_plant/widgets/map_card.dart';
import 'package:liana_plant/services/location_service.dart';
import 'package:liana_plant/services/animation_service.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_services/auth_service.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with TickerProviderStateMixin {
  final pageController = PageController();
  late final MapController mapController;
  late AnimationController _animationController;
  List<MapMarker> mapMarkers = [];
  LatLng currentLocation = AppConstants.myLocation;
  int selectedIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      final location = await LocationService.getCurrentLocation();
      final markers = await getData(location.longitude, location.latitude, 11);

      setState(() {
        currentLocation = location;
        mapMarkers = markers;
        loading = false;
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
    }
  }

  void _onMarkerTap(int index) {
    selectedIndex = index;
    currentLocation = mapMarkers[index].location ?? AppConstants.myLocation;
    AnimationService.animatedMapMove(
      mapController,
      _animationController,
      currentLocation,
      mapController.zoom,
    );
    setState(() {});
  }

  void _moveToCurrentLocation() {
    AnimationService.animatedMapMove(
      mapController,
      _animationController,
      currentLocation,
      18,
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: Loading(),
          )
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
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
                      urlTemplate: AppConstants().urlTemplate,
                      userAgentPackageName: 'com.it-pragmat.plant',
                    ),
                    MarkerLayer(
                      markers: [
                        // Маркер для вашого місцеположення
                        Marker(
                          height: 80,
                          width: 80,
                          point: currentLocation,
                          child: Icon(
                            Icons.my_location,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        // Інші маркери
                        ...mapMarkers.map((marker) {
                          int index = mapMarkers.indexOf(marker);
                          return Marker(
                            height: 40,
                            width: 40,
                            point: marker.location ?? AppConstants.myLocation,
                            child: GestureDetector(
                              onTap: () => _onMarkerTap(index),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 500),
                                scale: selectedIndex == index ? 1 : 0.7,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: selectedIndex == index ? 1 : 0.5,
                                  child: SvgPicture.asset(
                                      'assets/icons/map_marker.svg'),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                      _onMarkerTap(value);
                    },
                    itemCount: mapMarkers.length,
                    itemBuilder: (_, index) => MapCard(item: mapMarkers[index]),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: MediaQuery.of(context).size.height * 0.01,
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
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 + 165,
                  child: FloatingActionButton(
                    onPressed: _moveToCurrentLocation,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 10.0,
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).indicatorColor,
                    ),
                  ),
                ),
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
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        elevation: 10.0,
                        child: Icon(Icons.zoom_in,
                            color: Theme.of(context).indicatorColor),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: () {
                          final zoom = mapController.camera.zoom - 1;
                          mapController.move(mapController.camera.center, zoom);
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
              ],
            ),
          );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showMasterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              FlutterI18n.translate(context, 'map_view.master_dialog.title'),
              style: Theme.of(context).textTheme.titleMedium),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Button(
                labelText: FlutterI18n.translate(
                    context, 'map_view.master_dialog.create'),
                onPressed: () {
                  Navigator.pushNamed(context, '/create-master');
                },
                active: true,
                icon: Icons.add,
                size: Size.medium,
              ),
              Button(
                labelText: FlutterI18n.translate(
                    context, 'map_view.master_dialog.login'),
                onPressed: () {
                  Navigator.pop(context);
                  showLoginDialog(context);
                },
                active: false,
                icon: Icons.login,
                size: Size.medium,
              ),
            ],
          ),
        );
      },
    );
  }

  void showLoginDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              FlutterI18n.translate(
                  context, 'map_view.master_dialog.input_phone'),
              style: Theme.of(context).textTheme.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedTextField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                labelText: FlutterI18n.translate(
                    context, 'map_view.master_dialog.phone'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                String phone = phoneController.text;
                AuthService().sendSms(phone);
                Navigator.pop(context);
                showSMSDialog(context, phone);
              },
              child: Text(
                FlutterI18n.translate(
                    context, 'map_view.master_dialog.get_sms_code'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  void showSMSDialog(BuildContext context, String phone) {
    final TextEditingController smsCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              FlutterI18n.translate(
                  context, 'map_view.master_dialog.input_sms_code'),
              style: Theme.of(context).textTheme.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedTextField(
                controller: smsCodeController,
                labelText: FlutterI18n.translate(
                    context, 'map_view.master_dialog.code'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                int smsCode = int.parse(smsCodeController.text);
                // Закрити діалог після успішного введення
                bool result =
                    await AuthService().confirmLogin(phone, smsCode, context);
                if (result) {
                  Navigator.pop(context);
                  MyApp.restartApp(context);
                }
              },
              child: Text(
                FlutterI18n.translate(
                    context, 'map_view.master_dialog.confirm'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      },
    );
  }
}
