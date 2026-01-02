import 'package:pathau_now/core/models/parcel.dart' as data_model;
import 'package:pathau_now/core/services/hive/hive_service.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  @override
  Future<void> createParcel(ParcelEntity parcel) async {
    final dm = data_model.Parcel(
      trackingId: parcel.trackingId,
      sender: parcel.sender,
      recipient: parcel.recipient,
      status: parcel.status,
      courierName: parcel.courierName,
      ownerEmail: parcel.ownerEmail,
    );

    final box = HiveService.parcelsBox();
    await box.put(parcel.trackingId, dm);
  }

  @override
  Future<ParcelEntity?> getParcelById(String trackingId) async {
    final box = HiveService.parcelsBox();
    final data_model.Parcel? p = box.get(trackingId);
    if (p == null) return null;
    return ParcelEntity(
      trackingId: p.trackingId,
      sender: p.sender,
      recipient: p.recipient,
      status: p.status,
      courierName: p.courierName,
      ownerEmail: p.ownerEmail,
    );
  }

  @override
  Future<List<ParcelEntity>> getParcelsForUser(String ownerEmail) async {
    final box = HiveService.parcelsBox();
    final parcels = box.values
        .where((p) => p.ownerEmail == ownerEmail)
        .map(
          (p) => ParcelEntity(
            trackingId: p.trackingId,
            sender: p.sender,
            recipient: p.recipient,
            status: p.status,
            courierName: p.courierName,
            ownerEmail: p.ownerEmail,
          ),
        )
        .toList();
    return parcels;
  }

  @override
  Future<void> assignCourier(String trackingId, String courierName) async {
    final box = HiveService.parcelsBox();
    final p = box.get(trackingId);
    if (p == null) return;
    p.courierName = courierName;
    await p.save();
  }

  @override
  Future<void> updateParcelStatus(String trackingId, String status) async {
    final box = HiveService.parcelsBox();
    final p = box.get(trackingId);
    if (p == null) return;
    p.status = status;
    await p.save();
  }
}
