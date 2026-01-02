import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';
import '../../models/user.g.dart';

class HiveService {
  static const String usersBoxName = 'usersBox';
  static const String sessionBoxName = 'sessionBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      // UserAdapter is provided manually in user.g.dart
      Hive.registerAdapter(UserAdapter());
    }
    await Hive.openBox<User>(usersBoxName);
    await Hive.openBox<String>(sessionBoxName);
  }

  static Box<User> usersBox() => Hive.box<User>(usersBoxName);
  static Box<String> sessionBox() => Hive.box<String>(sessionBoxName);
}
