import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../features/bank_accounts/data/bank_account_api.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/cash_wallets/data/cash_wallet_api.dart';
import '../../features/profile/data/profile_api.dart';
import '../services/secure_storage_service.dart';
import '../services/session_store.dart';
import 'auth_interceptor.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore(ref.read(secureStorageProvider));
});

final publicDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(publicDioProvider));
});

final privateDioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      sessionStore: ref.read(sessionStoreProvider),
      authApi: ref.read(authApiProvider),
      privateDio: dio,
    ),
  );

  return dio;
});

final profileApiProvider = Provider<ProfileApi>((ref) {
  return ProfileApi(ref.watch(privateDioProvider));
});

final cashWalletApiProvider = Provider<CashWalletApi>((ref) {
  return CashWalletApi(ref.watch(privateDioProvider));
});

final bankAccountApiProvider = Provider<BankAccountApi>((ref) {
  return BankAccountApi(ref.watch(privateDioProvider));
});
