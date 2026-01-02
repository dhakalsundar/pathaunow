import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SetCurrentUserUseCase {
  final AuthRepository repository;

  SetCurrentUserUseCase(this.repository);

  Future<void> execute(UserEntity user) async {
    await repository.setCurrentUser(user);
  }
}
