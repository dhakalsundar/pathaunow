import 'package:flutter/material.dart';
import 'package:pathau_now/domain/entities/user_entity.dart';
import 'package:pathau_now/data/repositories/user_repository_impl.dart';
import 'package:pathau_now/core/error/exceptions.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository userRepository;

  UserEntity? _currentUser;
  List<UserEntity> _nearbyRiders = [];
  bool _isLoading = false;
  AppException? _error;

  UserProvider({required this.userRepository});

  UserEntity? get currentUser => _currentUser;
  List<UserEntity> get nearbyRiders => _nearbyRiders;
  bool get isLoading => _isLoading;
  AppException? get error => _error;

  Future<void> updateUserProfile(Map<String, dynamic> updateData) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser != null) {
        _currentUser = await userRepository.updateUserProfile(
          _currentUser!.id,
          updateData,
        );
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e);
    }
  }

  Future<void> addAddress(AddressEntity address) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser != null) {
        _currentUser = await userRepository.addAddress(
          _currentUser!.id,
          address,
        );
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e);
    }
  }

  Future<void> getNearbyRiders(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _nearbyRiders = await userRepository.getRidersNearby(
        latitude,
        longitude,
        radiusKm: radiusKm,
      );
      notifyListeners();
    } on AppException catch (e) {
      _setError(e);
    }
  }

  void setCurrentUser(UserEntity user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    _nearbyRiders = [];
    notifyListeners();
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
