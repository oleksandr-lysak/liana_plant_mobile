import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../classes/app_themes.dart';
import '../models/master.dart';
import '../providers/theme_provider.dart';

class PulsatingMaster extends StatefulWidget {
  final Master master;

  const PulsatingMaster({Key? key, required this.master}) : super(key: key);

  @override
  PulsatingIconState createState() => PulsatingIconState();
}

class PulsatingIconState extends State<PulsatingMaster>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..repeat(reverse: true);
    if (widget.master.available) {
      _bounceAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));
    } else {
      _bounceAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));
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
        ? 'assets/icons/location.svg'
        : 'assets/icons/location.svg';

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset:
              Offset(0, _bounceAnimation.value), // Анімація стрибка по осі Y
          child: SvgPicture.asset(
            iconPath,
            height: 70, // Налаштування розміру
            width: 70,
          ),
        );
      },
    );
  }
}
