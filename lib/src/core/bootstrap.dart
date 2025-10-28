import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../app.dart';
import '../providers/app_providers.dart';

Future<void> bootstrap() async {
  await _loadEnv();
  final container = ProviderContainer(overrides: globalProviderOverrides);
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
  };

  final dsn = dotenv.maybeGet('SENTRY_DSN');
  Future<void> runWithContainer() async {
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const App(),
      ),
    );
  }

  if (dsn != null && dsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 0.1;
        options.enableAutoSessionTracking = true;
      },
      appRunner: runWithContainer,
    );
  } else {
    await runWithContainer();
  }
}

Future<void> _loadEnv() async {
  try {
    await dotenv.load();
  } catch (_) {
    await dotenv.load(fileName: '.env.example');
  }
}
