import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/app_constants.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  MapPickerPageState createState() => MapPickerPageState();
}

class MapPickerPageState extends State<MapPickerPage> {
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await _requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation!, 18); // Оновити позицію мапи
      _selectedLocation =
          _currentLocation; // Встановити початкове місце маркера
    });
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
  }

  void _updateSelectedLocation() {
    setState(() {
      _selectedLocation = _mapController.camera.center;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'select_location')),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.navigate_next, color: Colors.black),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/create-master',
                  arguments: _selectedLocation,
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ??
                  const LatLng(37.7749, -122.4194), // Default to San Francisco
              initialZoom: 25,
              onPositionChanged: (MapCamera mapCamera, bool hasGesture) {
                if (hasGesture) {
                  _updateSelectedLocation(); // Оновити вибрану локацію при русі карти
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants().urlTemplate,
                userAgentPackageName: 'com.it-pragmat.plant',
                tileProvider: const FMTCStore('mapStore').getTileProvider(),
              ),
            ],
          ),
          Center(
            child: Icon(Icons.location_on,
                color: Theme.of(context).primaryColor, size: 40.0),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.01,
            right: MediaQuery.of(context).size.width * 0.01,
            bottom: MediaQuery.of(context).size.height * 0.02,
            child: ElevatedButton(
                onPressed: () => {
                      Navigator.pushNamed(
                        context,
                        '/create-master',
                        arguments: _selectedLocation,
                      )
                    },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    padding: const EdgeInsets.all(16.0)),
                child: Text('${FlutterI18n.translate(context, 'next')} ...',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 24))),
          ),
          // Positioned(
          //   left: MediaQuery.of(context).size.width * 0.01,
          //   right: MediaQuery.of(context).size.width * 0.01,
          //   top: MediaQuery.of(context).size.height * 0.02,
          //   child: Container(
          //     color: Theme.of(context).primaryColor,
          //     padding: const EdgeInsets.all(8.0),
          //     child: Text(
          //       _selectedLocation != null
          //           ? 'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
          //           : 'Select a location',
          //       style: const TextStyle(fontSize: 16, color: Colors.black),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
