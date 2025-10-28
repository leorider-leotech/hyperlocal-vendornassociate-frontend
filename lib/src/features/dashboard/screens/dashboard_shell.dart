import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../services/screens/services_screen.dart';
import '../../leads/screens/leads_screen.dart';
import '../../orders/screens/orders_screen.dart';
import '../../subscription/screens/subscription_screen.dart';
import '../../referral/screens/referral_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'overview_screen.dart';

class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  int _index = 0;

  late final List<_DashboardTab> _tabs = [
    _DashboardTab('Overview', Icons.dashboard_outlined, const OverviewScreen()),
    _DashboardTab('Services', Icons.inventory_2_outlined, const ServicesScreen()),
    _DashboardTab('Leads', Icons.support_agent_outlined, const LeadsScreen()),
    _DashboardTab('Orders', Icons.assignment_outlined, const OrdersScreen()),
    _DashboardTab('Subscription', Icons.workspace_premium_outlined, const SubscriptionScreen()),
    _DashboardTab('Referrals', Icons.card_giftcard_outlined, const ReferralScreen()),
    _DashboardTab('Profile', Icons.person_outline, const ProfileScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabs[_index].label),
        actions: [
          if (authState.vendor != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text(authState.vendor!.name),
              ),
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _tabs[_index].child,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: _tabs
            .map((tab) => NavigationDestination(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ))
            .toList(),
      ),
    );
  }
}

class _DashboardTab {
  const _DashboardTab(this.label, this.icon, this.child);

  final String label;
  final IconData icon;
  final Widget child;
}
