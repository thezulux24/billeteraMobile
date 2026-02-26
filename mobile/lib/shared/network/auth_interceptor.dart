import 'package:dio/dio.dart';

import '../../features/auth/data/auth_api.dart';
import '../services/session_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionStore sessionStore,
    required AuthApi authApi,
    required Dio privateDio,
  }) : _sessionStore = sessionStore,
       _authApi = authApi,
       _privateDio = privateDio;

  final SessionStore _sessionStore;
  final AuthApi _authApi;
  final Dio _privateDio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldSkip(options)) {
      handler.next(options);
      return;
    }

    final accessToken = _sessionStore.session?.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final shouldRetry =
        err.response?.statusCode == 401 && !_shouldSkip(options);
    final alreadyRetried = options.extra['retried'] == true;

    if (!shouldRetry || alreadyRetried) {
      handler.next(err);
      return;
    }

    final session = _sessionStore.session;
    if (session == null) {
      handler.next(err);
      return;
    }

    try {
      final refreshed = await _authApi.refresh(
        refreshToken: session.refreshToken,
      );
      await _sessionStore.setSession(refreshed);

      final retryOptions = options.copyWith(
        headers: Map<String, dynamic>.from(options.headers)
          ..['Authorization'] = 'Bearer ${refreshed.accessToken}',
        extra: Map<String, dynamic>.from(options.extra)..['retried'] = true,
      );

      final response = await _privateDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _sessionStore.clearSession();
      handler.next(err);
    }
  }

  bool _shouldSkip(RequestOptions options) {
    final path = options.path;
    final skipByExtra = options.extra['skipAuth'] == true;
    return skipByExtra ||
        path.contains('/auth/sign-in') ||
        path.contains('/auth/sign-up') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/reset-password');
  }
}
