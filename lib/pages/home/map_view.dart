import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_constants.dart';
import '../../models/map_marker_model.dart';
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
  late MapController mapController;
  late PageController pageController;
  List<MapMarker> mapMarkers = [];
  LatLng currentLocation = AppConstants.myLocation;
  int selectedIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _loadMapData();
  }

  @override
  void dispose() {
    pageController.dispose(); // Не забудьте звільнити пам'ять
    super.dispose();
  }

  Future<void> _loadMapData() async {
    try {
      mapController = MapController.customLayer(
        initPosition: GeoPoint(
          latitude: 47.4358055,
          longitude: 8.4737324,
        ),
        customTile: CustomTile(
          urlsServers: [
            TileURLs(url: "https://tile.openstreetmap.de/"),
          ],
          tileExtension: '.png',
          sourceName: 'osmGermany',
        ),
      );

      setState(() {
        loading = false;
      });

      final location = await LocationService.getCurrentLocation();
      final markers = await getData(location.longitude, location.latitude, 11);

      setState(() {
        currentLocation = location;
        mapMarkers = markers;
        _addMarkersToMap(markers);
      });
    } catch (error) {
      setState(() {
        loading = false;
      });
    }
  }

  void _addMarkersToMap(List<MapMarker> markers) {
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
  }

  void _onMarkerTap(int index) {
    selectedIndex = index;
    currentLocation = mapMarkers[index].location ?? AppConstants.myLocation;
    mapController.moveTo(
      GeoPoint(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude),
      animate: true,
    );
    mapController.setZoom(zoomLevel: 16, stepZoom: 0.5);
    setState(() {});
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
                  osmOption: const OSMOption(),
                  onGeoPointClicked: (p0) {
                    _handleGeoPointClick(p0);
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
                LocationFloatingButtons(mapController: mapController),
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
    for (int i = 0; i < mapMarkers.length; i++) {
      if (mapMarkers[i].location!.latitude == p0.latitude &&
          mapMarkers[i].location!.longitude == p0.longitude) {
        await pageController.animateToPage(i,
            duration: const Duration(seconds: 1), curve: Curves.ease);
        break;
      }
    }
  }

  @override
  Future<void> mapIsReady(bool isReady) {
    // TODO: implement mapIsReady
    throw UnimplementedError();
  }
}
