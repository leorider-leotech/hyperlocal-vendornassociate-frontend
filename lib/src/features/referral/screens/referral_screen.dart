import 'package:flutter/material.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Your Referral Code'),
            subtitle: const Text('Share this code with other vendors to earn extra subscription days.'),
            trailing: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Referral History'),
                subtitle: Text('You will see referrals accepted via the backend feed here.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
