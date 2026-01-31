import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/tracking/data/datasources/parcel_remote_datasource.dart';

abstract class ParcelRepository {
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

class ParcelRepositoryImpl implements ParcelRepository {
  final ParcelRemoteDataSource _remoteDataSource;

  ParcelRepositoryImpl(this._remoteDataSource);

  @override
  Future<ParcelEntity> getParcelByTracking(String trackingId) async {
    try {
      return await _remoteDataSource.getParcelByTracking(trackingId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ParcelEntity>> getUserParcels({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _remoteDataSource.getUserParcels(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParcelEntity> createParcel({
    required Map<String, dynamic> parcelData,
  }) async {
    try {
      return await _remoteDataSource.createParcel(parcelData: parcelData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParcelEntity> updateParcelStatus({
    required String parcelId,
    required String status,
    String? location,
    String? description,
  }) async {
    try {
      return await _remoteDataSource.updateParcelStatus(
        parcelId: parcelId,
        status: status,
        location: location,
        description: description,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelParcel(String parcelId) async {
    try {
      await _remoteDataSource.cancelParcel(parcelId);
    } catch (e) {
      rethrow;
    }
  }
}
