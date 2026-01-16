import 'package:pathau_now/core/models/user.dart' as data_model;
import 'package:pathau_now/core/services/hive_auth_service.dart';

class AuthLocalDatasource {
  final HiveAuthService service;

  AuthLocalDatasource({required this.service});

  Future<void> setCurrentUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final dm = data_model.User(name: name, email: email, password: password);
    await service.setCurrentUser(dm);
  }

  data_model.User? getCurrentUser() {
    return service.getCurrentUser();
  }

  Future<void> logout() async {
    await service.logout();
  }
}
