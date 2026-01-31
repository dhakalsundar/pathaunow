import 'package:flutter/material.dart';
import 'app.dart';
export 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully');
    print(' API_BASE_URL: ${dotenv.env['API_BASE_URL'] ?? "not set"}');
  } catch (e) {
    print(' .env file not found, using platform-specific defaults');
  }

  runApp(const PathauNowApp());
}
