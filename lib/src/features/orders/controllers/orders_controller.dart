import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline_queue.dart';
import '../../../models/order.dart';
import '../../../providers/service_providers.dart';

class OrdersController extends StateNotifier<AsyncValue<List<OrderItem>>> {
  OrdersController(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final vendorService = _ref.read(vendorServiceProvider);
      final orders = await vendorService.fetchOrders();
      state = AsyncValue.data(orders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateOrder(String id, String status) async {
    final vendorService = _ref.read(vendorServiceProvider);
    final queue = _ref.read(offlineQueueProvider);
    try {
      await vendorService.updateOrderStatus(id, status);
      await load();
    } catch (error, stackTrace) {
      if (_shouldQueue(error)) {
        await queue.enqueue(OfflineAction.orderStatus(orderId: id, status: status));
        state = state.whenData((orders) {
          return orders.map((order) => order.id == id ? order.copyWith(status: status) : order).toList();
        });
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  bool _shouldQueue(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          (error.response?.statusCode != null && error.response!.statusCode! >= 500);
    }
    return false;
  }
}

final ordersControllerProvider =
    StateNotifierProvider<OrdersController, AsyncValue<List<OrderItem>>>((ref) {
  return OrdersController(ref);
});
