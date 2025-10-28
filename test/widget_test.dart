import 'package:appydex_vendor/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders splash screen initially', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
