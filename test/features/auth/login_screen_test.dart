import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appydex_vendor/src/features/auth/controllers/auth_controller.dart';
import 'package:appydex_vendor/src/features/auth/models/auth_state.dart';
import 'package:appydex_vendor/src/screens/auth/login.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(Ref ref)
      : super(ref) {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String? lastIdentifier;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> login(String identifier) async {
    lastIdentifier = identifier;
    state = state.copyWith(status: AuthStatus.otpRequested, identifier: identifier, isLoading: false);
  }
}

void main() {
  testWidgets('sends OTP when form is valid', (tester) async {
    late _FakeAuthController controller;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) {
            controller = _FakeAuthController(ref);
            return controller;
          }),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'vendor@example.com');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    expect(controller.lastIdentifier, 'vendor@example.com');
  });
}
