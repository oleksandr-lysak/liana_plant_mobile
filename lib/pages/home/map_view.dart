import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/services/fcm_service.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:liana_plant/widgets/map_card.dart';
import 'package:liana_plant/services/location_service.dart';
import 'package:liana_plant/services/animation_service.dart';
import 'package:liana_plant/widgets/pulsaring_master.dart';
import 'package:liana_plant/widgets/pulsating_icon.dart';
import 'package:provider/provider.dart';

import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import '../../classes/liana_marker.dart';
import '../../models/master.dart';
import '../../providers/theme_provider.dart';
import '../../services/language_service.dart';
import 'package:liana_plant/widgets/animated_dropdown_field.dart';
import 'package:liana_plant/providers/service_provider.dart';
import 'package:liana_plant/widgets/map_filter_dialog.dart';
import 'package:liana_plant/widgets/user_location_marker.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with TickerProviderStateMixin {
  final pageController = PageController();
  static final MapController mapController = MapController();
  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  late AnimationController _animationController;
  List<Master> mapMasters = [];
  List<LianaMarker> masters = [];
  LatLng? currentLocation;
  int selectedIndex = 0;
  bool loading = true;
  int totalPages = 1;
  int currentPage = 1;

  String? filterName;
  double? filterRating;
  bool? filterAvailable;
  int? filterServiceId;
  String? sortBy;

  DropdownItem? selectedService;
  TextEditingController nameController = TextEditingController();
  double? selectedRating;
  bool? selectedAvailable;
  String? selectedSort;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadSpecialties();
    });
    _initLocationAndLoadData();
  }

  Future<void> _initLocationAndLoadData() async {
    final location = await LocationService.getCurrentLocation();
    setState(() {
      currentLocation = location;
    });
    await _loadMapData(location);
  }

  Future<List<Master>> getData(
      double longitude, double latitude, int page, double zoom) async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      await Geolocator.checkPermission();
    }

    String serverUrl = AppConstants.serverUrl;
    final String locale = await LanguageService.getLanguage() ?? 'en';
    final fcmToken = await FCMService.getToken();
    Map<String, dynamic> params = {
      'lng': longitude,
      'lat': latitude,
      'zoom': zoom,
      'page': page,
      'locale': locale,
      'fcm_token': fcmToken,
    };
    if (filterName != null && filterName!.isNotEmpty) params['name'] = filterName;
    if (filterRating != null) params['rating'] = filterRating;
    if (filterAvailable != null) params['available'] = filterAvailable! ? 1 : 0;
    if (filterServiceId != null) params['service_id'] = filterServiceId;
    if (sortBy != null && sortBy!.isNotEmpty) params['sort'] = sortBy;

    String url = '${serverUrl}masters?';
    url += params.entries.map((e) => "${e.key}=${e.value}").join('&');

    Response response = await dio.get(url);
    apiData = response.data;
    var tagObjsJson = apiData["data"] as List;
    List<Master> tagObjs =
        tagObjsJson.map((tagJson) => Master.fromJson(tagJson)).toList();

    return tagObjs;
  }

  Future<void> _loadMapData(LatLng position) async {
    double zoom = 13;

    final stopwatch = Stopwatch()..start();
    if (totalPages >= 1) {
      await _fetchMarkers(
        position.longitude,
        position.latitude,
        currentPage,
        zoom,
        updateImmediately: true,
      );
    }
    stopwatch.stop();

    if (totalPages > 1) {
      List<Future<List<Master>>> fetchRequests = [];

      for (int page = 2; page <= totalPages; page++) {
        fetchRequests
            .add(getData(position.longitude, position.latitude, page, zoom));
      }

      List<List<Master>> results = await Future.wait(fetchRequests);

      setState(() {
        for (var masters in results) {
          mapMasters.addAll(masters);
        }
        _createMarkers();
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _fetchMarkers(
      double longitude, double latitude, int page, double zoom,
      {bool updateImmediately = false}) async {
    final masters = await getData(longitude, latitude, page, zoom);
    setState(() {
      mapMasters.addAll(masters);
      if (page == 1) {
        totalPages = masters.isNotEmpty ? apiData["meta"]["last_page"] : 1;
      }

      if (updateImmediately) {
        _createMarkers();
        loading = false;
      }
    });
  }

  void _createMarkers() {
    masters.clear();
    for (int i = 0; i < mapMasters.length; i++) {
      final master = mapMasters[i];
      masters.add(
        LianaMarker(
          height: 40,
          width: 40,
          point: master.location,
          master: master,
          child: GestureDetector(
            onTap: () {
              _onMarkerTap(i);
            },
            child: PulsatingMaster(master: master),
          ),
        ),
      );
    }
  }

  void _onMarkerTap(int index) {
    setState(() {
      selectedIndex = index;
      currentLocation = mapMasters[index].location;
    });

    AnimationService.animatedMapMove(
      mapController,
      _animationController,
      currentLocation!,
      mapController.camera.zoom,
    );
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  void _moveToCurrentLocation() {
    if (currentLocation == null) return;
    AnimationService.animatedMapMove(
      mapController,
      _animationController,
      currentLocation!,
      18,
    );
  }

  void _showFilterDialog() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return MapFilterDialog(
          services: serviceProvider.services,
          initialName: filterName,
          initialServiceId: filterServiceId,
          initialRating: filterRating,
          initialAvailable: filterAvailable,
          initialSort: sortBy,
          onApply: ({String? name, int? serviceId, double? rating, bool? available, String? sort}) async {
            setState(() {
              filterName = name;
              filterServiceId = serviceId;
              filterRating = rating;
              filterAvailable = available;
              sortBy = sort;
              mapMasters.clear();
              masters.clear();
              loading = true;
              currentPage = 1;
            });
            if (currentLocation != null) {
              await _loadMapData(currentLocation!);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Center(child: Loading());
    }
    return loading
        ? const Center(
            child: Loading(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                FlutterI18n.translate(context, 'map_view.title'),
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.brightness_6, color: Colors.black),
                  onPressed: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme();
                  },
                ),
              ],
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    minZoom: 2,
                    maxZoom: 18,
                    initialZoom: 11,
                    initialCenter: currentLocation!,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.it-pragmat.plant',
                      tileProvider: const FMTCStore('mapStore').getTileProvider(),
                    ),
                    // User location marker
                    if (currentLocation != null)
                      UserLocationMarker(location: currentLocation!),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 100,
                        size: const Size(80, 80),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(50),
                        maxZoom: 15,
                        showPolygon: false,
                        markers: masters,
                        builder: (context, masters) {
                          return SizedBox(
                            width: 120,
                            height: 120,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: PulsatingIcon(
                                    markers: masters.cast<LianaMarker>(),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '${masters.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                DraggableScrollableSheet(
                  controller: sheetController,
                  maxChildSize: 0.37,
                  initialChildSize: 0.37,
                  minChildSize: 0.07,
                  builder: (BuildContext context, scrollController) {
                    return CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: PageView.builder(
                              controller: pageController,
                              onPageChanged: (value) {
                                _onMarkerTap(value);
                              },
                              itemCount: mapMasters.length,
                              itemBuilder: (_, index) {
                                return Stack(
                                  children: [
                                    MapCard(item: mapMasters[index]),
                                    Positioned(
                                      top:
                                          20,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).hintColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                          ),
                                          height: 4,
                                          width: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: MediaQuery.of(context).size.height * 0.01,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/map-picker');
                    },
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 10.0,
                    child: Icon(Icons.add_location_alt_outlined,
                        color: Theme.of(context).indicatorColor),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 +
                      165,
                  child: FloatingActionButton(
                    onPressed: _moveToCurrentLocation,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 10.0,
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).indicatorColor,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 + 235,
                  child: FloatingActionButton(
                    heroTag: 'filter_fab',
                    onPressed: _showFilterDialog,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 10.0,
                    child: Icon(Icons.filter_alt, color: Theme.of(context).indicatorColor),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: MediaQuery.of(context).size.height * 0.3 + 30,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoom_in_fab',
                        onPressed: () {
                          final zoom = mapController.camera.zoom + 1;
                          mapController.move(mapController.camera.center, zoom);
                        },
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        elevation: 10.0,
                        child: Icon(Icons.zoom_in, color: Theme.of(context).indicatorColor),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'zoom_out_fab',
                        onPressed: () {
                          final zoom = mapController.camera.zoom - 1;
                          mapController.move(mapController.camera.center, zoom);
                        },
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        elevation: 10.0,
                        child: Icon(Icons.zoom_out, color: Theme.of(context).indicatorColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    _animationController.dispose();
    pageController.dispose();
    super.dispose();
  }
}
