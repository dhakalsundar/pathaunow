import 'package:pathau_now/core/services/http_service.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';

abstract class ParcelRemoteDataSource {
  Future<ParcelEntity> getParcelByTracking(String trackingId);
  Future<List<ParcelEntity>> getUserParcels({int page = 1, int limit = 10});
  Future<ParcelEntity> createParcel({required Map<String, dynamic> parcelData});
  Future<ParcelEntity> updateParcelStatus({
    required String parcelId,
    required String status,
    String? location,
    String? description,
  });
  Future<void> cancelParcel(String parcelId);
}

class ParcelRemoteDataSourceImpl implements ParcelRemoteDataSource {
  @override
  Future<ParcelEntity> getParcelByTracking(String trackingId) async {
    final response = await HttpService.get('/parcels/track/$trackingId');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch parcel');
    }
    return _mapToParcelEntity(response['parcel']);
  }

  @override
  Future<List<ParcelEntity>> getUserParcels({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await HttpService.get('/parcels?page=$page&limit=$limit');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch parcels');
    }
    final List<dynamic> parcels = response['parcels'] ?? [];
    return parcels.map((p) => _mapToParcelEntity(p)).toList();
  }

  @override
  Future<ParcelEntity> createParcel({
    required Map<String, dynamic> parcelData,
  }) async {
    final response = await HttpService.post('/parcels', body: parcelData);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to create parcel');
    }
    return _mapToParcelEntity(response['parcel']);
  }

  @override
  Future<ParcelEntity> updateParcelStatus({
    required String parcelId,
    required String status,
    String? location,
    String? description,
  }) async {
    final response = await HttpService.put(
      '/parcels/$parcelId/status',
      body: {
        'status': status,
        'location': location,
        'description': description,
      },
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to update status');
    }
    return _mapToParcelEntity(response['parcel']);
  }

  @override
  Future<void> cancelParcel(String parcelId) async {
    final response = await HttpService.put(
      '/parcels/$parcelId/cancel',
      body: {},
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to cancel parcel');
    }
  }

  ParcelEntity _mapToParcelEntity(Map<String, dynamic> json) {
    return ParcelEntity(
      id: json['_id'] ?? '',
      trackingId: json['trackingId'] ?? '',
      sender: SenderEntity(
        name: json['sender']['name'] ?? '',
        email: json['sender']['email'] ?? '',
        phone: json['sender']['phone'] ?? '',
        address: json['sender']['address'] ?? '',
        city: json['sender']['city'] ?? '',
      ),
      receiver: ReceiverEntity(
        name: json['receiver']['name'] ?? '',
        email: json['receiver']['email'],
        phone: json['receiver']['phone'] ?? '',
        address: json['receiver']['address'] ?? '',
        city: json['receiver']['city'] ?? '',
      ),
      status: json['status'] ?? 'Pending Pickup',
      weight: (json['weight'] ?? 0.0).toDouble(),
      dimensions: json['dimensions'] != null
          ? DimensionsEntity(
              length: (json['dimensions']['length'] ?? 0.0).toDouble(),
              width: (json['dimensions']['width'] ?? 0.0).toDouble(),
              height: (json['dimensions']['height'] ?? 0.0).toDouble(),
            )
          : null,
      price: (json['price'] ?? 0.0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      contents: json['contents'] ?? '',
      specialInstructions: json['specialInstructions'],
      timeline: List<TrackingTimelineEntity>.from(
        (json['timeline'] as List?)?.map(
              (x) => TrackingTimelineEntity(
                status: x['status'] ?? '',
                timestamp: DateTime.parse(
                  x['timestamp'] ?? DateTime.now().toString(),
                ),
                location: x['location'],
                description: x['description'],
              ),
            ) ??
            [],
      ),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.parse(json['actualDelivery'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }
}
