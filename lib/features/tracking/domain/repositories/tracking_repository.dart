import '../entities/parcel_entity.dart';

abstract class TrackingRepository {
  Future<void> createParcel(ParcelEntity parcel);
  Future<ParcelEntity?> getParcelById(String trackingId);
  Future<List<ParcelEntity>> getParcelsForUser(String ownerEmail);
  Future<void> assignCourier(String trackingId, String courierName);
  Future<void> updateParcelStatus(String trackingId, String status);
}
