import 'package:pathau_now/domain/entities/parcel_entity.dart';

class ParcelModel extends ParcelEntity {
  const ParcelModel({
    required super.id,
    required super.trackingId,
    required super.status,
    required super.sender,
    required super.receiver,
    required super.weight,
    super.dimensions,
    required super.price,
    required super.paymentStatus,
    super.pickupLocation,
    super.deliveryLocation,
    super.currentLocation,
    super.estimatedDelivery,
    super.actualDelivery,
    super.assignedRiderId,
    super.riderName,
    super.statusHistory,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    return ParcelModel(
      id: json['_id'] ?? json['id'] ?? '',
      trackingId: json['trackingId'] ?? '',
      status: json['status'] ?? 'PENDING_PICKUP',
      sender: ParcelSenderModel.fromJson(json['sender'] ?? {}),
      receiver: ParcelReceiverModel.fromJson(json['receiver'] ?? {}),
      weight: (json['weight'] ?? 0).toDouble(),
      dimensions: json['dimensions'],
      price: (json['price'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      pickupLocation: json['sender'] != null
          ? Location(
              latitude: (json['sender']['coordinates']?['latitude'] ?? 0)
                  .toDouble(),
              longitude: (json['sender']['coordinates']?['longitude'] ?? 0)
                  .toDouble(),
              address: json['sender']['address'],
            )
          : null,
      deliveryLocation: json['receiver'] != null
          ? Location(
              latitude: (json['receiver']['coordinates']?['latitude'] ?? 0)
                  .toDouble(),
              longitude: (json['receiver']['coordinates']?['longitude'] ?? 0)
                  .toDouble(),
              address: json['receiver']['address'],
            )
          : null,
      currentLocation: null,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'])
          : null,
      assignedRiderId: json['riderId'],
      riderName: json['riderName'],
      statusHistory: json['statusHistory'] != null
          ? List<StatusHistory>.from(
              (json['statusHistory'] as List).map(
                (x) => StatusHistory(
                  status: x['status'] ?? '',
                  timestamp: DateTime.parse(
                    x['timestamp'] ?? DateTime.now().toIso8601String(),
                  ),
                  notes: x['notes'],
                  location: x['location'] != null
                      ? Location(
                          latitude: (x['location']['latitude'] ?? 0).toDouble(),
                          longitude: (x['location']['longitude'] ?? 0)
                              .toDouble(),
                          address: x['location']['address'],
                        )
                      : null,
                ),
              ),
            )
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'trackingId': trackingId,
    'status': status,
    'sender': (sender as ParcelSenderModel).toJson(),
    'receiver': (receiver as ParcelReceiverModel).toJson(),
    'weight': weight,
    'dimensions': dimensions,
    'price': price,
    'paymentStatus': paymentStatus,
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'actualDelivery': actualDelivery?.toIso8601String(),
    'riderId': assignedRiderId,
    'riderName': riderName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class ParcelSenderModel extends ParcelSender {
  const ParcelSenderModel({
    required super.name,
    super.email,
    required super.phone,
    required super.address,
    required super.city,
    super.coordinates,
  });

  factory ParcelSenderModel.fromJson(Map<String, dynamic> json) {
    return ParcelSenderModel(
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      coordinates: json['coordinates'] != null
          ? Location(
              latitude: (json['coordinates']['latitude'] ?? 0).toDouble(),
              longitude: (json['coordinates']['longitude'] ?? 0).toDouble(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'coordinates': coordinates != null
        ? {
            'latitude': coordinates!.latitude,
            'longitude': coordinates!.longitude,
          }
        : null,
  };
}

class ParcelReceiverModel extends ParcelReceiver {
  const ParcelReceiverModel({
    required super.name,
    super.email,
    required super.phone,
    required super.address,
    required super.city,
    super.coordinates,
  });

  factory ParcelReceiverModel.fromJson(Map<String, dynamic> json) {
    return ParcelReceiverModel(
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      coordinates: json['coordinates'] != null
          ? Location(
              latitude: (json['coordinates']['latitude'] ?? 0).toDouble(),
              longitude: (json['coordinates']['longitude'] ?? 0).toDouble(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'coordinates': coordinates != null
        ? {
            'latitude': coordinates!.latitude,
            'longitude': coordinates!.longitude,
          }
        : null,
  };
}
