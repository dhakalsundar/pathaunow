import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user.dart';
import '../../models/user.g.dart';
import '../../models/parcel.dart';
import '../../models/parcel.g.dart';

class HiveService {
  static const String usersBoxName = 'usersBox';
  static const String sessionBoxName = 'sessionBox';
  static const String parcelsBoxName = 'parcelsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ParcelAdapter());
    }
    await Hive.openBox<User>(usersBoxName);
    await Hive.openBox<String>(sessionBoxName);
    await Hive.openBox<Parcel>(parcelsBoxName);
  }

  static Box<User> usersBox() => Hive.box<User>(usersBoxName);
  static Box<String> sessionBox() => Hive.box<String>(sessionBoxName);
  static Box<Parcel> parcelsBox() => Hive.box<Parcel>(parcelsBoxName);

  static Future<void> saveToken(String token) async {
    final box = sessionBox();
    await box.put('auth_token', token);
  }

  static String? getToken() {
    try {
      final box = sessionBox();
      return box.get('auth_token');
    } catch (e) {
      return null;
    }
  }
}
