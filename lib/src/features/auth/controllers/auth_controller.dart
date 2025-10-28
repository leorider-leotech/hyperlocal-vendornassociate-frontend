import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/auth_tokens.dart';
import '../../../providers/service_providers.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../models/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref)
      : super(AuthState.initial()) {
    Future.microtask(initialize);
  }

  final Ref _ref;

  AuthService get _authService => _ref.read(authServiceProvider);
  ApiService get _apiService => _ref.read(apiServiceProvider);

  Future<void> initialize() async {
    await _apiService.loadStoredTokens();
    final tokens = _apiService.tokens;
    if (tokens?.isValid == true) {
      await _restoreSession();
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, resetError: true);
    }
  }

  Future<void> requestOtp(String phone) async {
    state = state.copyWith(isLoading: true, resetError: true);
    try {
      await _authService.requestOtp(phone: phone);
      state = state.copyWith(
        status: AuthStatus.otpRequested,
        isLoading: false,
        phone: phone,
        resetError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _describeError(error),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, resetError: true);
    try {
      final vendor = await _authService.verifyOtp(phone: state.phone, otp: otp);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        vendor: vendor,
        isLoading: false,
        resetError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _describeError(error),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      vendor: null,
      phone: '',
      resetError: true,
    );
  }

  Future<void> _restoreSession() async {
    state = state.copyWith(isLoading: true, resetError: true);
    try {
      final vendor = await _authService.fetchMe();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        vendor: vendor,
        isLoading: false,
        resetError: true,
      );
    } catch (_) {
      await _apiService.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated, isLoading: false, resetError: true);
    }
  }

  Future<void> updateTokens(AuthTokens tokens) async {
    await _apiService.setTokens(tokens);
  }

  String _describeError(Object error) {
    if (error is Exception) {
      return error.toString();
    }
    return 'Something went wrong';
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
