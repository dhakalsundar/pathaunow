import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathau_now/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:pathau_now/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:pathau_now/features/tracking/presentation/viewmodels/parcel_viewmodel.dart';
import 'package:pathau_now/core/services/locale_service.dart';

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

      // Setup mock behaviors
      when(
        () => mockAuthViewModel.getCurrentUser(),
      ).thenAnswer((_) async => null);
      when(
        () => mockParcelViewModel.getUserParcels(),
      ).thenAnswer((_) async => {});
      when(() => mockParcelViewModel.userParcels).thenReturn([]);
      when(() => mockAuthViewModel.user).thenReturn(null);
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
        child: const MaterialApp(home: DashboardScreen()),
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

    testWidgets('DashboardScreen has bottom navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('DashboardScreen navigation bar has 4 items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Track'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('DashboardScreen can switch to Track tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Track'));
      await tester.pumpAndSettle();

      // Track page should be displayed
      expect(find.byIcon(Icons.qr_code_2_rounded), findsWidgets);
    });

    testWidgets('DashboardScreen can switch to Orders tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('DashboardScreen can switch to Profile tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('DashboardScreen has search button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('DashboardScreen has notification button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('DashboardScreen displays brand logo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });
  });
}
