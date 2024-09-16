import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/specialty.dart';
import 'package:liana_plant/services/log_service.dart';

class SpecialtyService {
  final String apiUrl;

  SpecialtyService(this.apiUrl);

  Future<List<Specialty>> fetchSpecialties() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> specialtiesJson = data['data'];
        return specialtiesJson.map((json) {
          Specialty specialty = Specialty.fromJson(json);
          return specialty;
        }).toList();
      } else {
        throw Exception('Failed to load specialties');
      }
    } catch (e) {
      throw Exception('Failed to fetch specialties: $e');
    }
  }

  static Future<Specialty?> getSpecialtyById(int id) async {
    const baseUrl = AppConstants.serverUrl;
    final url = '${baseUrl}specialties/$id'; // Замість URL вкажіть свій API
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Specialty.fromJson(data['data']);
      }
    } catch (e) {
      LogService.log('Error fetching specialty: $e');
    }
    return null;
  }
}
