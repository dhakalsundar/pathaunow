import 'package:pathau_now/data/datasources/tracking_remote_data_source.dart';
import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/domain/repositories/repository_interfaces.dart';

class TrackingRepository implements ITrackingRepository {
  final ITrackingRemoteDataSource remoteDataSource;

  TrackingRepository({required this.remoteDataSource});

  @override
  Future<TrackingEntity> getTrackingByParcelId(String parcelId) async {
    return await remoteDataSource.getTrackingByParcelId(parcelId);
  }

  @override
  Future<List<TrackingEntity>> getTrackingHistory(
    String parcelId, {
    int limit = 50,
  }) async {
    return await remoteDataSource.getTrackingHistory(parcelId, limit);
  }

  @override
  Future<TrackingEntity> updateTrackingLocation(
    String trackingId,
    double latitude,
    double longitude, {
    String? address,
  }) async {
    return await remoteDataSource.updateTrackingLocation(
      trackingId,
      latitude,
      longitude,
      address: address,
    );
  }

  @override
  Future<List<TrackingEntity>> getActiveTrackingForRider(String riderId) async {
    throw UnimplementedError();
  }

  @override
  Stream<TrackingEntity> streamTracking(String parcelId) {
    // TODO: Implement WebSocket streaming for real-time tracking
    throw UnimplementedError();
  }
}
