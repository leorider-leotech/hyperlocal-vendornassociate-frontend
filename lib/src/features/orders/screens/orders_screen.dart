import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/orders_controller.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersControllerProvider);
    final controller = ref.read(ordersControllerProvider.notifier);
    return state.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No orders yet.'));
        }
        final format = NumberFormat.simpleCurrency(name: 'INR');
        final dateFormat = DateFormat('dd MMM, hh:mm a');
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title: Text('Order #${order.id.substring(0, 6)}'),
                subtitle: Text(
                  '${order.customerName}\n${order.updatedAt != null ? dateFormat.format(order.updatedAt!) : ''}',
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(label: Text(order.status.toUpperCase())),
                    const SizedBox(height: 8),
                    Text(format.format(order.total)),
                    PopupMenuButton<String>(
                      onSelected:
                          (value) => controller.updateOrder(order.id, value),
                      itemBuilder:
                          (context) => const [
                            PopupMenuItem(
                              value: 'in_progress',
                              child: Text('Mark In Progress'),
                            ),
                            PopupMenuItem(
                              value: 'completed',
                              child: Text('Mark Completed'),
                            ),
                            PopupMenuItem(
                              value: 'cancelled',
                              child: Text('Cancel Order'),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load orders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: controller.load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
    );
  }
}
