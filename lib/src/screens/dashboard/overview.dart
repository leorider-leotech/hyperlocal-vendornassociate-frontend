import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../widgets/kpi_card.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final vendor = authState.vendor;
    final stats = vendor?.stats;
    final currency = NumberFormat.simpleCurrency(name: 'INR');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            KpiCard(
              title: "Today's Leads",
              value: stats?.todayLeads.toString() ?? '--',
              icon: Icons.mark_email_unread_outlined,
            ),
            KpiCard(
              title: 'Open Orders',
              value: stats?.openOrders.toString() ?? '--',
              icon: Icons.assignment_outlined,
            ),
            KpiCard(
              title: 'Balance',
              value: stats != null ? currency.format(stats.balance) : '--',
              icon: Icons.currency_rupee_outlined,
            ),
            KpiCard(
              title: 'Subscription Days Left',
              value: vendor?.subscription?.remainingDays.toString() ?? '--',
              icon: Icons.workspace_premium_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _QuickAction(label: 'Accept Latest Lead', icon: Icons.thumb_up_alt_outlined),
            _QuickAction(label: 'Create New Service', icon: Icons.add_box_outlined),
            _QuickAction(label: 'Renew Subscription', icon: Icons.autorenew),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actionable Insights', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.trending_up),
                  title: Text('Increase your conversion rate by responding within 5 minutes.'),
                ),
                const ListTile(
                  leading: Icon(Icons.auto_graph_outlined),
                  title: Text('Add professional images to boost service visibility.'),
                ),
                const ListTile(
                  leading: Icon(Icons.security),
                  title: Text('Verify bank details to enable instant payouts.'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 20),
      label: Text(label),
      onPressed: () {},
    );
  }
}
