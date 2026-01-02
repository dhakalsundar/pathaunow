import 'package:pathau_now/core/models/user.dart' as data_model;
import 'package:pathau_now/core/services/hive_auth_service.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';
import 'package:pathau_now/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final HiveAuthService _service = HiveAuthService();

  @override
  Future<bool> signUp(UserEntity user) async {
    final dm = data_model.User(
      name: user.name,
      email: user.email,
      password: user.password,
    );
    return _service.signUp(dm);
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    final data_model.User? u = _service.login(email, password);
    if (u == null) return null;
    return UserEntity(name: u.name, email: u.email, password: u.password);
  }

  @override
  Future<void> setCurrentUser(UserEntity user) async {
    final dm = data_model.User(
      name: user.name,
      email: user.email,
      password: user.password,
    );
    await _service.setCurrentUser(dm);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final data_model.User? u = _service.getCurrentUser();
    if (u == null) return null;
    return UserEntity(name: u.name, email: u.email, password: u.password);
  }

  @override
  Future<void> logout() async {
    await _service.logout();
  }
}
