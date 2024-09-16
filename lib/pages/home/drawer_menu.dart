import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/token_service.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu(
      {super.key,
      void Function(String?)? onLanguageChanged,
      String? selectedLanguage});

  @override
  DrawerMenuState createState() => DrawerMenuState();
}

class DrawerMenuState extends State<DrawerMenu> {
  String? _selectedLanguage;
  bool _isTokenPresent = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    _checkToken();
  }

  Future<void> _loadSelectedLanguage() async {
    final languageCode = await LanguageService.getLanguage();
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _checkToken() async {
    final tokenService = TokenService();
    final token = await tokenService.getToken();
    setState(() {
      _isTokenPresent = token != null && token.isNotEmpty;
    });
  }

  void _changeLanguage(BuildContext context, String? languageCode) async {
    if (languageCode != null) {
      await FlutterI18n.refresh(context, Locale(languageCode));
      await LanguageService.saveLanguage(languageCode);
      setState(() {
        _selectedLanguage = languageCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              items: AppConstants.languages,
              onChanged: (String? newValue) {
                _changeLanguage(context, newValue);
              },
            ),
          ),
          if (_isTokenPresent) // Додаємо перевірку наявності токена
            ListTile(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(FlutterI18n.translate(context, 'booking_panel')),
                    const Icon(Icons.edit_calendar),
                  ]),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/booking-page',
                );
              },
            ),
          ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(FlutterI18n.translate(context, 'settings')),
                  const Icon(Icons.settings),
                ]),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/settings-page',
              );
            },
          ),
        ],
      ),
    );
  }
}
