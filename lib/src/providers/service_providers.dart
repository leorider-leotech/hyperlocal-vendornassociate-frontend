import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_service.dart';
import '../core/auth_service.dart';
import '../core/offline_queue.dart';
import '../core/notification_service.dart';
import '../core/secure_storage.dart';
import '../services/vendor_service.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
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

final offlineQueueProvider = Provider<OfflineQueueService>((ref) {
  final vendorService = ref.watch(vendorServiceProvider);
  final queue = OfflineQueueService(vendorService);
  Future.microtask(queue.initialize);
  ref.onDispose(queue.dispose);
  return queue;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  Future.microtask(service.initialize);
  ref.onDispose(service.dispose);
  return service;
});
