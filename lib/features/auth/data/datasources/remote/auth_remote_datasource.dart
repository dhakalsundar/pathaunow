import 'package:pathau_now/core/api/api_client.dart';
import 'package:pathau_now/core/api/api_endpoints.dart';

import '../../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final ApiClient api;

  AuthRemoteDatasource({required this.api});

  Future<AuthResponseModel> login(String email, String password) async {
    final res = await api.post(
      ApiEndpoints.login,
      body: {"email": email, "password": password},
    );

    return AuthResponseModel.fromJson(res, fallbackEmail: email);
  }

  Future<bool> signup(String name, String email, String password) async {
    await api.post(
      ApiEndpoints.signup,
      body: {"name": name, "email": email, "password": password},
    );
    return true;
  }
}
