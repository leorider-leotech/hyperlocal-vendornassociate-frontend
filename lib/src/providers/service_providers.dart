import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';
import '../services/vendor_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final api = ApiService(storage: storage);
  Future.microtask(api.loadStoredTokens);
  return api;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthService(api);
});

final vendorServiceProvider = Provider<VendorService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return VendorService(api);
});
