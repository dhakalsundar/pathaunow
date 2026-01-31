import 'package:pathau_now/core/network/api_client.dart';
import 'package:pathau_now/data/models/user_model.dart';

abstract class IUserRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(Map<String, dynamic> updateData);
  Future<UserModel> addAddress(Map<String, dynamic> address);
  Future<List<UserModel>> getRidersNearby(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  });
}

class UserRemoteDataSource implements IUserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSource({required this.apiClient});

  @override
  Future<UserModel> getUserProfile() async {
    final response = await apiClient.get('/users/profile');
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> updateUserProfile(Map<String, dynamic> updateData) async {
    final response = await apiClient.put('/users/profile', body: updateData);
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> addAddress(Map<String, dynamic> address) async {
    final response = await apiClient.post('/users/addresses', body: address);
    return UserModel.fromJson(response);
  }

  @override
  Future<List<UserModel>> getRidersNearby(
    double latitude,
    double longitude, {
    double radiusKm = 10,
  }) async {
    final response = await apiClient.get(
      '/users/riders-nearby?latitude=$latitude&longitude=$longitude&radius=$radiusKm',
    );
    final List<dynamic> data = response['data'] ?? [];
    return data.map((u) => UserModel.fromJson(u)).toList();
  }
}
