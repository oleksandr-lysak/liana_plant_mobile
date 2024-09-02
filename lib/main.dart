import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/pages/home_page.dart';
import 'package:liana_plant/pages/map_picker_page.dart';
import 'package:liana_plant/pages/master_creation_page.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:liana_plant/widgets/photo_grid_page.dart';

import 'classes/app_scrol_behavior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      home: const HomePage(),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: 'assets/i18n',
            fallbackFile: AppConstants.defaultLanguage,
            forcedLocale: const Locale(AppConstants.defaultLanguage),
          ),
          missingTranslationHandler: (key, locale) {
            print('Missing Key: $key, locale: $locale');
          },
        ),
      ],
      routes: {
        '/create-master': (context) => const MasterCreationPage(),
        '/map-picker': (context) => const MapPickerPage(),
        '/photo-grid': (context) => const PhotoGridPage(),
      },
    );
  }
}
