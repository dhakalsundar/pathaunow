import 'package:flutter/foundation.dart';
import 'package:pathau_now/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';

class AddressViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AddressViewModel(this._repository);

  List<AddressEntity> _addresses = [];
  AddressEntity? _selectedAddress;
  bool _isLoading = false;
  String? _error;

  List<AddressEntity> get addresses => _addresses;
  AddressEntity? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _repository.getAddresses();
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAddress({
    required Map<String, dynamic> addressData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newAddress = await _repository.createAddress(
        addressData: addressData,
      );
      _addresses.add(newAddress);
      _selectedAddress = newAddress;
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

  void selectAddress(AddressEntity address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
