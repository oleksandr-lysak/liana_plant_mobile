import 'package:liana_plant/models/specialty.dart';

class Slot {
  int? id;
  DateTime date;
  bool isBooked;
  String? clientName;
  String? source;
  Duration duration;
  String? clientPhone;
  Specialty? service;

  Slot({
    this.id,
    required this.date,
    required this.isBooked,
    this.clientName,
    this.source,
    required this.duration,
    this.clientPhone,
    this.service,
  });

  // Метод для створення об'єкта Slot з JSON
  factory Slot.fromJson(Map<String, dynamic> json) {
    String dateTimeString = '${json['date']} ${json['time']}';
    return Slot(
      id: json['id'],
      date: DateTime.parse(dateTimeString),
      isBooked: json['is_booked'] == 1,
      clientName: json['client_name'],
      source: json['source'],
      duration: Duration(minutes:  json['duration']),
      clientPhone: json['client_phone'],
      service: Specialty.fromJson(json['service']),
    );
  }
}