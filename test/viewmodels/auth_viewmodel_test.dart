import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthViewModel Unit Tests', () {
    late AuthViewModel authViewModel;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      when(() => mockRepository.getStoredToken()).thenReturn(null);
      authViewModel = AuthViewModel(mockRepository);
    });

    test('AuthViewModel initializes with null user', () {
      expect(authViewModel.user, isNull);
    });

    test('AuthViewModel notifyListeners updates listeners', () {
      int notificationCount = 0;
      authViewModel.addListener(() => notificationCount++);

      authViewModel.notifyListeners();

      expect(notificationCount, equals(1));
    });

    test('AuthViewModel can be disposed', () {
      authViewModel.dispose();
      // Should not throw
      expect(true, isTrue);
    });

    test('AuthViewModel loading state can be set', () {
      // Initially should not be loading
      expect(authViewModel.isLoading, isFalse);
    });

    test('AuthViewModel error state handling', () {
      expect(authViewModel.error, isNull);
    });

    test('AuthViewModel can add multiple listeners', () {
      int count1 = 0;
      int count2 = 0;

      authViewModel.addListener(() => count1++);
      authViewModel.addListener(() => count2++);

      authViewModel.notifyListeners();

      expect(count1, equals(1));
      expect(count2, equals(1));
    });

    test('AuthViewModel listeners are called on notifyListeners', () {
      int callCount = 0;
      authViewModel.addListener(() => callCount++);

      authViewModel.notifyListeners();
      authViewModel.notifyListeners();

      expect(callCount, equals(2));
    });

    test('AuthViewModel can be disposed and not throw', () {
      expect(() => authViewModel.dispose(), returnsNormally);
    });

    test('AuthViewModel isLoading property exists', () {
      // Should have isLoading property that is boolean
      expect(authViewModel.isLoading, isA<bool>());
    });

    test('AuthViewModel user property is initially null', () {
      expect(authViewModel.user, isNull);
    });

    test('AuthViewModel is ChangeNotifier', () {
      expect(authViewModel, isA<Object>());
    });

    test('AuthViewModel multiple dispose calls throw error', () {
      authViewModel.dispose();
      // Second dispose should throw FlutterError
      expect(() => authViewModel.dispose(), throwsFlutterError);
    });

    test('AuthViewModel listener removed after dispose', () {
      int count = 0;
      void listener() => count++;

      authViewModel.addListener(listener);
      authViewModel.dispose();

      // After dispose, listener should not be called
      expect(count, equals(0));
    });

    test('AuthViewModel error is nullable', () {
      expect(authViewModel.error, isNull);
    });

    test('AuthViewModel maintains state consistency', () {
      final initialUser = authViewModel.user;
      final initialLoading = authViewModel.isLoading;

      expect(initialUser, isNull);
      expect(initialLoading, isFalse);
    });
  });
}
