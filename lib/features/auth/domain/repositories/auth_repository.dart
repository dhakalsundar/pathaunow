import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> signUp(UserEntity user);

  Future<UserEntity?> login(String email, String password);

  Future<UserEntity?> getCurrentUser();

  Future<void> setCurrentUser(UserEntity user);

  Future<void> logout();
}
