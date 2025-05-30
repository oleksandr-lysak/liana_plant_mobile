import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserLocationMarker extends StatefulWidget {
  final LatLng location;
  const UserLocationMarker({Key? key, required this.location}) : super(key: key);

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: widget.location,
          width: 30,
          height: 30,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  // decoration: BoxDecoration(
                  //   shape: BoxShape.circle,
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.black.withOpacity(0.5),
                  //       blurRadius: 18,
                  //       spreadRadius: 6,
                  //     ),
                  //   ],
                  // ),
                  child: Icon(Icons.circle, color: Colors.black.withOpacity(0.7), size: 20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 