import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import 'secure_storage_service.dart';

class SessionStore extends ChangeNotifier {
  SessionStore(this._storageService);

  final SecureStorageService _storageService;

  AuthSession? _session;
  bool _initialized = false;

  AuthSession? get session => _session;
  bool get initialized => _initialized;
  bool get isAuthenticated => _session != null;

  Future<void> initialize() async {
    _session = await _storageService.readSession();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setSession(AuthSession session) async {
    _session = session;
    _initialized = true;
    await _storageService.saveSession(session);
    notifyListeners();
  }

  Future<void> clearSession() async {
    _session = null;
    _initialized = true;
    await _storageService.clearSession();
    notifyListeners();
  }
}
