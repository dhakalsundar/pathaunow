import 'package:pathau_now/data/datasources/parcel_remote_data_source.dart';
import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/domain/repositories/repository_interfaces.dart';

class ParcelRepository implements IParcelRepository {
  final IParcelRemoteDataSource remoteDataSource;

  ParcelRepository({required this.remoteDataSource});

  @override
  Future<ParcelEntity> createParcel({
    required String userId,
    required ParcelSender sender,
    required ParcelReceiver receiver,
    required double weight,
    required double price,
    Map<String, dynamic>? dimensions,
  }) async {
    final parcelData = {
      'sender': {
        'name': sender.name,
        'email': sender.email,
        'phone': sender.phone,
        'address': sender.address,
        'city': sender.city,
      },
      'receiver': {
        'name': receiver.name,
        'email': receiver.email,
        'phone': receiver.phone,
        'address': receiver.address,
        'city': receiver.city,
      },
      'weight': weight,
      'price': price,
      'dimensions': dimensions,
    };

    return await remoteDataSource.createParcel(parcelData);
  }

  @override
  Future<ParcelEntity> getParcelByTrackingId(String trackingId) async {
    return await remoteDataSource.getParcelByTrackingId(trackingId);
  }

  @override
  Future<ParcelEntity> getParcelById(String parcelId) async {
    // Implementation would fetch by ID from API
    throw UnimplementedError();
  }

  @override
  Future<List<ParcelEntity>> getUserParcels(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getUserParcels(userId, page, limit);
  }

  @override
  Future<ParcelEntity> updateParcelStatus(
    String parcelId,
    String status, {
    String? notes,
  }) async {
    return await remoteDataSource.updateParcelStatus(
      parcelId,
      status,
      notes: notes,
    );
  }

  @override
  Future<ParcelEntity> getParcelTracking(String trackingId) async {
    return await remoteDataSource.getParcelByTrackingId(trackingId);
  }

  @override
  Future<List<ParcelEntity>> getParcelsByStatus(
    String status, {
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getParcelsByStatus(status, page, limit);
  }

  @override
  Future<void> deleteParcel(String parcelId) async {
    // Implementation would delete parcel from API
    throw UnimplementedError();
  }
}
