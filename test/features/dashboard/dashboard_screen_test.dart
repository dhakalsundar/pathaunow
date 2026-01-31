import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathau_now/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'package:pathau_now/core/services/locale_service.dart';
import 'package:pathau_now/core/localization/app_localizations.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockParcelViewModel extends Mock implements ParcelViewModel {}

class MockLocaleService extends Mock implements LocaleService {}

void main() {
  group('DashboardScreen Widget Tests', () {
    late MockAuthViewModel mockAuthViewModel;
    late MockParcelViewModel mockParcelViewModel;
    late MockLocaleService mockLocaleService;

    setUp(() {
      mockAuthViewModel = MockAuthViewModel();
      mockParcelViewModel = MockParcelViewModel();
      mockLocaleService = MockLocaleService();

      when(
        () => mockAuthViewModel.getCurrentUser(),
      ).thenAnswer((_) async => null);
      when(
        () => mockParcelViewModel.getUserParcels(),
      ).thenAnswer((_) async => {});
      when(() => mockParcelViewModel.userParcels).thenReturn([]);
      when(() => mockAuthViewModel.user).thenReturn(null);
      when(() => mockAuthViewModel.isLoggedIn).thenReturn(false);
      when(() => mockLocaleService.locale).thenReturn(const Locale('en'));
    });

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthViewModel),
          ChangeNotifierProvider<ParcelViewModel>.value(
            value: mockParcelViewModel,
          ),
          ChangeNotifierProvider<LocaleService>.value(value: mockLocaleService),
        ],
        child: MaterialApp(
          localizationsDelegates: const [AppLocalizationsDelegate()],
          supportedLocales: const [Locale('en')],
          home: const DashboardScreen(),
        ),
      );
    }

    testWidgets('DashboardScreen renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('DashboardScreen displays app bar with title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PathauNow'), findsOneWidget);
    });
  });
}
