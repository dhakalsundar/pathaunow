import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<bool> execute(UserEntity user) async {
    return repository.signUp(user);
  }
}
