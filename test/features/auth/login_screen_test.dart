import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:appydex_vendor/src/features/auth/controllers/auth_controller.dart';
import 'package:appydex_vendor/src/features/auth/models/auth_state.dart';
import 'package:appydex_vendor/src/features/auth/screens/login_screen.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(super.ref) {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String? lastPhone;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestOtp(String phone) async {
    lastPhone = phone;
    state = state.copyWith(
      status: AuthStatus.otpRequested,
      phone: phone,
      isLoading: false,
    );
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

    await tester.enterText(find.byType(TextFormField), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    expect(controller.lastPhone, '+919876543210');
  });
}
