import 'package:flutter/material.dart';
import 'package:pathau_now/core/services/hive/hive_service.dart';

class LocaleService extends ChangeNotifier {
  Locale _locale;

  LocaleService._(this._locale);

  factory LocaleService() {
    final code = HiveService.sessionBox().get('preferred_language');
    final locale = (code is String && code.isNotEmpty)
        ? Locale(code)
        : const Locale('en');
    return LocaleService._(locale);
  }

  Locale get locale => _locale;

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    try {
      await HiveService.sessionBox().put('preferred_language', code);
    } catch (_) {}
    notifyListeners();
  }
}
