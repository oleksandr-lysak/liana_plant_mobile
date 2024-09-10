import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/models/map_marker_model.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.asset(
      'assets/images/location-jump.gif',
      width: 150, // налаштуйте розміри за потреби
      height: 150,
    ));
  }
}
