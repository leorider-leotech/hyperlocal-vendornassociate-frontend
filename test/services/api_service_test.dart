import 'package:appydex_vendor/src/core/api_service.dart';
import 'package:appydex_vendor/src/core/secure_storage.dart';
import 'package:appydex_vendor/src/models/auth_tokens.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

class _MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  test('adds Authorization header when tokens are present', () async {
    final storage = _MockSecureStorage();
    when(() => storage.readAccessToken()).thenAnswer((_) async => null);
    when(() => storage.readRefreshToken()).thenAnswer((_) async => null);
    when(() => storage.saveTokens(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async {});
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
    final adapter = _MockHttpClientAdapter();
    dio.httpClientAdapter = adapter;
    final service = ApiService(dio: dio, storage: storage);
    await service.setTokens(const AuthTokens(accessToken: 'token', refreshToken: 'refresh'));

    when(() => adapter.fetch(any(), any(), any())).thenAnswer((invocation) async {
      final options = invocation.positionalArguments[0] as RequestOptions;
      expect(options.headers['Authorization'], 'Bearer token');
      return ResponseBody.fromString('"ok"', 200, headers: {
        Headers.contentTypeHeader: ['application/json'],
      });
    });

    final response = await service.get<String>('/ping');
    expect(response.statusCode, 200);
  });
}
