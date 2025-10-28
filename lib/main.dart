import 'package:flutter/material.dart';

void main() {
  runApp(const VendorApp());
}

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyperlocal Vendor Console',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1865F2),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        useMaterial3: true,
      ),
      home: const VendorDashboard(),
    );
  }
}

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int _selectedIndex = 0;

  final List<_NavigationDestination> _destinations = const [
    _NavigationDestination(
      icon: Icons.dashboard_outlined,
      label: 'Overview',
      view: OverviewPage(),
    ),
    _NavigationDestination(
      icon: Icons.shopping_bag_outlined,
      label: 'Orders',
      view: OrdersPage(),
    ),
    _NavigationDestination(
      icon: Icons.inventory_2_outlined,
      label: 'Inventory',
      view: InventoryPage(),
    ),
    _NavigationDestination(
      icon: Icons.support_agent_outlined,
      label: 'Support',
      view: SupportPage(),
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.label),
        actions: const [_NotificationButton(), _HelpButton()],
      ),
      drawer: _VendorDrawer(
        destinations: _destinations,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      floatingActionButton:
          _selectedIndex == 2
              ? FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('New Product'),
              )
              : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Row(
            children: [
              if (isWide)
                NavigationRail(
                  extended: constraints.maxWidth >= 1200,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(.12),
                      child: const Icon(Icons.storefront_outlined),
                    ),
                  ),
                  destinations:
                      _destinations
                          .map(
                            (destination) => NavigationRailDestination(
                              icon: Icon(destination.icon),
                              label: Text(destination.label),
                            ),
                          )
                          .toList(),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: destination.view,
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          MediaQuery.of(context).size.width < 900
              ? NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onDestinationSelected,
                destinations:
                    _destinations
                        .map(
                          (destination) => NavigationDestination(
                            icon: Icon(destination.icon),
                            label: destination.label,
                          ),
                        )
                        .toList(),
              )
              : null,
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const metrics = [
    _MetricCardData(
      title: 'Today\'s Revenue',
      value: '₹42,300',
      change: '+12% vs yesterday',
      icon: Icons.currency_rupee,
      color: Color(0xFF0C8CE9),
    ),
    _MetricCardData(
      title: 'Active Orders',
      value: '18',
      change: '5 awaiting confirmation',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFF6D39FF),
    ),
    _MetricCardData(
      title: 'Delivery SLA',
      value: '92%',
      change: 'within 30 mins',
      icon: Icons.timer_outlined,
      color: Color(0xFF22B07D),
    ),
  ];

  static final List<_FulfilmentSlot> fulfilmentSlots = [
    _FulfilmentSlot('08:00 - 10:00', 24, 30),
    _FulfilmentSlot('10:00 - 12:00', 18, 25),
    _FulfilmentSlot('12:00 - 14:00', 12, 20),
    _FulfilmentSlot('14:00 - 16:00', 7, 15),
  ];

  static final List<_Insights> insights = [
    _Insights(
      title: 'Push new combos for evening rush',
      description:
          'Fruits & dairy combos sell 34% better between 6-9 pm in your micro-market.',
    ),
    _Insights(
      title: 'Reorder top-rated products',
      description:
          'Bananas, paneer and whole wheat bread are trending with 4.8★ customer rating.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children:
                metrics.map((metric) => _MetricCard(metric: metric)).toList(),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fulfilment Slots',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...fulfilmentSlots.map(
                              (slot) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: _CapacityProgress(slot: slot),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24, height: 24),
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actionable Insights',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...insights.map(
                              (insight) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.12),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  insight.title,
                                  style: theme.textTheme.titleMedium,
                                ),
                                subtitle: Text(insight.description),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static final List<_Order> _orders = [
    _Order(
      '#HGX-1021',
      '12 Sep · 08:45 am',
      'Ready for dispatch',
      524.80,
      Icons.check_circle,
      Color(0xFF22B07D),
    ),
    _Order(
      '#HGX-1018',
      '12 Sep · 08:12 am',
      'Packing · ETA 12 mins',
      316.45,
      Icons.local_shipping_outlined,
      Color(0xFF0C8CE9),
    ),
    _Order(
      '#HGX-1012',
      '12 Sep · 07:55 am',
      'Awaiting rider',
      742.10,
      Icons.pending_actions_outlined,
      Color(0xFFF59E0B),
    ),
    _Order(
      '#HGX-1009',
      '12 Sep · 07:42 am',
      'Delivered · 4.9★ feedback',
      279.30,
      Icons.star_rate_rounded,
      Color(0xFF6D39FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('orders'),
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: const [
            _OrderFilterChip(label: 'All Orders', selected: true),
            _OrderFilterChip(label: 'Priority'),
            _OrderFilterChip(label: 'Delayed'),
            _OrderFilterChip(label: 'Refunds'),
          ],
        ),
        const SizedBox(height: 16),
        ..._orders.map((order) => _OrderCard(order: order)),
      ],
    );
  }
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  static final List<_InventoryItem> _inventory = [
    _InventoryItem('Bananas (1kg)', 'Produce', 120, 24, true),
    _InventoryItem('Amul Paneer (200g)', 'Dairy', 58, 12, true),
    _InventoryItem('Whole Wheat Bread', 'Bakery', 34, 8, false),
    _InventoryItem('Organic Eggs (6pcs)', 'Dairy', 48, 6, true),
    _InventoryItem('Almond Milk (1L)', 'Beverages', 26, 4, false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: const ValueKey('inventory'),
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Coverage',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('In Stock')),
                  DataColumn(label: Text('Sold today')),
                  DataColumn(label: Text('Auto-replenish')),
                ],
                rows:
                    _inventory
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item.name)),
                              DataCell(Text(item.category)),
                              DataCell(Text(item.inStock.toString())),
                              DataCell(Text(item.todaySales.toString())),
                              DataCell(
                                Chip(
                                  label: Text(
                                    item.autoReplenish ? 'Enabled' : 'Paused',
                                  ),
                                  backgroundColor:
                                      item.autoReplenish
                                          ? theme.colorScheme.primary
                                              .withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.15),
                                  labelStyle: TextStyle(
                                    color:
                                        item.autoReplenish
                                            ? theme.colorScheme.primary
                                            : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      key: const ValueKey('support'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need help? We\'re here 24/7',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our city success team can help with onboarding, operations or resolving delivery issues.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _SupportActionChip(
                        icon: Icons.headset_mic_outlined,
                        label: 'Call city manager',
                      ),
                      _SupportActionChip(
                        icon: Icons.chat_bubble_outline,
                        label: 'Chat with ops',
                      ),
                      _SupportActionChip(
                        icon: Icons.sticky_note_2_outlined,
                        label: 'Raise a ticket',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Checklist',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _ChecklistTile(
                    title: 'Fresh stock synced with central warehouse',
                    completed: true,
                  ),
                  const _ChecklistTile(
                    title: 'Last-mile delivery riders assigned for lunch peak',
                    completed: true,
                  ),
                  const _ChecklistTile(
                    title: 'Critical SKUs pinned for auto restock alerts',
                    completed: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.icon,
    required this.label,
    required this.view,
  });

  final IconData icon;
  final String label;
  final Widget view;
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
}

class _FulfilmentSlot {
  const _FulfilmentSlot(this.label, this.currentCapacity, this.maxCapacity);

  final String label;
  final int currentCapacity;
  final int maxCapacity;

  double get progress => currentCapacity / maxCapacity;
}

class _Insights {
  const _Insights({required this.title, required this.description});

  final String title;
  final String description;
}

class _Order {
  const _Order(
    this.id,
    this.time,
    this.status,
    this.amount,
    this.icon,
    this.color,
  );

  final String id;
  final String time;
  final String status;
  final double amount;
  final IconData icon;
  final Color color;
}

class _InventoryItem {
  const _InventoryItem(
    this.name,
    this.category,
    this.inStock,
    this.todaySales,
    this.autoReplenish,
  );

  final String name;
  final String category;
  final int inStock;
  final int todaySales;
  final bool autoReplenish;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _MetricCardData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: metric.color.withOpacity(0.1),
                child: Icon(metric.icon, color: metric.color),
              ),
              const SizedBox(height: 16),
              Text(
                metric.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                metric.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: metric.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(metric.change, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityProgress extends StatelessWidget {
  const _CapacityProgress({required this.slot});

  final _FulfilmentSlot slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slot.label, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: slot.progress.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text('${slot.currentCapacity}/${slot.maxCapacity}'),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: order.color.withOpacity(0.12),
              child: Icon(order.icon, color: order.color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.id,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${order.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(order.status, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    order.time,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new),
              label: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderFilterChip extends StatelessWidget {
  const _OrderFilterChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      selectedColor: theme.colorScheme.primary.withOpacity(0.15),
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}

class _SupportActionChip extends StatelessWidget {
  const _SupportActionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(icon, color: theme.colorScheme.primary),
      label: Text(label),
      onPressed: () {},
      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.title, required this.completed});

  final String title;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        completed ? Icons.check_circle : Icons.radio_button_unchecked,
        color: completed ? theme.colorScheme.primary : Colors.grey,
      ),
      title: Text(title),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Alerts',
      onPressed: () {},
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Quick help',
      onPressed: () {},
      icon: const Icon(Icons.help_outline),
    );
  }
}

class _VendorDrawer extends StatelessWidget {
  const _VendorDrawer({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<_NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.85),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.store_mall_directory_outlined,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'FreshMart Express',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'HSR Layout · Bengaluru',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(destinations.length, (index) {
              final destination = destinations[index];
              final selected = index == selectedIndex;

              return ListTile(
                leading: Icon(
                  destination.icon,
                  color:
                      selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(destination.label),
                selected: selected,
                onTap: () {
                  Navigator.pop(context);
                  onDestinationSelected(index);
                },
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
