import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/pages/booking/booking_page.dart';
import 'package:liana_plant/pages/create_master/summary_info_page.dart';
import 'package:liana_plant/pages/home/home_page.dart';
import 'package:liana_plant/pages/create_master/map_picker_page.dart';
import 'package:liana_plant/pages/create_master/master_creation_page.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/providers/specialty_provider.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/specialty_service.dart';
import 'package:liana_plant/widgets/photo_grid_page.dart';
import 'package:provider/provider.dart';

import 'classes/app_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String serverUrl = AppConstants.serverUrl;
  final specialtyService = SpecialtyService('${serverUrl}specialties');
  String? savedLanguage = await LanguageService.getLanguage();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SpecialtyProvider(specialtyService),
      child: MyApp(savedLanguage: savedLanguage),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? savedLanguage;

  const MyApp({Key? key, this.savedLanguage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark(primary: Styles.primaryColor),
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: 'assets/i18n',
            fallbackFile: AppConstants.defaultLanguage,
            forcedLocale: savedLanguage != null ? Locale(savedLanguage!) : null,
          ),
          missingTranslationHandler: (key, locale) {},
        ),
      ],
      routes: {
        '/create-master': (context) => const MasterCreationPage(),
        '/map-picker': (context) => const MapPickerPage(),
        '/photo-grid': (context) => const PhotoGridPage(),
        '/choose-photo': (context) => const PhotoGridPage(),
        '/booking-page': (context) => BookingPage(),
        '/summary-info': (context) => SummaryInfoPage(),
      },
    );
  }
}
