import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/user.g.dart';

class HiveAuthService {
  static const String _boxName = 'usersBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    await Hive.openBox<User>(_boxName);
  }

  Box<User> get _box => Hive.box<User>(_boxName);

  Future<bool> signUp(User user) async {
    final box = _box;
    if (box.containsKey(user.email)) {
      return false; // already exists
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

  Future<void> logout() async {}
}
