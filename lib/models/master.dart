class Master {
  final String name;
  final String email;
  final String phone;
  final String? address;
  final double latitude;
  final double longitude;
  final String? description;
  final int? age;
  final String? photo;
  final int specialityId;

  Master({
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.age,
    this.photo,
    required this.specialityId,
  });

  // Створення об'єкта Master з JSON
  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      photo: json['photo'],
      specialityId: json['speciality_id'],
    );
  }

  // Перетворення об'єкта Master в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'age': age,
      'photo': photo,
      'speciality_id': specialityId,
    };
  }
}
