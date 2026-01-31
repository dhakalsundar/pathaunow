import 'package:pathau_now/domain/entities/parcel_entity.dart';

class TrackingModel extends TrackingEntity {
  const TrackingModel({
    required super.id,
    required super.parcelId,
    required super.trackingId,
    required super.latitude,
    required super.longitude,
    super.address,
    required super.status,
    super.speed,
    super.accuracy,
    required super.timestamp,
    super.riderId,
    super.riderName,
    super.riderPhone,
    super.riderRating,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      id: json['_id'] ?? json['id'] ?? '',
      parcelId: json['parcelId'] ?? '',
      trackingId: json['trackingId'] ?? '',
      latitude: (json['location']?['latitude'] ?? json['latitude'] ?? 0)
          .toDouble(),
      longitude: (json['location']?['longitude'] ?? json['longitude'] ?? 0)
          .toDouble(),
      address: json['location']?['address'] ?? json['address'],
      status: json['status'] ?? 'IN_TRANSIT',
      speed: json['speed']?.toDouble(),
      accuracy: (json['location']?['accuracy'] ?? json['accuracy'])?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      riderId: json['riderId'],
      riderName: json['riderInfo']?['name'],
      riderPhone: json['riderInfo']?['phone'],
      riderRating: (json['riderInfo']?['rating'])?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'parcelId': parcelId,
    'trackingId': trackingId,
    'location': {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
    },
    'status': status,
    'speed': speed,
    'timestamp': timestamp.toIso8601String(),
    'riderId': riderId,
    'riderInfo': {
      'name': riderName,
      'phone': riderPhone,
      'rating': riderRating,
    },
  };
}
