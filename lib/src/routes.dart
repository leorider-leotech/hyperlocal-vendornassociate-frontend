import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
import 'features/dashboard/screens/dashboard_shell.dart';
import 'screens/splash_screen.dart';
import 'utils/go_router_refresh.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterRefresh(
    ref.read(authControllerProvider.notifier).stream,
  );
  ref.onDispose(refresh.dispose);
  ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final loggingIn = state.matchedLocation == '/login';
      final verifyingOtp = state.matchedLocation == '/otp';
      if (status == AuthStatus.unknown) {
        return state.matchedLocation == '/' ? null : '/';
      }
      if (status == AuthStatus.unauthenticated) {
        return loggingIn ? null : '/login';
      }
      if (status == AuthStatus.otpRequested) {
        return verifyingOtp ? null : '/otp';
      }
      if (status == AuthStatus.authenticated) {
        if (state.matchedLocation.startsWith('/dashboard')) {
          return null;
        }
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardShell(),
      ),
    ],
  );
});
