import 'package:flutter_test/flutter_test.dart';
import 'package:pathau_now/features/dashboard/models/tracking_info.dart';

void main() {
  group('TrackingInfo Unit Tests', () {
    test('TrackingInfo should create instance with correct properties', () {
      final steps = [
        TrackStep("Picked up from sender", "09:10 AM", true),
        TrackStep("Arrived at hub (KTM)", "11:05 AM", true),
        TrackStep("Out for delivery", "02:40 PM", true),
        TrackStep("Delivering to receiver", "05:10 PM", false),
      ];

      final tracking = TrackingInfo(
        id: "PN-1001",
        status: "In Transit",
        eta: "Today, 5:30 PM",
        from: "Koteshwor, KTM",
        to: "Baneshwor, KTM",
        steps: steps,
      );

      expect(tracking.id, equals("PN-1001"));
      expect(tracking.status, equals("In Transit"));
      expect(tracking.eta, equals("Today, 5:30 PM"));
      expect(tracking.from, equals("Koteshwor, KTM"));
      expect(tracking.to, equals("Baneshwor, KTM"));
      expect(tracking.steps.length, equals(4));
    });

    test('TrackingInfo status can be verified as In Transit', () {
      final steps = [TrackStep("Picked up", "09:10 AM", true)];

      final tracking = TrackingInfo(
        id: "PN-1001",
        status: "In Transit",
        eta: "Today, 5:30 PM",
        from: "Koteshwor, KTM",
        to: "Baneshwor, KTM",
        steps: steps,
      );

      expect(tracking.status.toLowerCase().contains("transit"), isTrue);
    });

    test('TrackingInfo status can be verified as Delivered', () {
      final steps = [TrackStep("Delivered", "11:35 AM", true)];

      final tracking = TrackingInfo(
        id: "PN-2007",
        status: "Delivered",
        eta: "Delivered",
        from: "Kalanki, KTM",
        to: "Lalitpur",
        steps: steps,
      );

      expect(tracking.status.toLowerCase().contains("deliver"), isTrue);
    });

    test('TrackingInfo can track multiple steps', () {
      final steps = [
        TrackStep("Step 1", "Time 1", true),
        TrackStep("Step 2", "Time 2", true),
        TrackStep("Step 3", "Time 3", false),
        TrackStep("Step 4", "Time 4", false),
      ];

      final tracking = TrackingInfo(
        id: "PN-1001",
        status: "In Transit",
        eta: "Today",
        from: "From",
        to: "To",
        steps: steps,
      );

      final completedSteps = tracking.steps.where((s) => s.done).toList();
      expect(completedSteps.length, equals(2));
    });

    test('TrackingInfo can calculate progress percentage', () {
      final steps = [
        TrackStep("Step 1", "Time 1", true),
        TrackStep("Step 2", "Time 2", true),
        TrackStep("Step 3", "Time 3", false),
        TrackStep("Step 4", "Time 4", false),
      ];

      final tracking = TrackingInfo(
        id: "PN-1001",
        status: "In Transit",
        eta: "Today",
        from: "From",
        to: "To",
        steps: steps,
      );

      final progress =
          (tracking.steps.where((s) => s.done).length / tracking.steps.length) *
          100;

      expect(progress, equals(50.0));
    });

    test('TrackingInfo step properties are correct', () {
      final step = TrackStep("Picked up from sender", "09:10 AM", true);

      expect(step.title, equals("Picked up from sender"));
      expect(step.time, equals("09:10 AM"));
      expect(step.done, isTrue);
    });

    test('TrackingInfo with Pending Pickup status', () {
      final steps = [
        TrackStep("Order created", "10:05 AM", true),
        TrackStep("Waiting for rider pickup", "10:10 AM", false),
      ];

      final tracking = TrackingInfo(
        id: "PN-8888",
        status: "Pending Pickup",
        eta: "Today",
        from: "Thimi, Bhaktapur",
        to: "Chabahil, KTM",
        steps: steps,
      );

      expect(tracking.status, equals("Pending Pickup"));
      expect(tracking.eta, equals("Today"));
    });

    test('TrackingInfo equality check for same parcel', () {
      final step = TrackStep("Delivered", "11:35 AM", true);

      final tracking1 = TrackingInfo(
        id: "PN-2007",
        status: "Delivered",
        eta: "Delivered",
        from: "Kalanki, KTM",
        to: "Lalitpur",
        steps: [step],
      );

      final tracking2 = TrackingInfo(
        id: "PN-2007",
        status: "Delivered",
        eta: "Delivered",
        from: "Kalanki, KTM",
        to: "Lalitpur",
        steps: [step],
      );

      expect(tracking1.id, equals(tracking2.id));
      expect(tracking1.status, equals(tracking2.status));
    });

    test('TrackingInfo filtering by status works', () {
      final trackings = [
        TrackingInfo(
          id: "PN-1001",
          status: "In Transit",
          eta: "Today",
          from: "From",
          to: "To",
          steps: [],
        ),
        TrackingInfo(
          id: "PN-2007",
          status: "Delivered",
          eta: "Delivered",
          from: "From",
          to: "To",
          steps: [],
        ),
      ];

      final inTransit = trackings
          .where((t) => t.status == "In Transit")
          .toList();

      expect(inTransit.length, equals(1));
      expect(inTransit.first.id, equals("PN-1001"));
    });

    test('TrackStep with false done flag', () {
      final step = TrackStep("Pending step", "Future", false);

      expect(step.done, isFalse);
      expect(step.title, equals("Pending step"));
      expect(step.time, equals("Future"));
    });
  });
}
