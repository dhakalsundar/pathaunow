import '../entities/parcel_entity.dart';
import '../repositories/tracking_repository.dart';

class GetParcelUseCase {
  final TrackingRepository repository;

  GetParcelUseCase(this.repository);

  Future<ParcelEntity?> execute(String trackingId) async {
    return repository.getParcelById(trackingId);
  }
}
