import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(authControllerProvider).vendor;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
            title: Text(vendor?.businessName?.isNotEmpty == true ? vendor!.businessName! : vendor?.name ?? 'Vendor'),
            subtitle: Text(vendor?.email?.isNotEmpty == true ? vendor!.email : vendor?.phone ?? ''),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Business Category'),
            subtitle: Text(vendor?.category ?? 'Not provided'),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Business Address'),
            subtitle: Text(vendor?.address ?? 'Add your address to improve trust signals'),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Bank Account'),
            subtitle: Text(vendor?.bankAccountMasked ?? 'Bank details pending verification'),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (vendor?.referralCode != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.card_giftcard_outlined),
              title: Text('Referral code: ${vendor?.referralCode}'),
              subtitle: Text('Bonus days remaining: ${vendor?.referralDays ?? 0}'),
            ),
          ),
      ],
    );
  }
}
