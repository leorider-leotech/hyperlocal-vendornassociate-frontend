import '../models/auth_tokens.dart';
import '../models/vendor.dart';
import 'api_service.dart';

class AuthService {
  AuthService(this._api);

  final ApiService _api;

  Future<void> login({required String identifier}) async {
    final payload = _identifierPayload(identifier);
    await _api.post<void>(
      '/auth/login',
      data: payload,
    );
  }

  Future<Vendor> verifyOtp({required String identifier, required String otp}) async {
    final payload = _identifierPayload(identifier)..['otp'] = otp;
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/verify',
      data: payload,
    );
    final data = response.data ?? <String, dynamic>{};
    final tokens = AuthTokens.fromJson(data);
    await _api.setTokens(tokens);
    return Vendor.fromJson(data['vendor'] as Map<String, dynamic>? ?? <String, dynamic>{});
  }

  Future<AuthTokens> refresh() async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {
        'refresh_token': _api.tokens?.refreshToken,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final tokens = AuthTokens.fromJson(data);
    await _api.setTokens(tokens);
    return tokens;
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<Vendor> fetchMe() async {
    final response = await _api.get<Map<String, dynamic>>('/vendors/me');
    return Vendor.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<Vendor> completeOnboarding(Map<String, dynamic> payload) async {
    final response = await _api.put<Map<String, dynamic>>('/vendors/me', data: payload);
    return Vendor.fromJson(response.data ?? <String, dynamic>{});
  }

  Map<String, dynamic> _identifierPayload(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.contains('@')) {
      return {'email': trimmed};
    }
    return {'phone': trimmed};
  }
}
