import 'dart:io';
import 'package:pathau_now/core/api/api_client.dart';
import 'package:pathau_now/core/api/api_endpoints.dart';
import 'package:pathau_now/core/services/http_service.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<UserEntity> getCurrentUser();

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  });

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile);

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      print(' AuthRemoteDataSource: Starting signup...');
      print(' AuthRemoteDataSource: Email: $email, Phone: $phone');

      final response = await HttpService.post(
        '/auth/signup',
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      print(' AuthRemoteDataSource: Signup response received');
      print('AuthRemoteDataSource: Success: ${response['success']}');

      if (response['success'] != true) {
        print(' AuthRemoteDataSource: Signup failed - ${response['message']}');
        throw Exception(response['message'] ?? 'Signup failed');
      }

      print(' AuthRemoteDataSource: Signup successful');
      return response;
    } catch (e) {
      print(' AuthRemoteDataSource: Exception during signup: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      print(' AuthRemoteDataSource: Starting profile image upload...');

      final response = await HttpService.multipartPost(
        '/auth/profile/upload',
        file: imageFile,
      );

      print(' AuthRemoteDataSource: Upload response received');
      print(' AuthRemoteDataSource: Success: ${response['success']}');

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Upload failed');
      }
      return response;
    } catch (e) {
      print(' AuthRemoteDataSource: Upload failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print(' AuthRemoteDataSource: Starting login...');
    print(' AuthRemoteDataSource: Email: $email');

    final response = await HttpService.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    print(' AuthRemoteDataSource: Login response received');
    print(' AuthRemoteDataSource: Success: ${response['success']}');

    if (response['success'] != true) {
      print(' AuthRemoteDataSource: Login failed - ${response['message']}');
      throw Exception(response['message'] ?? 'Login failed');
    }

    if (response['user'] != null) {
      final user = response['user'];
      print(
        ' AuthRemoteDataSource: User data received - Name: ${user['name']}, Email: ${user['email']}',
      );
    }

    print(' AuthRemoteDataSource: Login successful');
    return response;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    print(' AuthRemoteDataSource: Fetching current user from API...');
    final response = await HttpService.get('/auth/me');

    print(
      ' AuthRemoteDataSource: Response received - success: ${response['success']}',
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to get user');
    }

    final userData = response['user'];
    print(
      ' AuthRemoteDataSource: User data - name: ${userData['name']}, email: ${userData['email']}',
    );

    return UserEntity(
      id: (userData['id'] ?? userData['_id'] ?? '').toString(),
      name: (userData['name'] ?? '').toString(),
      email: (userData['email'] ?? '').toString(),
      phone: (userData['phone'] ?? '').toString(),
      profileImage: userData['profileImage'],
      createdAt: userData['createdAt'] != null
          ? DateTime.tryParse(userData['createdAt'])
          : null,
      isEmailVerified: userData['isEmailVerified'] ?? false,
      addresses: (userData['addresses'] as List?)
          ?.map(
            (addr) => AddressEntity(
              id: (addr['id'] ?? addr['_id'] ?? '').toString(),
              label: (addr['label'] ?? '').toString(),
              fullName: (addr['fullName'] ?? addr['name'] ?? '').toString(),
              phone: (addr['phone'] ?? '').toString(),
              address: (addr['address'] ?? '').toString(),
              city: (addr['city'] ?? '').toString(),
              state: (addr['state'] ?? '').toString(),
              zipCode: (addr['zipCode'] ?? addr['zip'] ?? '').toString(),
              country: (addr['country'] ?? 'Nepal').toString(),
              isDefault: addr['isDefault'] ?? false,
              coordinates: addr['coordinates'] != null
                  ? {
                      'latitude': (addr['coordinates']['latitude'] ?? 0.0)
                          .toDouble(),
                      'longitude': (addr['coordinates']['longitude'] ?? 0.0)
                          .toDouble(),
                    }
                  : null,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    final body = {'name': name, 'phone': phone};
    if (profileImage != null) body['profileImage'] = profileImage;

    final response = await HttpService.put('/auth/profile', body: body);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Update failed');
    }
    return response;
  }

  @override
  Future<void> logout() async {
    await HttpService.post('/auth/logout', body: {});
    HttpService.clearToken();
  }
}
