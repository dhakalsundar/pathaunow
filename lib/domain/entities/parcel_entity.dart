library;

import 'dart:math';

class ParcelEntity {
  final String id;
  final String trackingId;
  final String status;
  final ParcelSender sender;
  final ParcelReceiver receiver;
  final double weight;
  final Map<String, dynamic>? dimensions;
  final double price;
  final String paymentStatus;
  final Location? pickupLocation;
  final Location? deliveryLocation;
  final Location? currentLocation;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final String? assignedRiderId;
  final String? riderName;
  final List<StatusHistory>? statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParcelEntity({
    required this.id,
    required this.trackingId,
    required this.status,
    required this.sender,
    required this.receiver,
    required this.weight,
    this.dimensions,
    required this.price,
    required this.paymentStatus,
    this.pickupLocation,
    this.deliveryLocation,
    this.currentLocation,
    this.estimatedDelivery,
    this.actualDelivery,
    this.assignedRiderId,
    this.riderName,
    this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDelivered => status == 'DELIVERED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isPending => status == 'PENDING_PICKUP';
  bool get isInTransit =>
      ['PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY'].contains(status);

  ParcelEntity copyWith({
    String? id,
    String? trackingId,
    String? status,
    ParcelSender? sender,
    ParcelReceiver? receiver,
    double? weight,
    Map<String, dynamic>? dimensions,
    double? price,
    String? paymentStatus,
    Location? pickupLocation,
    Location? deliveryLocation,
    Location? currentLocation,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    String? assignedRiderId,
    String? riderName,
    List<StatusHistory>? statusHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParcelEntity(
      id: id ?? this.id,
      trackingId: trackingId ?? this.trackingId,
      status: status ?? this.status,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      price: price ?? this.price,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      assignedRiderId: assignedRiderId ?? this.assignedRiderId,
      riderName: riderName ?? this.riderName,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ParcelEntity(trackingId: $trackingId, status: $status)';
}

class ParcelSender {
  final String name;
  final String? email;
  final String phone;
  final String address;
  final String city;
  final Location? coordinates;

  const ParcelSender({
    required this.name,
    this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.coordinates,
  });
}

class ParcelReceiver {
  final String name;
  final String? email;
  final String phone;
  final String address;
  final String city;
  final Location? coordinates;

  const ParcelReceiver({
    required this.name,
    this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.coordinates,
  });
}

class Location {
  final double latitude;
  final double longitude;
  final String? address;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  double distanceTo(Location other) {
    const double earthRadius = 6371; // km
    final double lat1 = latitude * (3.141592653589793 / 180);
    final double lat2 = other.latitude * (3.141592653589793 / 180);
    final double dLat = (other.latitude - latitude) * (3.141592653589793 / 180);
    final double dLng =
        (other.longitude - longitude) * (3.141592653589793 / 180);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  String toString() => 'Location($latitude, $longitude)';
}

class StatusHistory {
  final String status;
  final DateTime timestamp;
  final String? notes;
  final Location? location;

  const StatusHistory({
    required this.status,
    required this.timestamp,
    this.notes,
    this.location,
  });
}

class TrackingEntity {
  final String id;
  final String parcelId;
  final String trackingId;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;
  final double? speed;
  final double? accuracy;
  final DateTime timestamp;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final double? riderRating;

  const TrackingEntity({
    required this.id,
    required this.parcelId,
    required this.trackingId,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    this.speed,
    this.accuracy,
    required this.timestamp,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.riderRating,
  });

  bool isRecentUpdate({Duration duration = const Duration(minutes: 5)}) {
    return DateTime.now().difference(timestamp) < duration;
  }
}
