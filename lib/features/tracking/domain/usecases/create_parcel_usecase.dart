import '../entities/parcel_entity.dart';
import '../repositories/tracking_repository.dart';

class CreateParcelUseCase {
  final TrackingRepository repository;

  CreateParcelUseCase(this.repository);

  Future<void> execute(ParcelEntity parcel) async {
    return repository.createParcel(parcel);
  }
}
