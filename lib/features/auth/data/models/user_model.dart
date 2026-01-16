import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.name,
    required super.email,
    required super.password,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    String password = "",
  }) {
    return UserModel(
      name: (json["name"] ?? "").toString(),
      email: (json["email"] ?? "").toString(),
      password:
          password, // we keep password because your UserEntity requires it
    );
  }
}
