import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  static AppConfig fromEnvironment() {
    const raw = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (raw.isNotEmpty) {
      return AppConfig(apiBaseUrl: raw);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const AppConfig(apiBaseUrl: 'http://10.0.2.2:8000');
      case TargetPlatform.iOS:
        return const AppConfig(apiBaseUrl: 'http://localhost:8000');
      default:
        return const AppConfig(apiBaseUrl: 'http://localhost:8000');
    }
  }
}
