import 'package:flutter/foundation.dart';
import 'dart:io';

import 'dart:convert';
import 'package:pathau_now/core/services/hive/hive_service.dart';
import 'package:pathau_now/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pathau_now/features/auth/domain/entities/user_entity.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pathau_now/core/services/http_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel(this._repository) {
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    try {
      print(' AuthViewModel: Loading cached user...');
      final js = HiveService.sessionBox().get('user');
      print(
        ' AuthViewModel: Cached data exists: ${js is String && js.isNotEmpty}',
      );

      if (js is String && js.isNotEmpty) {
        final m = jsonDecode(js) as Map<String, dynamic>;
        _user = UserEntity(
          id: (m['id'] ?? '').toString(),
          name: (m['name'] ?? '').toString(),
          email: (m['email'] ?? '').toString(),
          phone: (m['phone'] ?? '').toString(),
          profileImage: m['profileImage'],
          createdAt: m['createdAt'] != null
              ? DateTime.tryParse(m['createdAt'])
              : null,
          isEmailVerified: m['isEmailVerified'] ?? false,
        );
        _loginIdentifierUsed = m['loginIdentifier']?.toString();
        print(' AuthViewModel: Loaded cached user: ${_user?.name}');
        print(' AuthViewModel: Email verified: ${_user?.isEmailVerified}');
        notifyListeners();
      }

      final token = _repository.getStoredToken();
      print(
        ' AuthViewModel: Stored token exists: ${token != null && token.isNotEmpty}',
      );
      if (token != null && token.isNotEmpty) {
        print(' AuthViewModel: Setting token in HttpService...');
        HttpService.setToken(token);
        print(' AuthViewModel: Fetching fresh user data...');
        await getCurrentUser();
      }
    } catch (e) {
      print(' AuthViewModel: Error loading cached user: $e');
    }
  }

  UserEntity? _user;
  String? _loginIdentifierUsed;
  bool _isLoading = false;
  String? _error;

  UserEntity? get user => _user;
  String? get loginIdentifierUsed => _loginIdentifierUsed;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _getStoredToken() != null;

  String? _getStoredToken() {
    return _repository.getStoredToken();
  }

  String? getStoredToken() {
    return _repository.getStoredToken();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(' AuthViewModel: Starting signup...');
      print(' AuthViewModel: Email: $email, Name: $name');

      final response = await _repository.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      print(' AuthViewModel: Repository response received');
      print(' AuthViewModel: Success: ${response['success']}');

      if (response['success'] == false) {
        _error = response['message'] ?? 'Signup failed';
        print(' AuthViewModel: Signup failed - $_error');
        notifyListeners();
        return;
      }

      print(' AuthViewModel: Signup successful');

      if (response['user'] != null &&
          response['user'] is Map<String, dynamic>) {
        final u = response['user'];
        _user = UserEntity(
          id: (u['id'] ?? u['_id'] ?? '').toString(),
          name: (u['name'] ?? '').toString(),
          email: (u['email'] ?? '').toString(),
          phone: (u['phone'] ?? '').toString(),
          profileImage: u['profileImage'],
          createdAt: u['createdAt'] != null
              ? DateTime.tryParse(u['createdAt'])
              : null,
          isEmailVerified: u['isEmailVerified'] ?? false,
        );
        print(' AuthViewModel: User entity created - ${_user!.name}');
      } else {
        print(' AuthViewModel: No user in response, fetching current user...');
        final fetched = await getCurrentUser();
        _user = fetched ?? _user;
      }

      try {
        if (_user != null) {
          _loginIdentifierUsed = email;
          await HiveService.sessionBox().put(
            'user',
            jsonEncode({
              'id': _user!.id,
              'name': _user!.name,
              'email': _user!.email,
              'phone': _user!.phone,
              'profileImage': _user!.profileImage,
              'loginIdentifier': _loginIdentifierUsed,
              'createdAt': _user!.createdAt?.toIso8601String(),
              'isEmailVerified': _user!.isEmailVerified,
            }),
          );
          print(' AuthViewModel: User data cached to Hive');
        }
      } catch (e) {
        print(' AuthViewModel: Failed to cache user data: $e');
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      print(' AuthViewModel: Exception during signup: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(
    File file, {
    bool crop = true,
    int quality = 85,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      File processed = file;

      if (crop) {
        try {
          final cropped = await _cropImage(processed);
          if (cropped != null) processed = cropped;
        } catch (_) {}
      }

      try {
        final compressed = await _compressImage(processed, quality: quality);
        if (compressed != null) processed = compressed;
      } catch (_) {}

      final response = await _repository.uploadProfileImage(processed);

      if (response['success'] == true && response['user'] != null) {
        final u = response['user'];
        _user = UserEntity(
          id: (u['id'] ?? u['_id'] ?? '').toString(),
          name: (u['name'] ?? '').toString(),
          email: (u['email'] ?? '').toString(),
          phone: (u['phone'] ?? '').toString(),
          profileImage: u['profileImage'],
          createdAt: u['createdAt'] != null
              ? DateTime.tryParse(u['createdAt'])
              : null,
          isEmailVerified: u['isEmailVerified'] ?? false,
        );

        try {
          _loginIdentifierUsed = _loginIdentifierUsed ?? _user?.email;
          await HiveService.sessionBox().put(
            'user',
            jsonEncode({
              'id': _user!.id,
              'name': _user!.name,
              'email': _user!.email,
              'phone': _user!.phone,
              'profileImage': _user!.profileImage,
              'loginIdentifier': _loginIdentifierUsed,
              'createdAt': _user!.createdAt?.toIso8601String(),
              'isEmailVerified': _user!.isEmailVerified,
            }),
          );
        } catch (_) {}
      } else {
        throw Exception(response['message'] ?? 'Upload failed');
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

  Future<File?> _cropImage(File file) async {
    try {
      final img = await ImageCropper().cropImage(sourcePath: file.path);
      if (img == null) return null;
      return File(img.path);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _compressImage(File file, {int quality = 85}) async {
    try {
      final targetPath = '${file.parent.path}/c_${file.uri.pathSegments.last}';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
      );

      if (result == null) return null;

      try {
        return File(result.path);
      } catch (_) {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(' AuthViewModel: Starting login...');
      print(' AuthViewModel: Email: $email');

      final response = await _repository.login(
        email: email,
        password: password,
      );

      print(' AuthViewModel: Repository response received');
      print(' AuthViewModel: Success: ${response['success']}');

      // If API returned an explicit error
      if (response['success'] == false) {
        _error = response['message'] ?? 'Login failed';
        print(' AuthViewModel: Login failed - $_error');
        notifyListeners();
        return;
      }

      // If the login response contains user, use it.
      if (response['user'] != null &&
          response['user'] is Map<String, dynamic>) {
        final u = response['user'];
        _user = UserEntity(
          id: (u['id'] ?? u['_id'] ?? '').toString(),
          name: (u['name'] ?? '').toString(),
          email: (u['email'] ?? '').toString(),
          phone: (u['phone'] ?? '').toString(),
          profileImage: u['profileImage'],
          createdAt: u['createdAt'] != null
              ? DateTime.tryParse(u['createdAt'])
              : null,
          isEmailVerified: u['isEmailVerified'] ?? false,
        );
        print(' AuthViewModel: User entity created from response');
        print(
          ' AuthViewModel: Name: ${_user!.name}, Email: ${_user!.email}, Phone: ${_user!.phone}',
        );
      } else {
        print(' AuthViewModel: No user in response, fetching current user...');
        // Otherwise fetch user from API using saved token
        final fetched = await getCurrentUser();
        _user = fetched ?? _user;
      }

      try {
        if (_user != null) {
          _loginIdentifierUsed = email;
          await HiveService.sessionBox().put(
            'user',
            jsonEncode({
              'id': _user!.id,
              'name': _user!.name,
              'email': _user!.email,
              'phone': _user!.phone,
              'profileImage': _user!.profileImage,
              'loginIdentifier': _loginIdentifierUsed,
              'createdAt': _user!.createdAt?.toIso8601String(),
              'isEmailVerified': _user!.isEmailVerified,
            }),
          );
          print(' AuthViewModel: User data cached to Hive');
          print(
            ' AuthViewModel: Cached data: Name=${_user!.name}, Email=${_user!.email}',
          );
        }
      } catch (e) {
        print(' AuthViewModel: Failed to cache user data: $e');
      }

      print(' AuthViewModel: Login completed successfully');
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

  Future<UserEntity?> getCurrentUser() async {
    try {
      print(' AuthViewModel: Attempting to get current user...');
      final token = _getStoredToken();
      print(
        ' AuthViewModel: Token exists: ${token != null && token.isNotEmpty}',
      );

      final user = await _repository.getCurrentUser();
      _user = user;
      print(' AuthViewModel: User fetched: ${user?.name ?? "null"}');

      notifyListeners();
      return _user;
    } catch (e) {
      print(' AuthViewModel: Error getting current user: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProfile(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );
      if (_user != null) {
        _user = _user!.copyWith(
          name: name,
          phone: phone,
          profileImage: profileImage ?? _user!.profileImage,
        );
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

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.logout();
      _user = null;
      try {
        await HiveService.sessionBox().delete('user');
      } catch (_) {}
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
