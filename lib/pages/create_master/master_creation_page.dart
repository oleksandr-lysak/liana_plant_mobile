import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liana_plant/constants/styles.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:latlong2/latlong.dart' as LatLng2;

class MasterCreationPage extends StatefulWidget {
  const MasterCreationPage({super.key});

  @override
  MasterCreationPageState createState() => MasterCreationPageState();
}

class MasterCreationPageState extends State<MasterCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late LatLng2.LatLng location;
  File? _photo;
  String? _photoBase64;
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final List<String> _specialities = [
    'Cosmetics selection',
    'Hair coloring'
  ]; // Example specialities
  String? _selectedSpeciality;
  final List<String> _selectedSpecialities = [];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _photo = File(pickedFile.path);
        _photoBase64 = base64Encode(imageBytes);
      });
    }
  }

  void _showImageSourceDialog() {
    Navigator.pushNamed(context, '/photo-grid');
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Prepare data for submission
      final data = {
        'country_code': _countryCodeController.text,
        'phone': _phoneController.text,
        'name': _nameController.text,
        'password': _passwordController.text,
        'age': int.tryParse(_ageController.text),
        'description': _descriptionController.text,
        'latitude': double.tryParse(_latitudeController.text),
        'longitude': double.tryParse(_longitudeController.text),
        'specialities': _selectedSpecialities,
        'speciality_id': _selectedSpeciality,
        'photo': _photoBase64,
      };

      // Submit the data (e.g., send to server)
      print(data); // Replace with actual submission code
    }
  }

  @override
  Widget build(BuildContext context) {
    location = ModalRoute.of(context)!.settings.arguments as LatLng2.LatLng;

    return Scaffold(
      appBar:
          AppBar(title: Text(FlutterI18n.translate(context, 'create_master'))),
      backgroundColor: Styles.backgroundFormColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: FlutterI18n.translate(context, 'phone'),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Styles.primaryColor), // Задайте тут потрібний колір
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Styles
                            .descriptionColor), // Задайте колір для неактивного стану
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? FlutterI18n.translate(context, 'required')
                    : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, 'name')),
                validator: (value) => value?.isEmpty ?? true
                    ? FlutterI18n.translate(context, 'required')
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: FlutterI18n.translate(context, 'description')),
                maxLines: 4,
                validator: (value) => value?.isEmpty ?? true
                    ? FlutterI18n.translate(context, 'required')
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedSpeciality,
                hint: Text(FlutterI18n.translate(context, 'select_speciality')),
                items: _specialities.map((speciality) {
                  return DropdownMenuItem<String>(
                    value: speciality,
                    child: Text(speciality),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpeciality = value;
                  });
                },
                validator: (value) => value == null
                    ? FlutterI18n.translate(context, 'required')
                    : null,
              ),
              if (_photo != null) Image.file(_photo!),
              TextButton(
                onPressed: _showImageSourceDialog,
                child: Text(FlutterI18n.translate(context, 'pick_photo')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(FlutterI18n.translate(context, 'submit')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
