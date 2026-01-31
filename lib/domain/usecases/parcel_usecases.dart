import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/domain/repositories/repository_interfaces.dart';

/// Use Cases - Orchestrate domain logic

class CreateParcelUseCase {
  final IParcelRepository repository;

  CreateParcelUseCase({required this.repository});

  Future<ParcelEntity> call({
    required String userId,
    required ParcelSender sender,
    required ParcelReceiver receiver,
    required double weight,
    required double price,
    Map<String, dynamic>? dimensions,
  }) async {
    return await repository.createParcel(
      userId: userId,
      sender: sender,
      receiver: receiver,
      weight: weight,
      price: price,
      dimensions: dimensions,
    );
  }
}

class GetParcelTrackingUseCase {
  final IParcelRepository repository;

  GetParcelTrackingUseCase({required this.repository});

  Future<ParcelEntity> call(String trackingId) async {
    return await repository.getParcelTracking(trackingId);
  }
}

class GetUserParcelsUseCase {
  final IParcelRepository repository;

  GetUserParcelsUseCase({required this.repository});

  Future<List<ParcelEntity>> call(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getUserParcels(userId, page: page, limit: limit);
  }
}

class UpdateParcelStatusUseCase {
  final IParcelRepository repository;

  UpdateParcelStatusUseCase({required this.repository});

  Future<ParcelEntity> call(
    String parcelId,
    String status, {
    String? notes,
  }) async {
    return await repository.updateParcelStatus(parcelId, status, notes: notes);
  }
}
