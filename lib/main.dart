import 'package:flutter/material.dart';
import 'app.dart';
export 'app.dart';
import 'core/services/hive_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveAuthService.init();
  runApp(const PathauNowApp());
}
