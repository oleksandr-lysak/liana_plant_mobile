import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1Ijoicm90dGluZyIsImEiOiJjbGFxc2Jxa3oxbTFrM3B0NzJwdTU0OTJtIn0.eQmKPSN5dCp9XxQcxPzJvA';
  static const String mapBoxStyleId = 'claqrpplh000g14mmffvd0767';
  static const String urlTemplate =
      "https://api.mapbox.com/styles/v1/rotting/$mapBoxStyleId/tiles/256/{z}/{x}/{y}@2x?access_token=$mapBoxAccessToken";

  static const String serverUrl = 'http://10.0.2.2:8002/api/';
  static const String publicServerUrl = 'http://10.0.2.2:8002/';

  static final myLocation = LatLng(47.844637, 11.147302);

  static const String defaultLanguage = 'en';
  static const String appTitle = 'Liana the best';

  static List<DropdownMenuItem<String>> languages = const [
    DropdownMenuItem(
      value: 'en',
      child: Text('English'),
    ),
    DropdownMenuItem(
      value: 'de',
      child: Text('Deutsch'),
    ),
    DropdownMenuItem(
      value: 'uk',
      child: Text('Українська'),
    ),
  ];
}
