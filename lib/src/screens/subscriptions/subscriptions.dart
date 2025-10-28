import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../providers/service_providers.dart';

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
              onPressed: () => _handleRenew(context),
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
                  onPressed: () => _startPayment(context, ref),
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Start Test Payment'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.loyalty_outlined),
            title: const Text('Referral Benefits'),
            subtitle: Text('Referral days earned: ${vendor?.referralDays ?? 0}\nCode: ${vendor?.referralCode ?? 'Generate via Support'}'),
          ),
        ),
      ],
    );
  }

  void _handleRenew(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Renewal flow coming soon. Contact support to upgrade your plan.')),
    );
  }

  Future<void> _startPayment(BuildContext context, WidgetRef ref) async {
    final isFakePay = (dotenv.maybeGet(EnvKeys.fakePayment) ?? 'true').toLowerCase() == 'true';
    if (isFakePay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulated payment successful.')),
      );
      return;
    }
    final vendorService = ref.read(vendorServiceProvider);
    try {
      final session = await vendorService.createPaymentSession(gateway: 'razorpay', amount: 49900);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment session created: ${session['id'] ?? session}')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start payment: $error')),
      );
    }
  }
}
