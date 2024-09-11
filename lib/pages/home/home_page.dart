import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/pages/home/drawer_menu.dart';
import 'package:liana_plant/pages/home/map_view.dart';

import '../../services/language_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    loadSelectedLanguage();
  }

  Future<void> loadSelectedLanguage() async {
    final languageCode = await LanguageService.getLanguage();
    setState(() {
      selectedLanguage = languageCode;
    });
  }

  void onLanguageChanged(String? languageCode) {
    setState(() {
      selectedLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: DrawerMenu(
        selectedLanguage: selectedLanguage,
        onLanguageChanged: onLanguageChanged,
      ),
      appBar: AppBar(
        backgroundColor: Styles.backgroundColor,
        title: const Text(AppConstants.appTitle),
      ),
      body: const MapView(),
    );
  }
}
