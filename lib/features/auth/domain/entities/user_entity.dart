class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final List<AddressEntity>? addresses;
  final DateTime? createdAt;
  final bool isEmailVerified;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.addresses,
    this.createdAt,
    this.isEmailVerified = false,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    List<AddressEntity>? addresses,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

class AddressEntity {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final Map<String, double>? coordinates;

  AddressEntity({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'Nepal',
    this.isDefault = false,
    this.coordinates,
  });

  String get fullAddress => '$address, $city, $state $zipCode';

  AddressEntity copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    Map<String, double>? coordinates,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      coordinates: coordinates ?? this.coordinates,
    );
  }
}
