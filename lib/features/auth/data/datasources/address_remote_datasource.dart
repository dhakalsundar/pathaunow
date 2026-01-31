import 'package:pathau_now/core/services/http_service.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';

abstract class AddressRemoteDataSource {
  Future<AddressEntity> createAddress({
    required Map<String, dynamic> addressData,
  });
  Future<List<AddressEntity>> getUserAddresses();
  Future<AddressEntity> getAddress(String addressId);
  Future<AddressEntity> updateAddress({
    required String addressId,
    required Map<String, dynamic> addressData,
  });
  Future<void> deleteAddress(String addressId);
  Future<AddressEntity> setDefaultAddress(String addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  @override
  Future<AddressEntity> createAddress({
    required Map<String, dynamic> addressData,
  }) async {
    final response = await HttpService.post('/addresses', body: addressData);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to create address');
    }
    return _mapToAddressEntity(response['address']);
  }

  @override
  Future<List<AddressEntity>> getUserAddresses() async {
    final response = await HttpService.get('/addresses');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch addresses');
    }
    final List<dynamic> addresses = response['addresses'] ?? [];
    return addresses.map((a) => _mapToAddressEntity(a)).toList();
  }

  @override
  Future<AddressEntity> getAddress(String addressId) async {
    final response = await HttpService.get('/addresses/$addressId');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to fetch address');
    }
    return _mapToAddressEntity(response['address']);
  }

  @override
  Future<AddressEntity> updateAddress({
    required String addressId,
    required Map<String, dynamic> addressData,
  }) async {
    final response = await HttpService.put(
      '/addresses/$addressId',
      body: addressData,
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to update address');
    }
    return _mapToAddressEntity(response['address']);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final response = await HttpService.delete('/addresses/$addressId');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to delete address');
    }
  }

  @override
  Future<AddressEntity> setDefaultAddress(String addressId) async {
    final response = await HttpService.put(
      '/addresses/$addressId/default',
      body: {},
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to set default address');
    }
    return _mapToAddressEntity(response['address']);
  }

  AddressEntity _mapToAddressEntity(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['_id'] ?? json['id'] ?? '',
      label: json['label'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? 'Nepal',
      isDefault: json['isDefault'] ?? false,
      coordinates: json['coordinates'] != null
          ? {
              'latitude': (json['coordinates']['latitude'] ?? 0.0).toDouble(),
              'longitude': (json['coordinates']['longitude'] ?? 0.0).toDouble(),
            }
          : null,
    );
  }
}
