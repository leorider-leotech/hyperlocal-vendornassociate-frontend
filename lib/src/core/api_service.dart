import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';

import '../models/auth_tokens.dart';
import 'constants.dart';
import 'secure_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({Dio? dio, SecureStorage? storage})
      : _dio = dio ?? Dio(_createOptions()),
        _storage = storage ?? SecureStorage() {
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
          handler.next(_mapError(error));
        },
      ),
    );
  }

  final Dio _dio;
  final SecureStorage _storage;
  final RetryOptions _retryOptions = const RetryOptions(maxAttempts: 3);
  AuthTokens? _tokens;

  static BaseOptions _createOptions() {
    final baseUrl = dotenv.maybeGet(EnvKeys.appBaseUrl)?.trim();
    return BaseOptions(
      baseUrl: baseUrl?.isNotEmpty == true ? baseUrl! : AppConstants.fallbackBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status >= 200 && status < 500,
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
    return _send(() => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(() => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(() => _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _send(() => _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        ));
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = _tokens?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final retryOptions = const RetryOptions(maxAttempts: 2);
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

  Future<Response<T>> _send<T>(Future<Response<T>> Function() request) async {
    try {
      return await _retryOptions.retry(
        () async {
          final response = await request();
          if (response.statusCode != null && response.statusCode! >= 400) {
            throw DioException.badResponse(
              statusCode: response.statusCode!,
              requestOptions: response.requestOptions,
              response: response,
            );
          }
          return response;
        },
        retryIf: (error) =>
            error is DioException &&
            (error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.badCertificate ||
                error.type == DioExceptionType.connectionError),
      );
    } on DioException catch (error) {
      throw _mapError(error);
    } catch (error) {
      throw ApiException('Unexpected error occurred', cause: error);
    }
  }

  DioException _mapError(DioException error) {
    if (error.error is ApiException) {
      return error;
    }

    final status = error.response?.statusCode;
    final message = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        'Unable to connect. Check your internet connection and try again.',
      DioExceptionType.badCertificate => 'Secure connection failed. Verify device date & time.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.badResponse => _describeServerError(status, error.response?.data),
      DioExceptionType.unknown => 'Something went wrong. Please try again.',
    };

    error.error = ApiException(message, statusCode: status, cause: error);
    return error;
  }

  String _describeServerError(int? status, dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    if (status == 401) {
      return 'Session expired. Please login again.';
    }
    if (status == 403) {
      return 'You do not have permission to perform this action.';
    }
    if (status == 404) {
      return 'Resource not found. Please try again later.';
    }
    if (status != null && status >= 500) {
      return 'Server is unavailable right now. Please try after some time.';
    }
    return 'Request failed with status $status';
  }
}
