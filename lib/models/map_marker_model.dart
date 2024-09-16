import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:dio/dio.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/services/language_service.dart';

class MapMarker {
  final String? image;
  final String? title;
  final String? address;
  final LatLng? location;
  final String? description;
  final double? rating;
  final String? phone;

  MapMarker({
    required this.image,
    required this.title,
    required this.address,
    required this.description,
    required this.location,
    required this.rating,
    required this.phone,
  });

  factory MapMarker.fromJson(dynamic json) {
    double lng = json['longitude'] as double;
    double lat = json['latitude'] as double;
    return MapMarker(
      image: (json['main_photo'] ?? '') as String,
      title: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      location: LatLng(lat, lng),
      rating: double.parse(json['rating'].toString()),
      phone: json['phone'] as String,
    );
  }
}

late Response response;
Dio dio = Dio();

bool error = false; //for error status
String errMsg = ""; //to assing any error message from API/runtime
late Map<String, dynamic> apiData; //for decoded JSON data

Future<List<MapMarker>> getData(
    double longitude, double latitude, double zoom) async {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Geolocator.checkPermission();
  }
  String serverUrl = AppConstants.serverUrl;
  final String locale = await LanguageService.getLanguage() ?? 'en';
  String url =
      '${serverUrl}masters?lng=$longitude&lat=$latitude&zoom=$zoom&page=1&locale=$locale';

  Response response = await dio.get(url);
  apiData = response.data; //get JSON decoded data from response

  var tagObjsJson = apiData["data"] as List;
  List<MapMarker> tagObjs =
      tagObjsJson.map((tagJson) => MapMarker.fromJson(tagJson)).toList();

  return tagObjs;
}
