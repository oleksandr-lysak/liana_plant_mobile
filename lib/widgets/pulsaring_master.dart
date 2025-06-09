import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../classes/app_themes.dart';
import '../models/master.dart';
import '../providers/theme_provider.dart';
import '../constants/app_constants.dart';

class PulsatingMaster extends StatefulWidget {
  final Master master;
  final bool isActive;

  const PulsatingMaster({super.key, required this.master, this.isActive = false});

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

    // Формуємо повний URL для фото
    String photoUrl = widget.master.photo.isNotEmpty
        ? '${AppConstants.publicServerUrl}${widget.master.photo}'
        : '';

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.master.available ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      // placeholder: (context, url) => SvgPicture.asset(
                      //   iconPath,
                      //   height: 100,
                      //   width: 100,
                      // ),
                      // errorWidget: (context, url, error) => SvgPicture.asset(
                      //   iconPath,
                      //   height: 100,
                      //   width: 100,
                      // ),
                    )
                  : SvgPicture.asset(
                      iconPath,
                      height: 100,
                      width: 100,
                    ),
            ),
          ),
        );
      },
    );
  }
}
