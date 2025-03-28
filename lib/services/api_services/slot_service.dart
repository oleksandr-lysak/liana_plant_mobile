import 'package:intl/intl.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/slot.dart';
import 'package:liana_plant/models/service.dart';

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

  Future<void> bookSlotFromClient(String name, String phone, bool isBooked,
      DateTime dateTime, Service service, int masterId) async {
    final response =
        await apiService.postRequest('appointments/book', {
      'master_id': masterId,
      'start_time': dateTime.toString(),
      'client_phone': phone,
      'service_id': service.id,
      'duration': 60,
    });
  }
}
