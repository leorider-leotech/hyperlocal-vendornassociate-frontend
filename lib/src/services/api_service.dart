import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';

import '../models/auth_tokens.dart';
import 'secure_storage_service.dart';

class ApiService {
  ApiService({Dio? dio, SecureStorageService? storage})
      : _dio = dio ?? Dio(_createOptions()),
        _storage = storage ?? SecureStorageService() {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_tokens?.accessToken.isNotEmpty == true) {
            options.headers['Authorization'] = 'Bearer ${_tokens!.accessToken}';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_hasRetried(error.requestOptions)) {
            final refreshed = await _refreshTokens();
            if (refreshed) {
              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer ${_tokens!.accessToken}';
              requestOptions.extra['retried'] = true;
              final response = await _dio.fetch(requestOptions);
              return handler.resolve(response);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final SecureStorageService _storage;
  AuthTokens? _tokens;

  static BaseOptions _createOptions() {
    final baseUrl = dotenv.maybeGet('APP_BASE_URL')?.trim();
    return BaseOptions(
      baseUrl: baseUrl?.isNotEmpty == true ? baseUrl! : 'https://api.appydex.co',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    );
  }

  bool _hasRetried(RequestOptions options) => options.extra['retried'] == true;

  Future<void> loadStoredTokens() async {
    final access = await _storage.readAccessToken();
    final refresh = await _storage.readRefreshToken();
    if (access != null && refresh != null) {
      _tokens = AuthTokens(accessToken: access, refreshToken: refresh);
    }
  }

  AuthTokens? get tokens => _tokens;

  Future<void> setTokens(AuthTokens tokens) async {
    _tokens = tokens;
    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<void> clearTokens() async {
    _tokens = null;
    await _storage.clearTokens();
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = _tokens?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final retryOptions = RetryOptions(maxAttempts: 2);
    try {
      final response = await retryOptions.retry(
        () => Dio(_createOptions()).post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        ),
      );
      final data = response.data;
      if (data == null) return false;
      final tokens = AuthTokens.fromJson(data);
      await setTokens(tokens);
      return true;
    } on DioException {
      await clearTokens();
      return false;
    }
  }
}
