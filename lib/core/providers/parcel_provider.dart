import 'package:flutter/material.dart';
import 'package:pathau_now/domain/entities/parcel_entity.dart';
import 'package:pathau_now/domain/usecases/parcel_usecases.dart';
import 'package:pathau_now/core/error/exceptions.dart';

class ParcelProvider extends ChangeNotifier {
  final GetParcelTrackingUseCase getTrackingUseCase;
  final GetUserParcelsUseCase getUserParcelsUseCase;
  final CreateParcelUseCase createParcelUseCase;

  ParcelEntity? _currentParcel;
  List<ParcelEntity> _userParcels = [];
  final List<TrackingEntity> _trackingHistory = [];
  bool _isLoading = false;
  AppException? _error;

  ParcelProvider({
    required this.getTrackingUseCase,
    required this.getUserParcelsUseCase,
    required this.createParcelUseCase,
  });

  // Getters
  ParcelEntity? get currentParcel => _currentParcel;
  List<ParcelEntity> get userParcels => _userParcels;
  List<TrackingEntity> get trackingHistory => _trackingHistory;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  // Get parcel tracking by ID
  Future<void> getParcelTracking(String trackingId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentParcel = await getTrackingUseCase(trackingId);
      notifyListeners();
    } on AppException catch (e) {
      _setError(e);
    }
  }

  // Get user's parcels
  Future<void> getUserParcels(
    String userId, {
    int page = 1,
    int limit = 10,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _userParcels = await getUserParcelsUseCase(
        userId,
        page: page,
        limit: limit,
      );
      notifyListeners();
    } on AppException catch (e) {
      _setError(e);
    }
  }

  // Create new parcel
  Future<void> createParcel({
    required String userId,
    required ParcelSender sender,
    required ParcelReceiver receiver,
    required double weight,
    required double price,
    Map<String, dynamic>? dimensions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final parcel = await createParcelUseCase(
        userId: userId,
        sender: sender,
        receiver: receiver,
        weight: weight,
        price: price,
        dimensions: dimensions,
      );

      _currentParcel = parcel;
      notifyListeners();
    } on AppException catch (e) {
      _setError(e);
    }
  }

  // Private helpers
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

  void clearCurrentParcel() {
    _currentParcel = null;
    notifyListeners();
  }

  void clearUserParcels() {
    _userParcels = [];
    notifyListeners();
  }
}
