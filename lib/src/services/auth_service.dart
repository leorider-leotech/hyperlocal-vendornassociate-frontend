import '../models/auth_tokens.dart';
import '../models/vendor.dart';
import 'api_service.dart';

class AuthService {
  AuthService(this._api);

  final ApiService _api;

  Future<void> requestOtp({required String phone}) async {
    await _api.post<void>(
      '/auth/login',
      data: {'phone': phone},
    );
  }

  Future<Vendor> verifyOtp({required String phone, required String otp}) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/verify',
      data: {
        'phone': phone,
        'otp': otp,
      },
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
}
