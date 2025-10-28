import '../../../models/vendor.dart';

enum AuthStatus { unknown, unauthenticated, otpRequested, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isLoading = false,
    this.phone = '',
    this.vendor,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isLoading;
  final String phone;
  final Vendor? vendor;
  final String? errorMessage;

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? phone,
    Vendor? vendor,
    String? errorMessage,
    bool resetError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      phone: phone ?? this.phone,
      vendor: vendor ?? this.vendor,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
