import 'package:flutter/material.dart';
import 'app.dart';
export 'app.dart';
import 'core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const PathauNowApp());
}
