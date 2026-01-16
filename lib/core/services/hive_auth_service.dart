import 'package:hive/hive.dart';
import '../models/user.dart';
import 'hive/hive_service.dart';

class HiveAuthService {
  Box<User> get _box => HiveService.usersBox();
  Future<bool> signUp(User user) async {
    final box = _box;
    if (box.containsKey(user.email)) {
      return false;
    }
    await box.put(user.email, user);
    return true;
  }

  User? login(String email, String password) {
    final box = _box;
    final User? user = box.get(email);
    if (user == null) return null;
    if (user.password == password) return user;
    return null;
  }

  Future<void> setCurrentUser(User user) async {
    final sbox = HiveService.sessionBox();
    await sbox.put('currentUserEmail', user.email);
  }

  User? getCurrentUser() {
    final sbox = HiveService.sessionBox();
    final email = sbox.get('currentUserEmail');
    if (email == null) return null;
    return _box.get(email);
  }

  Future<void> logout() async {
    final sbox = HiveService.sessionBox();
    await sbox.delete('currentUserEmail');
  }
}
