import 'package:flutter/material.dart';
import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/data/repositories/tracking_repository_impl.dart';
import 'package:pathau_now/core/error/exceptions.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingRepository _trackingRepository;

  TrackingProvider(this._trackingRepository);

  TrackingEntity? _currentTracking;
  List<TrackingEntity> _trackingHistory = [];
  bool _isLoading = false;
  AppException? _error;

  TrackingEntity? get currentTracking => _currentTracking;
  List<TrackingEntity> get trackingHistory => _trackingHistory;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  Future<void> getTracking(String parcelId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentTracking = await _trackingRepository.getTrackingByParcelId(
        parcelId,
      );
      notifyListeners();
    } on AppException catch (e) {
      _setError(e);
    }
  }

  Future<void> getTrackingHistory(String parcelId, {int limit = 50}) async {
    _setLoading(true);
    _clearError();

    try {
      _trackingHistory = await _trackingRepository.getTrackingHistory(
        parcelId,
        limit: limit,
      );
      notifyListeners();
    } on AppException catch (e) {
      _setError(e);
    }
  }

  void streamTracking(String parcelId) {
    _trackingRepository
        .streamTracking(parcelId)
        .listen(
          (tracking) {
            _currentTracking = tracking;
            notifyListeners();
          },
          onError: (error) {
            _setError(AppException(message: error.toString()));
          },
        );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(AppException error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
