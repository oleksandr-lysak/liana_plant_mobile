import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/services/language_service.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key,void Function(String?)? onLanguageChanged, String? selectedLanguage});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final languageCode = await LanguageService.getLanguage();
    setState(() {
      _selectedLanguage = languageCode;
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
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              '${FlutterI18n.translate(context, 'language')}:',
              style: const TextStyle(color: Styles.descriptionColor),
            ),
          ),
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
        ],
      ),
    );
  }
}
