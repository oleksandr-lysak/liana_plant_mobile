import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liana_plant/classes/liana_marker.dart';
import 'package:liana_plant/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import '../classes/app_themes.dart';

class PulsatingIcon extends StatefulWidget {
  final List<LianaMarker> markers;

  const PulsatingIcon({Key? key, required this.markers}) : super(key: key);

  @override
  _PulsatingIconState createState() => _PulsatingIconState();
}

class _PulsatingIconState extends State<PulsatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Анімація буде циклічною

    bool available = false;
    for (LianaMarker marker in widget.markers) {
      if (marker.master.available) {
        available = true;
        break;
      }
    }
    if (available) {
      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else {
      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme =
        Provider.of<ThemeProvider>(context, listen: true).themeData;

    // Визначаємо шлях до іконки в залежності від теми
    String iconPath = currentTheme == AppThemes.darkTheme
        ? 'assets/icons/cluster_dark.svg'
        : 'assets/icons/cluster_light.svg';

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value, // Змінюємо масштаб іконки
          child: SvgPicture.asset(
            'assets/icons/cluster_light.svg',
            //'assets/icons/cluster_dark.svg',
            height: 100, // Можна налаштувати розмір
            width: 100,
          ),
        );
      },
    );
  }
}
