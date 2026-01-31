import 'package:pathau_now/data/datasources/user_remote_data_source.dart';
import 'package:pathau_now/domain/entities/user_entity.dart';
import 'package:pathau_now/domain/repositories/repository_interfaces.dart';

class UserRepository implements IUserRepository {
  final IUserRemoteDataSource remoteDataSource;

  UserRepository({required this.remoteDataSource});

  @override
  Future<UserEntity> getUserById(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getUserByEmail(String email) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> updateUserProfile(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    return await remoteDataSource.updateUserProfile(updateData);
  }

  @override
  Future<UserEntity> addAddress(String userId, AddressEntity address) async {
    final addressData = {
      'address': {
        'label': address.label,
        'address': address.address,
        'city': address.city,
        'coordinates': address.latitude != null && address.longitude != null
            ? {'latitude': address.latitude, 'longitude': address.longitude}
            : null,
        'isDefault': address.isDefault,
      },
    };
    return await remoteDataSource.addAddress(addressData);
  }

  @override
  Future<UserEntity> removeAddress(String userId, String addressId) {
    throw UnimplementedError();
  }

  @override
  Future<List<UserEntity>> getRidersNearby(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  }) async {
    return await remoteDataSource.getRidersNearby(
      latitude,
      longitude,
      radiusKm: radiusKm,
    );
  }
}
