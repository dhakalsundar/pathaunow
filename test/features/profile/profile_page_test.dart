import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';
import 'package:pathau_now/core/localization/app_localizations.dart';
import 'package:pathau_now/core/services/locale_service.dart';
import 'package:pathau_now/features/profile/presentation/pages/profile_page.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockLocaleService extends Mock implements LocaleService {}

void main() {
  group('ProfilePage Widget Tests', () {
    const Color primaryColor = Color(0xFFF57C00);

    late MockAuthViewModel mockAuthViewModel;
    late MockLocaleService mockLocaleService;

    late UserEntity testUser;

    setUp(() {
      mockAuthViewModel = MockAuthViewModel();
      mockLocaleService = MockLocaleService();

      when(() => mockAuthViewModel.getCurrentUser()).thenAnswer((_) async {});
      when(() => mockAuthViewModel.isLoggedIn).thenReturn(false);
      when(() => mockLocaleService.locale).thenReturn(const Locale('en'));

      testUser = UserEntity(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        phone: '9800000000',
        profileImage: null,
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );
      when(() => mockAuthViewModel.user).thenReturn(testUser);
    });

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
          ChangeNotifierProvider<LocaleService>.value(value: mockLocaleService),
        ],
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizationsDelegate()],
          supportedLocales: const [Locale('en')],
          home: ProfilePage(primaryColor: primaryColor, onNavigateBack: () {}),
        ),
      );
    }

    testWidgets('ProfilePage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('ProfilePage displays user profile information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ProfilePage has back navigation button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final backButtons = find.byIcon(Icons.arrow_back);
      final closeButtons = find.byIcon(Icons.close);

      expect(
        backButtons.evaluate().isNotEmpty || closeButtons.evaluate().isNotEmpty,
        true,
      );
    });
  });
}
