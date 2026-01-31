import 'package:flutter/material.dart';
import 'app.dart';
export 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive first
  await HiveService.init();

  // Load environment variables (create a .env file with API_BASE_URL)
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
    print('📡 API_BASE_URL: ${dotenv.env['API_BASE_URL'] ?? "not set"}');
  } catch (e) {
    // .env file not found - this is ok, will use platform defaults
    print('⚠️ .env file not found, using platform-specific defaults');
  }

  runApp(const PathauNowApp());
}
