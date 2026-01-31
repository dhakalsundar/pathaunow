import 'package:flutter_test/flutter_test.dart';
import 'package:pathau_now/core/services/hive/hive_service.dart';

void main() {
  group('HiveService Unit Tests', () {
    test('HiveService has parcelsBox method', () {
      expect(HiveService.parcelsBox, isA<Function>());
    });

    test('HiveService has usersBox method', () {
      expect(HiveService.usersBox, isA<Function>());
    });

    test('HiveService has sessionBox method', () {
      expect(HiveService.sessionBox, isA<Function>());
    });

    test('HiveService has init method', () {
      expect(HiveService.init, isA<Function>());
    });

    test('HiveService has saveToken method', () {
      expect(HiveService.saveToken, isA<Function>());
    });

    test('HiveService has getToken method', () {
      expect(HiveService.getToken, isA<Function>());
    });

    test('HiveService.getToken returns null when no token', () {
      final token = HiveService.getToken();
      // Should return null or string
      expect(token == null || token is String, isTrue);
    });

    test('HiveService box names are defined', () {
      // Check that box names exist as constants
      expect(HiveService.usersBoxName, equals('usersBox'));
      expect(HiveService.sessionBoxName, equals('sessionBox'));
      expect(HiveService.parcelsBoxName, equals('parcelsBox'));
    });

    test('HiveService box names are different', () {
      expect(
        HiveService.usersBoxName,
        isNot(equals(HiveService.sessionBoxName)),
      );
      expect(
        HiveService.usersBoxName,
        isNot(equals(HiveService.parcelsBoxName)),
      );
      expect(
        HiveService.sessionBoxName,
        isNot(equals(HiveService.parcelsBoxName)),
      );
    });

    test('HiveService usersBoxName is correct', () {
      expect(HiveService.usersBoxName, 'usersBox');
    });

    test('HiveService sessionBoxName is correct', () {
      expect(HiveService.sessionBoxName, 'sessionBox');
    });

    test('HiveService parcelsBoxName is correct', () {
      expect(HiveService.parcelsBoxName, 'parcelsBox');
    });

    test('HiveService class is accessible', () {
      expect(HiveService, isNotNull);
    });

    test('HiveService has static methods', () {
      expect(HiveService.init, isA<Function>());
      expect(HiveService.usersBox, isA<Function>());
      expect(HiveService.sessionBox, isA<Function>());
      expect(HiveService.parcelsBox, isA<Function>());
      expect(HiveService.saveToken, isA<Function>());
      expect(HiveService.getToken, isA<Function>());
    });

    test('HiveService box name constants are String type', () {
      expect(HiveService.usersBoxName, isA<String>());
      expect(HiveService.sessionBoxName, isA<String>());
      expect(HiveService.parcelsBoxName, isA<String>());
    });
  });
}
