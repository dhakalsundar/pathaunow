import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.profileImage,
    super.addresses,
    super.createdAt,
    super.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    if (map.containsKey('user') && map['user'] is Map) {
      map.addAll(Map<String, dynamic>.from(map['user']));
    }
    if (map.containsKey('data') &&
        map['data'] is Map &&
        map['data']['user'] is Map) {
      map.addAll(Map<String, dynamic>.from(map['data']['user']));
    }

    final createdAtRaw = map['createdAt'] ?? map['created_at'];
    DateTime? createdAt;
    if (createdAtRaw != null) {
      try {
        createdAt = DateTime.tryParse(createdAtRaw.toString());
      } catch (_) {
        createdAt = null;
      }
    }

    final isEmailVerifiedRaw =
        map['isEmailVerified'] ??
        map['is_email_verified'] ??
        map['emailVerified'];
    final isEmailVerified = (isEmailVerifiedRaw is bool)
        ? isEmailVerifiedRaw
        : (isEmailVerifiedRaw != null &&
              (isEmailVerifiedRaw.toString() == 'true'));

    return UserModel(
      id: (map["_id"] ?? map["id"] ?? "").toString(),
      name: (map["name"] ?? "").toString(),
      email: (map["email"] ?? "").toString(),
      phone: (map["phone"] ?? "").toString(),
      profileImage: map["profileImage"],
      createdAt: createdAt,
      isEmailVerified: isEmailVerified,
    );
  }
}
