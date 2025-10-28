import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
    await vendorService.updateOrderStatus(id, status);
    await load();
  }
}

final ordersControllerProvider =
    StateNotifierProvider<OrdersController, AsyncValue<List<OrderItem>>>((ref) {
      return OrdersController(ref);
    });
