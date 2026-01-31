import 'dart:io';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';
import 'package:pathau_now/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pathau_now/features/auth/data/datasources/address_remote_datasource.dart';
import 'package:pathau_now/core/services/http_service.dart';
import 'package:pathau_now/core/services/hive/hive_service.dart';
import 'package:pathau_now/core/services/connectivity_service.dart';
import 'dart:convert';

abstract class AuthRepository {
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

  Future<UserEntity?> getCurrentUser();

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  });

  Future<Map<String, dynamic>> uploadProfileImage(File imageFile);

  Future<void> logout();

  Future<void> saveToken(String token);

  String? getStoredToken();

  Future<List<AddressEntity>> getAddresses();

  Future<AddressEntity> createAddress({
    required Map<String, dynamic> addressData,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final AddressRemoteDataSource _addressRemoteDataSource;

  AuthRepositoryImpl({
    AuthRemoteDataSource? authRemoteDataSource,
    AddressRemoteDataSource? addressRemoteDataSource,
  }) : _authRemoteDataSource =
           authRemoteDataSource ?? AuthRemoteDataSourceImpl(),
       _addressRemoteDataSource =
           addressRemoteDataSource ?? AddressRemoteDataSourceImpl() {
    _initializeToken();
  }

  void _initializeToken() {
    final token = getStoredToken();
    if (token != null && token.isNotEmpty) {
      HttpService.setToken(token);
      print(
        ' AuthRepository: Token loaded from storage and set in HttpService',
      );
    } else {
      print(' AuthRepository: No stored token found');
    }
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      print(' AuthRepository: Starting signup process...');
      print(' AuthRepository: Email: $email');

      final hasInternet = await ConnectivityService.hasConnectionFast();
      print(' AuthRepository: Internet available: $hasInternet');

      if (!hasInternet) {
        print(' AuthRepository: No internet, saving user locally');
        final localUser = {
          'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': email,
          'phone': phone,
          'profileImage': null,
          'createdAt': DateTime.now().toIso8601String(),
          'isEmailVerified': false,
          'isLocal': true,
        };

        await HiveService.sessionBox().put(
          'pendingUser',
          jsonEncode(localUser),
        );
        await HiveService.sessionBox().put('user', jsonEncode(localUser));

        final localToken =
            'local_token_${DateTime.now().millisecondsSinceEpoch}';
        await saveToken(localToken);

        return {
          'success': true,
          'message': 'Account created offline. Will sync when online.',
          'user': localUser,
          'token': localToken,
          'isLocal': true,
        };
      }

      final response = await _authRemoteDataSource.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      print(' AuthRepository: Response received from data source');

      if (response['token'] != null) {
        print(' AuthRepository: Token received, saving...');
        await saveToken(response['token']);
        HttpService.setToken(response['token']);
        print(' AuthRepository: Token saved successfully');
      } else {
        print(' AuthRepository: No token in response');
      }

      print(' AuthRepository: Signup completed successfully');
      return response;
    } catch (e) {
      print(' AuthRepository: Signup error: $e');

      if (e.toString().contains('Network') ||
          e.toString().contains('Connection')) {
        print(' AuthRepository: Network error, saving user locally');
        final localUser = {
          'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': email,
          'phone': phone,
          'profileImage': null,
          'createdAt': DateTime.now().toIso8601String(),
          'isEmailVerified': false,
          'isLocal': true,
        };

        await HiveService.sessionBox().put(
          'pendingUser',
          jsonEncode(localUser),
        );
        await HiveService.sessionBox().put('user', jsonEncode(localUser));

        final localToken =
            'local_token_${DateTime.now().millisecondsSinceEpoch}';
        await saveToken(localToken);

        return {
          'success': true,
          'message': 'Account created offline. Will sync when online.',
          'user': localUser,
          'token': localToken,
          'isLocal': true,
        };
      }

      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print(' AuthRepository: Starting login process...');
      print(' AuthRepository: Email: $email');

      final response = await _authRemoteDataSource.login(
        email: email,
        password: password,
      );

      print(' AuthRepository: DataSource response received');
      print(' AuthRepository: Success: ${response['success']}');
      print(' AuthRepository: User data present: ${response['user'] != null}');

      if (response['token'] != null) {
        await saveToken(response['token']);
        HttpService.setToken(response['token']);
        print(' AuthRepository: Token saved and set');
      }

      if (response['user'] != null) {
        final user = response['user'];
        print(
          ' AuthRepository: User data - Name: ${user['name']}, Email: ${user['email']}, Phone: ${user['phone']}',
        );
      }

      print(' AuthRepository: Login completed successfully');
      return response;
    } catch (e) {
      print(' AuthRepository: Login error: $e');
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      print(' AuthRepository: Getting current user...');
      final token = getStoredToken();
      print(
        ' AuthRepository: Token exists: ${token != null && token.isNotEmpty}',
      );

      if (token == null || token.isEmpty) {
        print(' AuthRepository: No token available, returning null');
        return null;
      }

      HttpService.setToken(token);
      print(' AuthRepository: Calling remote data source...');
      final user = await _authRemoteDataSource.getCurrentUser();
      print(' AuthRepository: User fetched successfully - ${user.name}');
      return user;
    } catch (e) {
      print(' AuthRepository: Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    try {
      return await _authRemoteDataSource.updateProfile(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final response = await _authRemoteDataSource.uploadProfileImage(
        imageFile,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authRemoteDataSource.logout();
      await HiveService.saveToken('');
      HttpService.clearToken();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await HiveService.saveToken(token);
  }

  @override
  String? getStoredToken() {
    return HiveService.getToken();
  }

  @override
  Future<List<AddressEntity>> getAddresses() async {
    try {
      return await _addressRemoteDataSource.getUserAddresses();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AddressEntity> createAddress({
    required Map<String, dynamic> addressData,
  }) async {
    try {
      return await _addressRemoteDataSource.createAddress(
        addressData: addressData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
