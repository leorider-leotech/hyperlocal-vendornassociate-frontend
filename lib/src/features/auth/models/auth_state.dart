import '../../../models/vendor.dart';

enum AuthStatus { unknown, unauthenticated, otpRequested, onboarding, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isLoading = false,
    this.identifier = '',
    this.vendor,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isLoading;
  final String identifier;
  final Vendor? vendor;
  final String? errorMessage;

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);

  bool get needsOnboarding => status == AuthStatus.onboarding;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? identifier,
    Vendor? vendor,
    String? errorMessage,
    bool resetError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      identifier: identifier ?? this.identifier,
      vendor: vendor ?? this.vendor,
      errorMessage: resetError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
