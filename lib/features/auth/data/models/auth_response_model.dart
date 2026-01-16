import 'user_model.dart';

class AuthResponseModel {
  final String? token;
  final UserModel? user;

  AuthResponseModel({this.token, this.user});

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json, {
    required String password,
    required String fallbackEmail,
  }) {
    final token = json["token"]?.toString();
    Map<String, dynamic>? userJson;
    final u = json["user"];
    if (u is Map) userJson = Map<String, dynamic>.from(u);

    final data = json["data"];
    if (userJson == null && data is Map) {
      final du = data["user"];
      if (du is Map) userJson = Map<String, dynamic>.from(du);
    }

    final user = userJson != null
        ? UserModel.fromJson(userJson, password: password)
        : UserModel(name: "", email: fallbackEmail, password: password);

    return AuthResponseModel(token: token, user: user);
  }
}
