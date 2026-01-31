import 'package:pathau_now/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.profileImage,
    required super.isVerified,
    required super.isActive,
    required super.addresses,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'USER',
      profileImage: json['profileImage'],
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      addresses: json['addresses'] != null
          ? List<AddressModel>.from(
              (json['addresses'] as List).map((x) => AddressModel.fromJson(x)),
            )
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'profileImage': profileImage,
    'isVerified': isVerified,
    'isActive': isActive,
    'addresses': (addresses as List<AddressModel>)
        .map((a) => a.toJson())
        .toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.id,
    required super.label,
    required super.address,
    required super.city,
    super.latitude,
    super.longitude,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      label: json['label'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['coordinates']?['latitude'])?.toDouble(),
      longitude: (json['coordinates']?['longitude'])?.toDouble(),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'label': label,
    'address': address,
    'city': city,
    'coordinates': latitude != null && longitude != null
        ? {'latitude': latitude, 'longitude': longitude}
        : null,
    'isDefault': isDefault,
  };
}
