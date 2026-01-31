import 'package:pathau_now/core/models/parcel.dart' as data_model;
import 'package:pathau_now/core/services/hive/hive_service.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  @override
  Future<void> createParcel(ParcelEntity parcel) async {
    final dm = data_model.Parcel(
      trackingId: parcel.trackingId,
      sender: parcel.sender.name,
      recipient: parcel.receiver.name,
      status: parcel.status,
      courierName: 'Unassigned',
      ownerEmail: parcel.sender.email,
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
      id: trackingId,
      trackingId: p.trackingId,
      sender: SenderEntity(
        name: p.sender,
        email: p.ownerEmail,
        phone: '',
        address: '',
        city: '',
      ),
      receiver: ReceiverEntity(
        name: p.recipient,
        email: '',
        phone: '',
        address: '',
        city: '',
      ),
      status: p.status,
      weight: 0.0,
      price: 0.0,
      paymentStatus: 'pending',
      contents: '',
      timeline: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<ParcelEntity>> getParcelsForUser(String ownerEmail) async {
    final box = HiveService.parcelsBox();
    final parcels = box.values
        .where((p) => p.ownerEmail == ownerEmail)
        .map(
          (p) => ParcelEntity(
            id: p.trackingId,
            trackingId: p.trackingId,
            sender: SenderEntity(
              name: p.sender,
              email: p.ownerEmail,
              phone: '',
              address: '',
              city: '',
            ),
            receiver: ReceiverEntity(
              name: p.recipient,
              email: '',
              phone: '',
              address: '',
              city: '',
            ),
            status: p.status,
            weight: 0.0,
            price: 0.0,
            paymentStatus: 'pending',
            contents: '',
            timeline: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
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
