import 'package:pathau_now/core/network/api_client.dart';
import 'package:pathau_now/data/models/tracking_model.dart';

abstract class ITrackingRemoteDataSource {
  Future<TrackingModel> getTrackingByParcelId(String parcelId);
  Future<List<TrackingModel>> getTrackingHistory(String parcelId, int limit);
  Future<TrackingModel> updateTrackingLocation(
    String trackingId,
    double latitude,
    double longitude, {
    String? address,
  });
}

class TrackingRemoteDataSource implements ITrackingRemoteDataSource {
  final ApiClient apiClient;

  TrackingRemoteDataSource({required this.apiClient});

  @override
  Future<TrackingModel> getTrackingByParcelId(String parcelId) async {
    final response = await apiClient.get('/tracking/parcel/$parcelId');
    return TrackingModel.fromJson(response);
  }

  @override
  Future<List<TrackingModel>> getTrackingHistory(
    String parcelId,
    int limit,
  ) async {
    final response = await apiClient.get(
      '/tracking/history/$parcelId?limit=$limit',
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((t) => TrackingModel.fromJson(t)).toList();
  }

  @override
  Future<TrackingModel> updateTrackingLocation(
    String trackingId,
    double latitude,
    double longitude, {
    String? address,
  }) async {
    final response = await apiClient.put(
      '/tracking/$trackingId/location',
      body: {'latitude': latitude, 'longitude': longitude, 'address': address},
    );
    return TrackingModel.fromJson(response);
  }
}
