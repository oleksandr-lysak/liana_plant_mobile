import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/services/token_service.dart';

import '../../models/slot.dart';

class SlotService {
  final String apiUrl = AppConstants.serverUrl;

  // Метод для отримання слотів з бекенду
  Future<List<Slot>> getSlots(DateTime date) async {
    String? token = await TokenService().getToken();
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(date); // Форматування дати

    final response = await http.get(
      Uri.parse('${apiUrl}time-slots/date=$formattedDate'),
      headers: {
        'Authorization': 'Bearer $token', // Додаємо токен в заголовок
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey('data')) {
        List<dynamic> slotsJson = jsonResponse['data'];

        List<Slot> slots =
            slotsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();

        return slots;
      } else {
        throw Exception('Unexpected response format');
      }
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
