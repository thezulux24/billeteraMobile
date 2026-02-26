import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';

class SecureStorageService {
  SecureStorageService()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  static const _authSessionKey = 'auth_session';

  final FlutterSecureStorage _storage;

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _authSessionKey, value: session.toStorage());
  }

  Future<AuthSession?> readSession() async {
    final raw = await _storage.read(key: _authSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return AuthSession.fromStorage(raw);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _authSessionKey);
  }
}
