import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final Map<String, String> _fallbackMemory = {};

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (_) {
      _fallbackMemory[_accessTokenKey] = accessToken;
      _fallbackMemory[_refreshTokenKey] = refreshToken;
    }
  }

  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return _fallbackMemory[_accessTokenKey];
    }
  }

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return _fallbackMemory[_refreshTokenKey];
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {
      _fallbackMemory.remove(_accessTokenKey);
      _fallbackMemory.remove(_refreshTokenKey);
    }
  }
}
