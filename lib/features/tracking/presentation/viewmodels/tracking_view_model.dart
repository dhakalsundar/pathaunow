import 'package:flutter/material.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';
import 'package:pathau_now/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:pathau_now/features/tracking/domain/usecases/get_parcel_usecase.dart';
import 'package:pathau_now/features/tracking/domain/usecases/create_parcel_usecase.dart';

class TrackingViewModel extends ChangeNotifier {
  final TrackingRepositoryImpl _repo = TrackingRepositoryImpl();

  ParcelEntity? parcel;
  List<ParcelEntity> parcels = [];
  bool loading = false;

  Future<void> createParcel(ParcelEntity p) async {
    loading = true;
    notifyListeners();
    await CreateParcelUseCase(_repo).execute(p);
    loading = false;
    notifyListeners();
  }

  Future<void> getParcel(String id) async {
    loading = true;
    notifyListeners();
    parcel = await GetParcelUseCase(_repo).execute(id);
    loading = false;
    notifyListeners();
  }

  Future<void> loadParcelsForUser(String email) async {
    loading = true;
    notifyListeners();
    parcels = await _repo.getParcelsForUser(email);
    loading = false;
    notifyListeners();
  }
}
