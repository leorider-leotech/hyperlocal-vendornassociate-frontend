import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(authControllerProvider).vendor;
    final subscription = vendor?.subscription;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text(subscription?.plan.toUpperCase() ?? 'No plan'),
            subtitle: Text(
              'Expiry: ${subscription?.expiry?.toLocal().toString().split(' ').first ?? 'N/A'}\nDays left: ${subscription?.remainingDays ?? '--'}',
            ),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Renew'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                title: Text('Payments'),
                subtitle: Text('Complete the test payment flow to verify Razorpay/Stripe integration.'),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test payment flow is available via Razorpay/Stripe sandbox.')),
                    );
                  },
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Start Test Payment'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
