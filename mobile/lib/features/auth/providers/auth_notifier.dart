import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/auth_session.dart';
import '../../../shared/network/api_client.dart';
import '../../../shared/services/session_store.dart';
import '../data/auth_api.dart';

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(
    authApi: ref.read(authApiProvider),
    sessionStore: ref.read(sessionStoreProvider),
  );
});

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({required AuthApi authApi, required SessionStore sessionStore})
    : _authApi = authApi,
      _sessionStore = sessionStore {
    _initialize();
  }

  final AuthApi _authApi;
  final SessionStore _sessionStore;

  bool _busy = false;
  String? _error;

  bool get isBusy => _busy;
  bool get isInitialized => _sessionStore.initialized;
  bool get isAuthenticated => _sessionStore.isAuthenticated;
  AuthSession? get session => _sessionStore.session;
  String? get error => _error;

  Future<void> _initialize() async {
    await _sessionStore.initialize();

    final current = _sessionStore.session;
    if (current != null) {
      try {
        await _authApi.me(accessToken: current.accessToken);
      } catch (_) {
        try {
          final refreshed = await _authApi.refresh(
            refreshToken: current.refreshToken,
          );
          await _sessionStore.setSession(refreshed);
        } catch (_) {
          await _sessionStore.clearSession();
        }
      }
    }

    notifyListeners();
  }

  Future<void> signUp({required String email, required String password}) async {
    await _run(() async {
      final session = await _authApi.signUp(email: email, password: password);
      await _sessionStore.setSession(session);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _run(() async {
      final session = await _authApi.signIn(email: email, password: password);
      await _sessionStore.setSession(session);
    });
  }

  Future<void> recoverPassword({required String email}) async {
    await _run(() async {
      await _authApi.resetPassword(email: email);
    });
  }

  Future<void> signOut() async {
    await _run(() async {
      final current = _sessionStore.session;
      if (current != null) {
        try {
          await _authApi.signOut(session: current);
        } catch (_) {
          // Session should still be cleared locally.
        }
      }
      await _sessionStore.clearSession();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } on DioException catch (error) {
      _error = _extractDioError(error);
    } catch (error) {
      _error = error.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  String _extractDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    final uri = error.requestOptions.uri;
    if (error.response == null) {
      return 'No se pudo conectar al backend (${uri.scheme}://${uri.host}:${uri.port}). '
          'Verifica que el API este encendida y que API_BASE_URL sea correcta.';
    }
    return 'No se pudo completar la operacion.';
  }
}
