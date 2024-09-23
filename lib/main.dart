import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/pages/booking/booking_page.dart';
import 'package:liana_plant/pages/create_master/summary_info_page.dart';
import 'package:liana_plant/pages/home/home_page.dart';
import 'package:liana_plant/pages/create_master/map_picker_page.dart';
import 'package:liana_plant/pages/create_master/master_creation_page.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/pages/home/map_view.dart';
import 'package:liana_plant/pages/settings/settings_page.dart';
import 'package:liana_plant/providers/specialty_provider.dart';
import 'package:liana_plant/providers/theme_provider.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/log_service.dart';
import 'package:liana_plant/services/api_services/specialty_service.dart';
import 'package:liana_plant/services/token_service.dart';
import 'package:liana_plant/widgets/photo_grid_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'classes/app_scroll_behavior.dart';
import 'classes/app_themes.dart';
import 'firebase_options.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      LogService.log('FlutterError: ${details.exception.toString()}');
      LogService.log('Stack trace: ${details.stack.toString()}');
    } else {
      LogService.log(details.toString());
    }
  };

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final specialtyService = SpecialtyService();
  String? savedLanguage = await LanguageService.getLanguage();
  final tokenService = TokenService();
  final token = await tokenService.getToken();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SpecialtyProvider(specialtyService),
        ),
        Provider<TokenService>(
          create: (context) => TokenService(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(AppThemes.lightTheme), // Додано ThemeProvider
        ),
      ],
      child: MyApp(savedLanguage: savedLanguage, token: token),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? savedLanguage;
  final String? token;

  const MyApp({Key? key, this.savedLanguage, this.token}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  // Список сторінок для навігації
  List<Widget> pages = [];

  List<BottomNavigationBarItem> itemsNavigationBar = [];

  bool isMaster(){
    return widget.token != null && widget.token!.isNotEmpty;
  }
  setNavigationBar() {
    if (isMaster()) {
      itemsNavigationBar = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
      pages = [
        BookingPage(masterId: 0, masterName: '',),
        const MapView(),
        const SettingsPage(),
      ];
    }else{
      itemsNavigationBar = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
      pages = [
        const MapView(),
        const SettingsPage(),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    setNavigationBar();
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        scrollBehavior: AppScrollBehavior(),
        theme: themeProvider.themeData.copyWith(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Theme.of(context).primaryColor, // Колір фону
            selectedItemColor: Theme.of(context)
                .colorScheme
                .secondary, // Колір вибраного елемента
            unselectedItemColor: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.6), // Колір невибраного елемента
          ),
        ),
        themeMode: ThemeMode.system,
        darkTheme: AppThemes.darkTheme,
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
              basePath: 'assets/i18n',
              fallbackFile: AppConstants.defaultLanguage,
              forcedLocale: widget.savedLanguage != null
                  ? Locale(widget.savedLanguage!)
                  : null,
            ),
            missingTranslationHandler: (key, locale) {},
          ),
        ],
        home: Scaffold(
          body: pages[_selectedIndex], // Інші сторінки не змінюються
          bottomNavigationBar: BottomNavigationBar(
            items: itemsNavigationBar,
            currentIndex: _selectedIndex,
            backgroundColor: themeProvider
                .themeData.bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: themeProvider
                .themeData.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: themeProvider
                .themeData.bottomNavigationBarTheme.unselectedItemColor,
            onTap: _onItemTapped, // Зміна сторінки при виборі елемента
          ),
        ),
        routes: {
          '/create-master': (context) => const MasterCreationPage(),
          '/map-picker': (context) => const MapPickerPage(),
          '/photo-grid': (context) => const PhotoGridPage(),
          '/choose-photo': (context) => const PhotoGridPage(),
          //'/booking-page': (context) => BookingPage(),
          '/summary-info': (context) => const SummaryInfoPage(),
          '/home-page': (context) => const HomePage(),
          '/settings-page': (context) => const HomePage(),
        },
      );
    });
  }
}
