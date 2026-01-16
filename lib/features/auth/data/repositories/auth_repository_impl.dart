import 'package:flutter/foundation.dart';
import 'package:pathau_now/core/api/api_client.dart';
import 'package:pathau_now/core/api/api_endpoints.dart';
import 'package:pathau_now/core/services/hive_auth_service.dart';
import 'package:pathau_now/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:pathau_now/features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';
import 'package:pathau_now/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  late final AuthRemoteDatasource _remote;
  late final AuthLocalDatasource _local;

  AuthRepositoryImpl() {
    final api = ApiClient(baseUrl: ApiEndpoints.baseUrl);
    _remote = AuthRemoteDatasource(api: api);

    final hive = HiveAuthService();
    _local = AuthLocalDatasource(service: hive);
  }

  @override
  Future<bool> signUp(UserEntity user) async {
    return _remote.signup(user.name, user.email, user.password);
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    final res = await _remote.login(email, password);
    debugPrint(' Raw response user: ${res.user}');
    debugPrint('Name: ${res.user?.name}');
    debugPrint('Email: ${res.user?.email}');
    debugPrint('Password: ${res.user?.password}');
    await _local.setCurrentUser(
      name: res.user!.name,
      email: res.user!.email,
      password: res.user!.password,
    );

    return res.user;
  }

  @override
  Future<void> setCurrentUser(UserEntity user) async {
    await _local.setCurrentUser(
      name: user.name,
      email: user.email,
      password: user.password,
    );
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final u = _local.getCurrentUser();
    if (u == null) return null;
    return UserEntity(name: u.name, email: u.email, password: u.password);
  }

  @override
  Future<void> logout() async {
    await _local.logout();
  }
}
