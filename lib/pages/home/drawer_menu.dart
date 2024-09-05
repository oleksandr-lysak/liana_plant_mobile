import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/constants/app_constants.dart';

class DrawerMenu extends StatelessWidget {
  final String? selectedLanguage;
  final Function(String?) onLanguageChanged;

  const DrawerMenu({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  void _changeLanguage(BuildContext context, String? languageCode) async {
    if (languageCode != null) {
      await FlutterI18n.refresh(context, Locale(languageCode));
      onLanguageChanged(languageCode);
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
              value: selectedLanguage,
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
