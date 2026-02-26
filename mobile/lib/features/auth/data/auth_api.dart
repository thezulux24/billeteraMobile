import 'package:dio/dio.dart';

import '../../../shared/models/auth_session.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthSession> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/sign-up',
      data: {'email': email, 'password': password},
      options: Options(extra: {'skipAuth': true}),
    );
    return AuthSession.fromApi(response.data ?? <String, dynamic>{});
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/sign-in',
      data: {'email': email, 'password': password},
      options: Options(extra: {'skipAuth': true}),
    );
    return AuthSession.fromApi(response.data ?? <String, dynamic>{});
  }

  Future<AuthSession> refresh({required String refreshToken}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );
    return AuthSession.fromApi(response.data ?? <String, dynamic>{});
  }

  Future<void> signOut({required AuthSession session}) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/sign-out',
      data: {'refresh_token': session.refreshToken},
      options: Options(
        extra: {'skipAuth': true},
        headers: {'Authorization': 'Bearer ${session.accessToken}'},
      ),
    );
  }

  Future<void> resetPassword({required String email}) async {
    await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/reset-password',
      data: {'email': email},
      options: Options(extra: {'skipAuth': true}),
    );
  }

  Future<void> me({required String accessToken}) async {
    await _dio.get<Map<String, dynamic>>(
      '/api/v1/auth/me',
      options: Options(
        extra: {'skipAuth': true},
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
  }
}
