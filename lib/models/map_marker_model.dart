// import 'dart:convert';
// import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:dio/dio.dart';

class MapMarker {
  final String? image;
  final String? title;
  final String? address;
  final LatLng? location;
  final String? description;
  final int? rating;
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
    return MapMarker(
      image: (json['image'] ?? '') as String,
      title: json['name'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      location: LatLng(
          double.parse(json['latitude']), double.parse(json['longitude'])),
      rating: json['rating'] as int,
      phone: json['phone'] as String,
    );
  }
}

late Response response;
Dio dio = Dio();

bool error = false; //for error status
String errmsg = ""; //to assing any error message from API/runtime
var apidata; //for decoded JSON data

//var MapMarkers = getData();

Future<List<MapMarker>> getData(
    double longitude, double latitude, double zoom) async {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    LocationPermission permission = await Geolocator.checkPermission();
  }

  String url = "http://10.0.2.2:8002/api/masters?long=" +
      longitude.toString() +
      '&lat=' +
      latitude.toString() +
      '&zoom=' +
      zoom.toString();
  print(url);
  Response response = await dio.get(url);
  apidata = response.data; //get JSON decoded data from response

  var tagObjsJson = apidata as List;
  List<MapMarker> tagObjs =
      tagObjsJson.map((tagJson) => MapMarker.fromJson(tagJson)).toList();

  return tagObjs;
}
