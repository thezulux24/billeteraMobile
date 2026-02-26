import 'package:dio/dio.dart';

import '../models/profile.dart';

class ProfileApi {
  ProfileApi(this._dio);

  final Dio _dio;

  Future<Profile> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/profile');
    return Profile.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Profile> patchProfile({String? baseCurrency, bool? aiEnabled}) async {
    final payload = <String, dynamic>{};
    if (baseCurrency != null) {
      payload['base_currency'] = baseCurrency;
    }
    if (aiEnabled != null) {
      payload['ai_enabled'] = aiEnabled;
    }

    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/profile',
      data: payload,
    );
    return Profile.fromJson(response.data ?? <String, dynamic>{});
  }
}
