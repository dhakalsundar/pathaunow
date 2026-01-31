import 'package:pathau_now/core/network/api_client.dart';
import 'package:pathau_now/data/models/parcel_model.dart';

abstract class IParcelRemoteDataSource {
  Future<ParcelModel> createParcel(Map<String, dynamic> parcelData);
  Future<ParcelModel> getParcelByTrackingId(String trackingId);
  Future<List<ParcelModel>> getUserParcels(String userId, int page, int limit);
  Future<ParcelModel> updateParcelStatus(
    String parcelId,
    String status, {
    String? notes,
  });
  Future<List<ParcelModel>> getParcelsByStatus(
    String status,
    int page,
    int limit,
  );
}

class ParcelRemoteDataSource implements IParcelRemoteDataSource {
  final ApiClient apiClient;

  ParcelRemoteDataSource({required this.apiClient});

  @override
  Future<ParcelModel> createParcel(Map<String, dynamic> parcelData) async {
    final response = await apiClient.post('/parcels/create', body: parcelData);
    return ParcelModel.fromJson(response);
  }

  @override
  Future<ParcelModel> getParcelByTrackingId(String trackingId) async {
    final response = await apiClient.get('/parcels/track/$trackingId');
    return ParcelModel.fromJson(response);
  }

  @override
  Future<List<ParcelModel>> getUserParcels(
    String userId,
    int page,
    int limit,
  ) async {
    final response = await apiClient.get(
      '/parcels/my-parcels?page=$page&limit=$limit',
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((p) => ParcelModel.fromJson(p)).toList();
  }

  @override
  Future<ParcelModel> updateParcelStatus(
    String parcelId,
    String status, {
    String? notes,
  }) async {
    final response = await apiClient.put(
      '/parcels/$parcelId/status',
      body: {'status': status, 'notes': notes},
    );
    return ParcelModel.fromJson(response);
  }

  @override
  Future<List<ParcelModel>> getParcelsByStatus(
    String status,
    int page,
    int limit,
  ) async {
    final response = await apiClient.get(
      '/parcels?status=$status&page=$page&limit=$limit',
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((p) => ParcelModel.fromJson(p)).toList();
  }
}
