import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class LocationFloatingButtons extends StatelessWidget {
  final MapController mapController;

  const LocationFloatingButtons({Key? key, required this.mapController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      bottom: MediaQuery.of(context).size.height * 0.3 + 30,
      child: Column(
        children: [
          FloatingActionButton(
            onPressed: () {
              mapController.zoomIn();
            },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 10.0,
            child: Icon(Icons.zoom_in, color: Theme.of(context).indicatorColor),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              mapController.zoomOut();
            },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 10.0,
            child:
                Icon(Icons.zoom_out, color: Theme.of(context).indicatorColor),
          ),
        ],
      ),
    );
  }
}
