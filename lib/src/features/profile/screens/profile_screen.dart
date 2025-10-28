import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';

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
            title: Text(vendor?.name ?? 'Vendor'),
            subtitle: Text(vendor?.email ?? vendor?.phone ?? ''),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: const ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Business Address'),
            subtitle: Text('Update address information via Settings > Business Details'),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Bank Account'),
            subtitle: Text('**** **** **** 1234\nUPI: vendor@upi'),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ),
        ),
      ],
    );
  }
}
