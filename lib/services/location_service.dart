import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:liana_plant/constants/app_constants.dart';

class LocationService {
  static Future<LatLng> getCurrentLocation() async {
    if (await Geolocator.isLocationServiceEnabled()) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } else {
      return const LatLng(50.249198, 30.350024);
    }
  }

  static Future<String> getCountry(LatLng location) async {
    String apiKey = AppConstants.googleMapsApiKey;
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        // Перевіряємо кожен компонент адреси, щоб знайти країну
        for (var result in data['results']) {
          for (var component in result['address_components']) {
            if (component['types'].contains('country')) {
              return component['long_name']; // Повертаємо код країни
            }
          }
        }
      }
    }

    return ''; // Якщо не знайшли країну
  }

  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com//maps/api/geocode/json?latlng=$latitude,$longitude&key=${AppConstants.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
    return null;
  }
}
