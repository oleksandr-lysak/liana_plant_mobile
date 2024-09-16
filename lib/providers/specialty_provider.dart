import 'package:flutter/material.dart';
import 'package:liana_plant/models/specialty.dart';
import 'package:liana_plant/services/api_services/specialty_service.dart';

class SpecialtyProvider with ChangeNotifier {
  final SpecialtyService _service;
  List<Specialty> _specialties = [];
  bool _isLoading = false;
  String? _errorMessage;

  SpecialtyProvider(this._service);

  List<Specialty> get specialties => _specialties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSpecialties() async {
    _isLoading = true;
    notifyListeners();

    try {
      _specialties = await _service.fetchSpecialties();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
