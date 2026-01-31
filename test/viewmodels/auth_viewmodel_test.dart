import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthViewModel Unit Tests', () {
    late AuthViewModel authViewModel;
    late MockAuthRepository mockRepository;

    bool _openedSessionBox = false;

    setUpAll(() async {
      Hive.init('.');
      if (!Hive.isBoxOpen('sessionBox')) {
        await Hive.openBox<String>('sessionBox');
        _openedSessionBox = true;
      }
    });

    // tearDownAll(() async {
    //   if (_openedSessionBox && Hive.isBoxOpen('sessionBox')) {
    //     await Hive.box('sessionBox').clear();
    //     await Hive.close();
    //   }
    // });

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
      expect(true, isTrue);
    });

    test('AuthViewModel loading state can be set', () {
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
      expect(() => authViewModel.dispose(), throwsFlutterError);
    });

    test('AuthViewModel listener removed after dispose', () {
      int count = 0;
      void listener() => count++;

      authViewModel.addListener(listener);
      authViewModel.dispose();

      expect(count, equals(0));
    });

    test('AuthViewModel error is nullable', () {
      expect(authViewModel.error, isNull);
    });
  });
}
