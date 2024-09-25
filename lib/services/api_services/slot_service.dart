import 'package:intl/intl.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/slot.dart';
import 'package:liana_plant/models/specialty.dart';

import 'api_service.dart';

class SlotService {
  final ApiService apiService = ApiService(AppConstants.serverUrl);

  Future<List<Slot>> getSlots(DateTime date, {int masterId = 0}) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response =
        await apiService.getRequest('time-slots/date=$formattedDate/$masterId');
    List<dynamic> slotsJson = response['data'];
    return slotsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
  }

  Future<void> bookSlot(String client, String service) async {
    await apiService.postRequest(
        'time-slots/store', {'client': client, 'service': service});
  }

  Future<void> bookSlotFromClient(
      String name, String phone, bool isBooked, DateTime dateTime, Specialty specialty, int masterId) async {
    
    final response = await apiService.postRequest('time-slots/store-from-client/$masterId', {
      'master_id': masterId,
      'date': dateTime.toString(),
      'time': "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}",
      'is_booked': true,
      'client_name': name,
      'client_phone': phone,
      'service_id': specialty.id,
      'source': 'client',
      'duration': 60,
    });
  }
}
