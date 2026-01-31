/// User Entity
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final bool isVerified;
  final bool isActive;
  final List<AddressEntity> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    required this.isVerified,
    required this.isActive,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRider => role == 'RIDER';
  bool get isAdmin => role == 'ADMIN';

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    bool? isVerified,
    bool? isActive,
    List<AddressEntity>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserEntity(id: $id, name: $name, role: $role)';
}

class AddressEntity {
  final String id;
  final String label;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  @override
  String toString() => 'AddressEntity(label: $label, address: $address)';
}
