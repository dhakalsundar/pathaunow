import 'package:flutter/foundation.dart';
import 'package:pathau_now/features/tracking/data/repositories/parcel_repository_impl.dart';
import 'package:pathau_now/features/tracking/domain/entities/parcel_entity.dart';

class ParcelViewModel extends ChangeNotifier {
  final ParcelRepository _repository;

  ParcelViewModel(this._repository);

  ParcelEntity? _selectedParcel;
  List<ParcelEntity> _userParcels = [];
  bool _isLoading = false;
  String? _error;

  ParcelEntity? get selectedParcel => _selectedParcel;
  List<ParcelEntity> get userParcels => _userParcels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getParcelByTracking(String trackingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedParcel = await _repository.getParcelByTracking(trackingId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUserParcels({int page = 1, int limit = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userParcels = await _repository.getUserParcels(page: page, limit: limit);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ParcelEntity> createParcel({
    required Map<String, dynamic> parcelData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _repository.createParcel(parcelData: parcelData);
      await getUserParcels();
      _error = null;
      notifyListeners();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateParcelStatus({
    required String parcelId,
    required String status,
    String? location,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateParcelStatus(
        parcelId: parcelId,
        status: status,
        location: location,
        description: description,
      );
      if (_selectedParcel?.id == parcelId) {
        await getParcelByTracking(_selectedParcel!.trackingId);
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelParcel(String parcelId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.cancelParcel(parcelId);
      await getUserParcels();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
