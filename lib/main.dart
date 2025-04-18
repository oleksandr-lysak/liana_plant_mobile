
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/user.dart';
import 'package:liana_plant/pages/booking/booking_page.dart';
import 'package:liana_plant/pages/create_master/summary_info_page.dart';
import 'package:liana_plant/pages/home/home_page.dart';
import 'package:liana_plant/pages/create_master/map_picker_page.dart';
import 'package:liana_plant/pages/create_master/master_creation_page.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/pages/home/map_view.dart';
import 'package:liana_plant/pages/settings/settings_page.dart';
import 'package:liana_plant/providers/language_provider.dart';
import 'package:liana_plant/providers/notification_provider.dart';
import 'package:liana_plant/providers/service_provider.dart';
import 'package:liana_plant/providers/theme_provider.dart';
import 'package:liana_plant/services/fcm_service.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/log_service.dart';
import 'package:liana_plant/services/api_services/service_service.dart';
import 'package:liana_plant/services/token_service.dart';
import 'package:liana_plant/services/user_service.dart';
import 'package:liana_plant/widgets/photo_grid_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'classes/app_scroll_behavior.dart';
import 'classes/app_themes.dart';
import 'widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

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

  await Firebase.initializeApp();
  final specialtyService = ServiceService();
  String? savedLanguage = await LanguageService.getLanguage();
  final tokenService = TokenService();
  final token = await tokenService.getToken();
  Object? initErr;
  try {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('mapStore').manage.create();
  } catch (err) {
    initErr = err;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ServiceProvider(specialtyService),
        ),
        Provider<TokenService>(
          create: (context) => TokenService(),
        ),
        Provider<UserService>(
          create: (context) => UserService(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ThemeProvider(AppThemes.lightTheme),
        ),
        ChangeNotifierProvider(
            create: (context) => LanguageProvider(
                  savedLanguage != null
                      ? Locale(savedLanguage)
                      : const Locale('en'),
                ),),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: MyApp(savedLanguage: savedLanguage, token: token),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? savedLanguage;
  final String? token;

  const MyApp({Key? key, this.savedLanguage, this.token}) : super(key: key);

  static void restartApp(BuildContext context) {
    final MyAppState state = context.findAncestorStateOfType<MyAppState>()!;
    state.restartApp();
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  int _selectedIndex = 0;
  late Future<List<Widget>> pagesFuture;

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  Future<bool> isMaster() async {
    return await UserService().isMaster();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List<Widget>> setNavigationBar() async {
    List<Widget> pages;
    if (await isMaster()) {
      User? user = await UserService().getUser();
      int masterId = user!.master!.id;
      String masterName = user.master!.name;
      pages = [
        BookingPage(
          masterId: masterId,
          masterName: masterName,
        ),
        const MapView(),
        const SettingsPage(),
      ];
    } else {
      pages = [
        const MapView(),
        const SettingsPage(),
      ];
    }
    return pages;
  }

  @override
  void initState() {
    super.initState();
    pagesFuture = setNavigationBar();
  }

  @override
  Widget build(BuildContext context) {
    FCMService.initializeFCM(context: context);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
        return MaterialApp(
          key: key,
          scrollBehavior: AppScrollBehavior(),
          theme: themeProvider.themeData.copyWith(
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Theme.of(context).primaryColor,
              selectedItemColor: Theme.of(context).colorScheme.secondary,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          themeMode: ThemeMode.system,
          darkTheme: AppThemes.darkTheme,
          localizationsDelegates: [
            FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                basePath: 'assets/i18n',
                fallbackFile: AppConstants.defaultLanguage,
                forcedLocale: languageProvider.locale,
              ),
              missingTranslationHandler: (key, locale) {},
            ),
          ],
          home: FutureBuilder<List<Widget>>(
            future: pagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<Widget> pages = snapshot.data!;
              return Scaffold(
                body: pages[_selectedIndex],
                bottomNavigationBar: CustomBottomNavigationBar(
                  selectedIndex: _selectedIndex,
                  themeProvider: themeProvider,
                  onItemTapped: _onItemTapped,
                ),
              );
            },
          ),
          routes: {
            '/create-master': (context) => const MasterCreationPage(),
            '/map-picker': (context) => const MapPickerPage(),
            '/photo-grid': (context) => const PhotoGridPage(),
            '/choose-photo': (context) => const PhotoGridPage(),
            '/summary-info': (context) => const SummaryInfoPage(),
            '/home-page': (context) => const HomePage(),
            '/settings-page': (context) => const HomePage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/booking-page') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => BookingPage(
                  masterId: args['masterId'],
                  masterName: args['masterName'],
                ),
              );
            }
            return null;
          },
        );
      });
    });
  }
}
