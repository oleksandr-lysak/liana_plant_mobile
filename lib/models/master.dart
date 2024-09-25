class Master {
  final int id;
  final String name;
  final String phone;
  final String? address;
  final double latitude;
  final double longitude;
  final String? description;
  final int? age;
  final String? photo;
  final int specialityId;
  List<int> specialities;

  Master({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.age,
    this.photo,
    required this.specialityId,
    this.specialities = const [],
  });

  // Створення об'єкта Master з JSON
  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      id: json['id'] ?? 0,
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'] is double
          ? json['latitude']
          : double.parse(json['latitude'].toString()),
      longitude: json['longitude'] is double
          ? json['longitude']
          : double.parse(json['longitude'].toString()),
      description: json['description'],
      photo: json['photo'],
      specialityId: json['speciality_id'],
      age: json['age'],
      specialities: json['specialities'] != null
          ? List<int>.from(json['specialities'])
          : [],
    );
  }

  // Перетворення об'єкта Master в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'age': age,
      'photo': photo,
      'speciality_id': specialityId,
      'specialities': specialities,
    };
  }
}
