import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/domain/entities/user_entity.dart';

/// Abstract repositories defining contracts for data operations

abstract class IParcelRepository {
  /// Create a new parcel
  Future<ParcelEntity> createParcel({
    required String userId,
    required ParcelSender sender,
    required ParcelReceiver receiver,
    required double weight,
    required double price,
    Map<String, dynamic>? dimensions,
  });

  /// Get parcel by tracking ID
  Future<ParcelEntity> getParcelByTrackingId(String trackingId);

  /// Get parcel by ID
  Future<ParcelEntity> getParcelById(String parcelId);

  /// Get all parcels for a user
  Future<List<ParcelEntity>> getUserParcels(
    String userId, {
    int page = 1,
    int limit = 10,
  });

  /// Update parcel status
  Future<ParcelEntity> updateParcelStatus(
    String parcelId,
    String status, {
    String? notes,
  });

  /// Get parcel tracking info
  Future<ParcelEntity> getParcelTracking(String trackingId);

  /// Get parcels by status
  Future<List<ParcelEntity>> getParcelsByStatus(
    String status, {
    int page = 1,
    int limit = 10,
  });

  /// Delete parcel
  Future<void> deleteParcel(String parcelId);
}

abstract class IUserRepository {
  /// Get user by ID
  Future<UserEntity> getUserById(String userId);

  /// Get user by email
  Future<UserEntity> getUserByEmail(String email);

  /// Update user profile
  Future<UserEntity> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  );

  /// Add address for user
  Future<UserEntity> addAddress(String userId, AddressEntity address);

  /// Remove address
  Future<UserEntity> removeAddress(String userId, String addressId);

  /// Get nearby riders
  Future<List<UserEntity>> getRidersNearby(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  });
}

abstract class ITrackingRepository {
  /// Get tracking by parcel ID
  Future<TrackingEntity> getTrackingByParcelId(String parcelId);

  /// Get tracking history
  Future<List<TrackingEntity>> getTrackingHistory(
    String parcelId, {
    int limit = 50,
  });

  /// Update tracking location
  Future<TrackingEntity> updateTrackingLocation(
    String trackingId,
    double latitude,
    double longitude, {
    String? address,
  });

  /// Get active tracking for rider
  Future<List<TrackingEntity>> getActiveTrackingForRider(String riderId);

  /// Stream tracking updates (real-time)
  Stream<TrackingEntity> streamTracking(String parcelId);
}
