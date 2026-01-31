import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathau_now/features/home/presentation/pages/home_page.dart';
import 'package:pathau_now/features/dashboard/models/order_info.dart';

void main() {
  group('HomePage Widget Tests', () {
    late List<OrderInfo> mockOrders;

    setUp(() {
      mockOrders = [
        OrderInfo(
          "PN-2007",
          "Delivered",
          "Kalanki → Lalitpur",
          "NPR 180",
          "Today, 11:35 AM",
        ),
        OrderInfo(
          "PN-1001",
          "In Transit",
          "Koteshwor → Baneshwor",
          "NPR 120",
          "ETA 5:30 PM",
        ),
        OrderInfo(
          "PN-8888",
          "Pending Pickup",
          "Thimi → Chabahil",
          "NPR 150",
          "Pickup today",
        ),
      ];
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: HomePage(
          primaryColor: const Color(0xFFF57C00),
          recentOrders: mockOrders,
          onTrackParcel: () {},
          onOrderTap: (_) {},
        ),
      );
    }

    testWidgets('HomePage renders header card', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Fast courier & parcel tracking'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);
    });

    testWidgets('HomePage displays quick action buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Track Parcel'), findsOneWidget);
      expect(find.text('Create Order'), findsOneWidget);
      expect(find.text('Rider Request'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Live Map'), findsOneWidget);
    });

    testWidgets('HomePage shows recent activity section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Recent activity'), findsOneWidget);
    });

    testWidgets('HomePage displays order cards for recent orders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Should show first 3 orders
      expect(find.text('PN-2007'), findsWidgets);
      expect(find.text('PN-1001'), findsWidgets);
      expect(find.text('PN-8888'), findsWidgets);
    });

    testWidgets('HomePage displays pro tip card', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Pro tip'), findsOneWidget);
      expect(
        find.text(
          'Save frequent tracking IDs for faster access (feature idea).',
        ),
        findsOneWidget,
      );
    });

    testWidgets('HomePage Track Parcel button triggers callback', (
      WidgetTester tester,
    ) async {
      bool trackParcelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            primaryColor: const Color(0xFFF57C00),
            recentOrders: mockOrders,
            onTrackParcel: () => trackParcelCalled = true,
            onOrderTap: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Track Parcel'));
      await tester.pumpAndSettle();

      expect(trackParcelCalled, isTrue);
    });

    testWidgets('HomePage displays mini chips in header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Secure'), findsOneWidget);
      expect(find.text('Fast'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
    });

    testWidgets('HomePage is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('HomePage with empty orders still shows header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            primaryColor: const Color(0xFFF57C00),
            recentOrders: [],
            onTrackParcel: () {},
            onOrderTap: (_) {},
          ),
        ),
      );

      expect(find.text('Fast courier & parcel tracking'), findsOneWidget);
      expect(find.text('Track Parcel'), findsOneWidget);
    });

    testWidgets('HomePage order tap triggers callback', (
      WidgetTester tester,
    ) async {
      String? tappedOrderId;

      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(
            primaryColor: const Color(0xFFF57C00),
            recentOrders: mockOrders,
            onTrackParcel: () {},
            onOrderTap: (id) => tappedOrderId = id,
          ),
        ),
      );

      // Tap on first order card if visible
      final orderCard = find.text('PN-2007').first;
      await tester.tap(orderCard);
      await tester.pumpAndSettle();

      expect(tappedOrderId, equals('PN-2007'));
    });
  });
}
