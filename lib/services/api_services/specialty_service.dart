import 'package:liana_plant/models/specialty.dart';

import '../../constants/app_constants.dart';
import 'api_service.dart';

class SpecialtyService {
  final ApiService apiService = ApiService(AppConstants.serverUrl);

  Future<List<Specialty>> fetchSpecialties() async {
    final response = await apiService.getRequest('specialties');
    List<dynamic> specialtiesJson = response['data'];
    return specialtiesJson.map((json) => Specialty.fromJson(json)).toList();
  }

  static Future<Specialty?> getSpecialtyById(int id) async {
    final response =
        await ApiService(AppConstants.serverUrl).getRequest('specialties/$id');
    return Specialty.fromJson(response['data']);
  }

  Future<List<Specialty>> getSpecialtyForMaster(int masterId) async {
    final response = await apiService.getRequest('specialties/get-for-master/$masterId');
    List<dynamic> specialtiesJson = response['data'];
    return specialtiesJson.map((json) => Specialty.fromJson(json)).toList();
  }
}
