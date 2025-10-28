class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;

  AuthTokens copyWith({String? accessToken, String? refreshToken}) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }

  static const empty = AuthTokens(accessToken: '', refreshToken: '');
}
