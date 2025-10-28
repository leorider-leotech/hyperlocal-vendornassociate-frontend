import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../services/vendor_service.dart';
import 'constants.dart';

enum OfflineActionType { leadStatus, orderStatus }

class OfflineAction {
  OfflineAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  factory OfflineAction.leadStatus({required String leadId, required String status}) {
    return OfflineAction(
      id: const Uuid().v4(),
      type: OfflineActionType.leadStatus,
      payload: {'lead_id': leadId, 'status': status},
      createdAt: DateTime.now(),
    );
  }

  factory OfflineAction.orderStatus({required String orderId, required String status}) {
    return OfflineAction(
      id: const Uuid().v4(),
      type: OfflineActionType.orderStatus,
      payload: {'order_id': orderId, 'status': status},
      createdAt: DateTime.now(),
    );
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'] as String,
      type: OfflineActionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => OfflineActionType.leadStatus,
      ),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };
}

class OfflineQueueService {
  OfflineQueueService(this._vendorService, {Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final VendorService _vendorService;
  final Connectivity _connectivity;
  SharedPreferences? _prefs;
  StreamSubscription<ConnectivityResult>? _subscription;
  final List<OfflineAction> _actions = [];
  bool _processing = false;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromStorage();
    _subscription = _connectivity.onConnectivityChanged.listen((_) => processPending());
    await processPending();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> enqueue(OfflineAction action) async {
    _actions.add(action);
    await _persist();
    await processPending();
  }

  Future<void> processPending() async {
    if (_processing || _actions.isEmpty) {
      return;
    }
    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return;
    }
    _processing = true;
    try {
      while (_actions.isNotEmpty) {
        final action = _actions.first;
        try {
          await _perform(action);
          _actions.removeAt(0);
          await _persist();
        } catch (error) {
          if (_isRecoverable(error)) {
            break;
          }
          _actions.removeAt(0);
          await _persist();
        }
      }
    } finally {
      _processing = false;
    }
  }

  bool _isRecoverable(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
      final status = error.response?.statusCode;
      if (status != null && status >= 500) {
        return true;
      }
    }
    return false;
  }

  Future<void> _perform(OfflineAction action) {
    switch (action.type) {
      case OfflineActionType.leadStatus:
        return _vendorService.updateLeadStatus(
          action.payload['lead_id'] as String,
          action.payload['status'] as String,
        );
      case OfflineActionType.orderStatus:
        return _vendorService.updateOrderStatus(
          action.payload['order_id'] as String,
          action.payload['status'] as String,
        );
    }
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final jsonList = _actions.map((action) => jsonEncode(action.toJson())).toList();
    await prefs.setStringList(AppConstants.offlineQueueStorageKey, jsonList);
  }

  void _loadFromStorage() {
    final prefs = _prefs;
    if (prefs == null) return;
    final stored = prefs.getStringList(AppConstants.offlineQueueStorageKey) ?? [];
    _actions
      ..clear()
      ..addAll(stored.map((item) => OfflineAction.fromJson(jsonDecode(item) as Map<String, dynamic>)));
  }
}
