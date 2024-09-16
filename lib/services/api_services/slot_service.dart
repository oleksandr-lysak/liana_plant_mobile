import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:liana_plant/constants/app_constants.dart';

class SlotService {
  final String apiUrl = AppConstants.serverUrl;

  // Метод для отримання слотів з бекенду
  Future<List<Map<String, dynamic>>> getSlots(DateTime date) async {
    final response = await http
        .get(Uri.parse('$apiUrl/time-slots?date=${date.toIso8601String()}'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((slot) => slot as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load slots');
    }
  }

  // Метод для бронювання слоту
  Future<void> bookSlot(String client, String service) async {
    final response = await http.post(
      Uri.parse('$apiUrl/time-slots/store'),
      body: jsonEncode({'client': client, 'service': service}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to book slot');
    }
  }
}
