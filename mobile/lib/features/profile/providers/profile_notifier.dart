import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/network/api_client.dart';
import '../data/profile_api.dart';
import '../models/profile.dart';

final profileNotifierProvider = ChangeNotifierProvider<ProfileNotifier>((ref) {
  return ProfileNotifier(profileApi: ref.read(profileApiProvider));
});

class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier({required ProfileApi profileApi}) : _profileApi = profileApi;

  final ProfileApi _profileApi;

  Profile? _profile;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileApi.getProfile();
    } on DioException catch (error) {
      _error = _extractError(error);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> save({
    required String baseCurrency,
    required bool aiEnabled,
  }) async {
    _saving = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _profileApi.patchProfile(
        baseCurrency: baseCurrency,
        aiEnabled: aiEnabled,
      );
    } on DioException catch (error) {
      _error = _extractError(error);
    } catch (error) {
      _error = error.toString();
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  String _extractError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (error.response == null) {
      final uri = error.requestOptions.uri;
      return 'No se pudo conectar al backend (${uri.scheme}://${uri.host}:${uri.port}).';
    }
    return 'No se pudo cargar el perfil.';
  }
}
