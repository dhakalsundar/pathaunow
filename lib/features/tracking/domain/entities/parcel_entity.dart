class ParcelEntity {
  final String id;
  final String trackingId;
  final SenderEntity sender;
  final ReceiverEntity receiver;
  final String status;
  final double weight;
  final DimensionsEntity? dimensions;
  final double price;
  final String paymentStatus;
  final String contents;
  final String? specialInstructions;
  final List<TrackingTimelineEntity> timeline;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParcelEntity({
    required this.id,
    required this.trackingId,
    required this.sender,
    required this.receiver,
    required this.status,
    required this.weight,
    this.dimensions,
    required this.price,
    required this.paymentStatus,
    required this.contents,
    this.specialInstructions,
    required this.timeline,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.createdAt,
    required this.updatedAt,
  });

  ParcelEntity copyWith({
    String? id,
    String? trackingId,
    SenderEntity? sender,
    ReceiverEntity? receiver,
    String? status,
    double? weight,
    DimensionsEntity? dimensions,
    double? price,
    String? paymentStatus,
    String? contents,
    String? specialInstructions,
    List<TrackingTimelineEntity>? timeline,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParcelEntity(
      id: id ?? this.id,
      trackingId: trackingId ?? this.trackingId,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      status: status ?? this.status,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      price: price ?? this.price,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      contents: contents ?? this.contents,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      timeline: timeline ?? this.timeline,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SenderEntity {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;

  SenderEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
  });
}

class ReceiverEntity {
  final String name;
  final String? email;
  final String phone;
  final String address;
  final String city;

  ReceiverEntity({
    required this.name,
    this.email,
    required this.phone,
    required this.address,
    required this.city,
  });
}

class DimensionsEntity {
  final double length;
  final double width;
  final double height;

  DimensionsEntity({
    required this.length,
    required this.width,
    required this.height,
  });
}

class TrackingTimelineEntity {
  final String status;
  final DateTime timestamp;
  final String? location;
  final String? description;

  TrackingTimelineEntity({
    required this.status,
    required this.timestamp,
    this.location,
    this.description,
  });
}
