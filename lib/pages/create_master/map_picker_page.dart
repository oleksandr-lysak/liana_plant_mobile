import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:liana_plant/constants/styles.dart';

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
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.navigate_next),
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
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  _updateSelectedLocation(); // Оновити вибрану локацію при русі карти
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.urlTemplate,
                userAgentPackageName: 'com.it-pragmat.plant',
              ),
            ],
          ),
          const Center(
            child:
                Icon(Icons.location_on, color: Styles.primaryColor, size: 40.0),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.01,
            right: MediaQuery.of(context).size.width * 0.01,
            bottom: MediaQuery.of(context).size.height * 0.02,
            child: Container(
              color: Styles.backgroundColor,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _selectedLocation != null
                    ? 'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                    : 'Select a location',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
