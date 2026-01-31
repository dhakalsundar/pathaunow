import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/domain/entities/user_entity.dart';

abstract class IParcelRepository {
  Future<ParcelEntity> createParcel({
    required String userId,
    required ParcelSender sender,
    required ParcelReceiver receiver,
    required double weight,
    required double price,
    Map<String, dynamic>? dimensions,
  });

  Future<ParcelEntity> getParcelByTrackingId(String trackingId);

  Future<ParcelEntity> getParcelById(String parcelId);

  Future<List<ParcelEntity>> getUserParcels(
    String userId, {
    int page = 1,
    int limit = 10,
  });

  Future<ParcelEntity> updateParcelStatus(
    String parcelId,
    String status, {
    String? notes,
  });

  Future<ParcelEntity> getParcelTracking(String trackingId);

  Future<List<ParcelEntity>> getParcelsByStatus(
    String status, {
    int page = 1,
    int limit = 10,
  });

  Future<void> deleteParcel(String parcelId);
}

abstract class IUserRepository {
  Future<UserEntity> getUserById(String userId);

  Future<UserEntity> getUserByEmail(String email);

  Future<UserEntity> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  );

  Future<UserEntity> addAddress(String userId, AddressEntity address);

  Future<UserEntity> removeAddress(String userId, String addressId);

  Future<List<UserEntity>> getRidersNearby(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  });
}

abstract class ITrackingRepository {
  Future<TrackingEntity> getTrackingByParcelId(String parcelId);

  Future<List<TrackingEntity>> getTrackingHistory(
    String parcelId, {
    int limit = 50,
  });

  Future<TrackingEntity> updateTrackingLocation(
    String trackingId,
    double latitude,
    double longitude, {
    String? address,
  });

  Future<List<TrackingEntity>> getActiveTrackingForRider(String riderId);

  Stream<TrackingEntity> streamTracking(String parcelId);
}
