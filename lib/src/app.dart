import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'routes.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Appydex Vendor',
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: theme.mode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
