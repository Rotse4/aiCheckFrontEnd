import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:my_flutter_project/storage/storage_web.dart';
// Platform storage: uses SharedPreferences on mobile/desktop and localStorage on web.
// import 'storage/storage_stub.dart'
//     if (dart.library.html) 'storage/storage_web.dart'
//     if (dart.library.io) 'storage/storage_sp.dart' hide getStore;

class AuthResponse {
  final String token;
  final String username;

  AuthResponse({required this.token, required this.username});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';

  // Keep this in sync with DashboardController
  final String baseUrl = 'http://10.193.115.168:8000/api';

  final KeyValueStore _store = getStore();

  Future<void> saveAuth(AuthResponse auth) async {
    await _store.setString(_tokenKey, auth.token);
    await _store.setString(_usernameKey, auth.username);
  }

  Future<void> clearAuth() async {
    await _store.remove(_tokenKey);
    await _store.remove(_usernameKey);
  }

  Future<String?> getToken() async {
    return _store.getString(_tokenKey);
  }

  Future<String?> getUsername() async {
    return _store.getString(_usernameKey);
  }

  Future<AuthResponse> login({required String username, required String password}) async {
    final dio = Dio();
    final resp = await dio.post(
      '$baseUrl/auth/login/',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({'username': username, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final auth = AuthResponse.fromJson(resp.data);
      await saveAuth(auth);
      return auth;
    }
    throw Exception('Login failed: ${resp.statusCode}');
  }

  Future<AuthResponse> register({required String username, String? email, required String password}) async {
    final dio = Dio();
    final resp = await dio.post(
      '$baseUrl/auth/register/',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: jsonEncode({'username': username, if (email != null && email.isNotEmpty) 'email': email, 'password': password}),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final auth = AuthResponse.fromJson(resp.data);
      await saveAuth(auth);
      return auth;
    }
    throw Exception('Register failed: ${resp.statusCode}');
  }
}
