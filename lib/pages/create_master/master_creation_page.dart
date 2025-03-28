import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/widgets/animated_dropdown_field.dart';
import 'package:liana_plant/widgets/animated_text_field.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:provider/provider.dart'; // Додати імпорт для провайдера
import 'package:liana_plant/providers/service_provider.dart'; // Імпорт для провайдера спеціальностей
import 'package:latlong2/latlong.dart' as latlong;

import '../../providers/theme_provider.dart'; // Імпорт для роботи з геолокацією

class MasterCreationPage extends StatefulWidget {
  const MasterCreationPage({super.key});

  @override
  MasterCreationPageState createState() => MasterCreationPageState();
}

class MasterCreationPageState extends State<MasterCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  latlong.LatLng? _selectedLocation;
  DropdownItem? selectedItem;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Ініціалізація даних з провайдера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadSpecialties();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Отримання провайдера
    final serviceProvider = Provider.of<ServiceProvider>(context);
    _selectedLocation =
        ModalRoute.of(context)?.settings.arguments as latlong.LatLng;

    if (serviceProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
            title: Text(FlutterI18n.translate(context, 'create_master'))),
        body: const Center(child: Loading()),
      );
    }

    if (serviceProvider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
            title: Text(FlutterI18n.translate(context, 'create_master'))),
        body: Center(child: Text('Error: ${serviceProvider.errorMessage}')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'create_master')),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.brightness_6,
              color: Colors.black,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next, color: Colors.black),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pushNamed(
                  context,
                  '/choose-photo',
                  arguments: [
                    _selectedLocation,
                    _phoneController.text,
                    _nameController.text,
                    _descriptionController.text,
                    selectedItem?.id,
                  ],
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AnimatedTextField(
                controller: _phoneController,
                labelText: '${FlutterI18n.translate(context, 'phone')} (+380 xxx xx xx)',
                hintText: FlutterI18n.translate(context, 'enter_phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return FlutterI18n.translate(context, 'required');
                  }
                  // Регулярний вираз для валідації українського мобільного номера
                  final RegExp phoneRegExp = RegExp(r'^\+380\d{9}$');
                  if (!phoneRegExp.hasMatch(value)) {
                    return FlutterI18n.translate(context, 'invalid_phone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AnimatedTextField(
                controller: _nameController,
                labelText: FlutterI18n.translate(context, 'name'),
                hintText: FlutterI18n.translate(context, 'enter_name'),
                validator: (value) => value?.isEmpty ?? true
                    ? FlutterI18n.translate(context, 'required')
                    : null,
              ),
              const SizedBox(height: 20),
              AnimatedTextField(
                controller: _descriptionController,
                labelText: FlutterI18n.translate(context, 'description'),
                hintText: FlutterI18n.translate(context, 'enter_description'),
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true
                    ? FlutterI18n.translate(context, 'required')
                    : null,
              ),
              const SizedBox(height: 20),
              AnimatedDropdownField(
                labelText: FlutterI18n.translate(context, 'select_speciality'),
                hintText: FlutterI18n.translate(context, 'choose_speciality'),
                items: serviceProvider.services
                    .map((service) =>
                        DropdownItem(id: service.id, name: service.name))
                    .toList(),
                selectedItem: selectedItem,
                validator: (value) => value?.id.isNaN ?? true
                    ? FlutterI18n.translate(context, 'required')
                    : null,
                onChanged: (DropdownItem? value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Your submit logic here
    }
  }
}
