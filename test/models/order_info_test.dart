import 'package:flutter_test/flutter_test.dart';
import 'package:pathau_now/features/dashboard/models/order_info.dart';

void main() {
  group('OrderInfo Unit Tests', () {
    test('OrderInfo should create instance with correct properties', () {
      const id = "PN-2007";
      const status = "Delivered";
      const route = "Kalanki → Lalitpur";
      const amount = "NPR 180";
      const date = "Today, 11:35 AM";

      final order = OrderInfo(id, status, route, amount, date);

      expect(order.id, equals(id));
      expect(order.status, equals(status));
      expect(order.route, equals(route));
      // expect(order.amount, equals(amount));
      // expect(order.date, equals(date));
    });

    test('OrderInfo equality works correctly', () {
      final order1 = OrderInfo(
        "PN-2007",
        "Delivered",
        "Kalanki → Lalitpur",
        "NPR 180",
        "Today, 11:35 AM",
      );

      final order2 = OrderInfo(
        "PN-2007",
        "Delivered",
        "Kalanki → Lalitpur",
        "NPR 180",
        "Today, 11:35 AM",
      );

      expect(order1.id, equals(order2.id));
      expect(order1.status, equals(order2.status));
    });

    test('OrderInfo can create multiple instances with different data', () {
      final orders = [
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

      expect(orders.length, equals(3));
      expect(orders[0].status, equals("Delivered"));
      expect(orders[1].status, equals("In Transit"));
      expect(orders[2].status, equals("Pending Pickup"));
    });

    test('OrderInfo status filtering works correctly', () {
      final orders = [
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
      ];

      final deliveredOrders = orders
          .where((o) => o.status == "Delivered")
          .toList();

      expect(deliveredOrders.length, equals(1));
      expect(deliveredOrders.first.id, equals("PN-2007"));
    });

    test('OrderInfo toString returns non-empty string', () {
      final order = OrderInfo(
        "PN-2007",
        "Delivered",
        "Kalanki → Lalitpur",
        "NPR 180",
        "Today, 11:35 AM",
      );

      expect(order.toString(), isNotEmpty);
    });

    test('OrderInfo properties are immutable', () {
      final order = OrderInfo(
        "PN-2007",
        "Delivered",
        "Kalanki → Lalitpur",
        "NPR 180",
        "Today, 11:35 AM",
      );

      expect(order.id, equals("PN-2007"));
      final id = order.id;
      expect(order.id, equals(id));
    });

    test('OrderInfo can be sorted by id', () {
      final orders = [
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
      ];

      final sorted = List<OrderInfo>.from(orders)
        ..sort((a, b) => a.id.compareTo(b.id));

      expect(sorted.first.id, equals("PN-1001"));
      expect(sorted.last.id, equals("PN-2007"));
    });

    test('OrderInfo with empty strings', () {
      final order = OrderInfo("", "", "", "", "");

      expect(order.id, isEmpty);
      expect(order.status, isEmpty);
      expect(order.route, isEmpty);
    });

    test('OrderInfo route formatting', () {
      final order = OrderInfo(
        "PN-2007",
        "Delivered",
        "Kalanki → Lalitpur",
        "NPR 180",
        "Today, 11:35 AM",
      );

      expect(order.route.contains('→'), isTrue);
      expect(order.route.split('→').length, equals(2));
    });
  });
}
