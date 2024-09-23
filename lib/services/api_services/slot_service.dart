import 'package:intl/intl.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/slot.dart';

import 'api_service.dart';

class SlotService {
  final ApiService apiService = ApiService(AppConstants.serverUrl);

  Future<List<Slot>> getSlots(DateTime date, {int masterId = 0}) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await apiService.getRequest('time-slots/date=$formattedDate/$masterId');
    List<dynamic> slotsJson = response['data'];
    return slotsJson.map((slotJson) => Slot.fromJson(slotJson)).toList();
  }

  Future<void> bookSlot(String client, String service) async {
    await apiService.postRequest('time-slots/store', {'client': client, 'service': service});
  }
}
