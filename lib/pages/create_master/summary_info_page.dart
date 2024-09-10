import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/models/specialty.dart';
import 'package:liana_plant/services/location_service.dart';
import 'package:liana_plant/services/specialty_service.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:latlong2/latlong.dart' as latlng;

class SummaryInfoPage extends StatefulWidget {
  @override
  SummaryInfoPageState createState() => SummaryInfoPageState();
}

class SummaryInfoPageState extends State<SummaryInfoPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  latlng.LatLng? _selectedLocation;
  String? _phone;
  String? _name;
  String? _description;
  int? _specialtyId;
  String? _photoId;
  String? _address;
  String? _placeId;
  bool isLoading = true;
  File? _photoFile;
  Specialty? _specialty;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as List<dynamic>?;
      if (args != null) {
        _selectedLocation = args[0] as latlng.LatLng?;
        _phone = args[1] as String?;
        _name = args[2] as String?;
        _description = args[3] as String?;
        _specialtyId = args[4] as int?;
        _photoId = args[5] as String?;
      }
      initData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initData() async {
    if (_selectedLocation != null) {
      _address = await LocationService.getAddressFromCoordinates(
        _selectedLocation!.latitude, 
        _selectedLocation!.longitude
      );
    }
    if (_photoId != null) {
      await _getPhotoFromGallery(_photoId!);
    }
    if (_specialtyId != null) {
      _specialty = await SpecialtyService.getSpecialtyById(_specialtyId!);
    }
    setState(() {
      isLoading = false;
      _animationController.forward();
    });
  }

  Future<void> _getPhotoFromGallery(String photoId) async {
      final albums = await PhotoManager.getAssetPathList(onlyAll: true);

      for (final album in albums) {
        final assets = await album.getAssetListPaged(page: 0, size: 100);
        for (final asset in assets) {
          if (asset.id == photoId) {
            final file = await asset.file;
            setState(() {
              _photoFile = file;
            });
            return;
          }
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Loading(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'summary_info_page.title')),
          backgroundColor: Styles.backgroundColor,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Styles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
            ),
            onPressed: _registerUser,
            child: Text(
              FlutterI18n.translate(context, 'summary_info_page.register_button'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildContent() {
    return ListView(
      children: [
        if (_photoFile != null) _buildPhotoTile(),
        if (_address != null) _buildInfoTile(FlutterI18n.translate(context, 'summary_info_page.address'), _address!),
        _buildInfoTile(FlutterI18n.translate(context, 'summary_info_page.phone'), _phone ?? FlutterI18n.translate(context, 'summary_info_page.not_provided')),
        _buildInfoTile(FlutterI18n.translate(context, 'summary_info_page.name'), _name ?? FlutterI18n.translate(context, 'summary_info_page.not_provided')),
        _buildInfoTile(FlutterI18n.translate(context, 'summary_info_page.description'), _description ?? FlutterI18n.translate(context, 'summary_info_page.not_provided')),
        _buildInfoTile(
            FlutterI18n.translate(context, 'summary_info_page.specialty'), _specialty?.name ?? FlutterI18n.translate(context, 'summary_info_page.not_provided')),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 16,
              color: Styles.descriptionColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Styles.textInputColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            FlutterI18n.translate(context, 'summary_info_page.photo'),
            style: const TextStyle(
              fontSize: 16,
              color: Styles.descriptionColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Styles.textInputColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _photoFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(
                      _photoFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Styles.subtitleColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _registerUser() {
    // Логіка реєстрації користувача
    print(FlutterI18n.translate(context, 'summary_info_page.registration_data'));
    print('${FlutterI18n.translate(context, 'summary_info_page.phone')}: $_phone');
    print('${FlutterI18n.translate(context, 'summary_info_page.name')}: $_name');
    print('${FlutterI18n.translate(context, 'summary_info_page.description')}: $_description');
    print('${FlutterI18n.translate(context, 'summary_info_page.specialty_id')}: $_specialtyId');
    print('${FlutterI18n.translate(context, 'summary_info_page.specialty')}: ${_specialty?.name}');
    print('${FlutterI18n.translate(context, 'summary_info_page.address')}: $_address');
    print('${FlutterI18n.translate(context, 'summary_info_page.place_id')}: $_placeId');
    print('${FlutterI18n.translate(context, 'summary_info_page.location')}: $_selectedLocation');
  }
}
