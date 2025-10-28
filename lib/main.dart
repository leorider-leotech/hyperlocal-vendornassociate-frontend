import 'dart:async';

import 'package:flutter/material.dart';

import 'src/core/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
}
