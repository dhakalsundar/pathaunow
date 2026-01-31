import 'package:flutter/material.dart';

class AppConstants {
  // Parcel Statuses
  static const String statusPendingPickup = 'PENDING_PICKUP';
  static const String statusPickedUp = 'PICKED_UP';
  static const String statusInTransit = 'IN_TRANSIT';
  static const String statusOutForDelivery = 'OUT_FOR_DELIVERY';
  static const String statusDelivered = 'DELIVERED';
  static const String statusFailedDelivery = 'FAILED_DELIVERY';
  static const String statusCancelled = 'CANCELLED';
  static const String statusReturned = 'RETURNED';

  // Payment Status
  static const String paymentPending = 'PENDING';
  static const String paymentPaid = 'PAID';
  static const String paymentFailed = 'FAILED';

  // User Roles
  static const String roleUser = 'USER';
  static const String roleRider = 'RIDER';
  static const String roleAdmin = 'ADMIN';

  // Status Colors
  static const Map<String, Color> statusColors = {
    statusPendingPickup: Color(0xFFFFA726),
    statusPickedUp: Color(0xFF42A5F5),
    statusInTransit: Color(0xFF66BB6A),
    statusOutForDelivery: Color(0xFFAB47BC),
    statusDelivered: Color(0xFF29B6F6),
    statusFailedDelivery: Color(0xFFEF5350),
    statusCancelled: Color(0xFF757575),
    statusReturned: Color(0xFFFF7043),
  };

  // Status Icons
  static const Map<String, IconData> statusIcons = {
    statusPendingPickup: Icons.pending,
    statusPickedUp: Icons.local_shipping,
    statusInTransit: Icons.directions,
    statusOutForDelivery: Icons.near_me,
    statusDelivered: Icons.done_all,
    statusFailedDelivery: Icons.error,
    statusCancelled: Icons.cancel,
    statusReturned: Icons.replay,
  };

  // Messages
  static const String errorNetworkMessage =
      'Network error. Please check your connection.';
  static const String errorServerMessage = 'Server error. Please try again.';
  static const String errorNotFoundMessage = 'Resource not found.';
  static const String errorUnauthorizedMessage =
      'You are not authorized to perform this action.';
}
