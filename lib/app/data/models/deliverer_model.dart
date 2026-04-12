class DelivererModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? description;
  final String? logo;
  final DeliveryZoneModel zone;
  final DelivererUserModel? user;

  DelivererModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.description,
    this.logo,
    required this.zone,
    this.user,
  });

  factory DelivererModel.fromJson(Map<String, dynamic> json) {
    return DelivererModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      zone: DeliveryZoneModel.fromJson(json['zone'] as Map<String, dynamic>),
      user: json['user'] != null
          ? DelivererUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'description': description,
      'logo': logo,
      'zone': zone.toJson(),
      'user': user?.toJson(),
    };
  }
}

class DeliveryZoneModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;

  DeliveryZoneModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneModel(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class DelivererUserModel {
  final int id;
  final String name;
  final String phone;

  DelivererUserModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory DelivererUserModel.fromJson(Map<String, dynamic> json) {
    return DelivererUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}
