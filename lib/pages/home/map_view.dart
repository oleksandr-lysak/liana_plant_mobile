import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlong2/latlong.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/map_marker_model.dart';
import 'package:liana_plant/widgets/animated_text_field.dart';
import 'package:liana_plant/widgets/buttons.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:liana_plant/widgets/map_card.dart';
import 'package:liana_plant/services/location_service.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_services/auth_service.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with OSMMixinObserver {
  bool animateMap = true;
  final pageController = PageController();
  late MapController mapController;
  late AnimationController _animationController;
  List<MapMarker> mapMarkers = [];
  LatLng currentLocation = AppConstants.myLocation;
  int selectedIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      mapController = MapController.customLayer(
        initPosition: GeoPoint(
          latitude: 47.4358055,
          longitude: 8.4737324,
        ),
        customTile: CustomTile(urlsServers: [
          TileURLs(url: "https://tile.openstreetmap.de/"),
        ], tileExtension: '.png', sourceName: 'osmGermany'),
      );

      setState(() {
        loading = false;
      });

      final location = await LocationService.getCurrentLocation();
      final markers = await getData(location.longitude, location.latitude, 11);

      setState(() {
        currentLocation = location;
        mapMarkers = markers;
      });

      for (int i = 0; i < markers.length; i++) {
        var marker = markers[i];
        mapController.addMarker(
          GeoPoint(
            latitude: marker.location!.latitude,
            longitude: marker.location!.longitude,
          ),
          markerIcon: MarkerIcon(
            iconWidget: GestureDetector(
              onTap: () {
                _onMarkerTap(i);
              },
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 34,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      setState(() {});
    } catch (error) {
      print(error.toString());
      setState(() {
        loading = false;
      });
    }
  }

  void _onMarkerTap(int index) {
    if (animateMap) {
      selectedIndex = index;
      currentLocation = mapMarkers[index].location ?? AppConstants.myLocation;
      mapController.moveTo(
          GeoPoint(
              latitude: currentLocation.latitude,
              longitude: currentLocation.longitude),
          animate: true);
      mapController.setZoom(
        zoomLevel: 16,
        stepZoom: 0.5,
      );

      setState(() {});
    }
  }

  void _moveToCurrentLocation() {
    mapController.currentLocation();
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
                OSMFlutter(
                  controller: mapController,
                  osmOption: OSMOption(),
                  onGeoPointClicked: (p0) async {
                    for (int i = 0; i < mapMarkers.length; i++) {
                      if (mapMarkers[i].location!.latitude == p0.latitude &&
                          mapMarkers[i].location!.longitude == p0.longitude) {
                        animateMap = false;
                        await pageController.animateToPage(i,
                            duration: const Duration(seconds: 1),
                            curve: Curves.ease);
                        animateMap = true;
                        break;
                      }
                    }
                  },
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
                          mapController.zoomIn();
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
                          mapController.zoomOut();
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

  @override
  Future<void> mapIsReady(bool isReady) {
    // TODO: implement mapIsReady
    throw UnimplementedError();
  }
}
