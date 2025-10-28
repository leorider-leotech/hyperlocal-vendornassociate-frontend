import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/services/controllers/services_controller.dart';
import '../../models/service.dart';
import '../../widgets/service_card.dart';
import 'service_form.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesControllerProvider);
    return Stack(
      children: [
        Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search services',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _statusFilter,
                  onChanged: (value) => setState(() => _statusFilter = value ?? 'all'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              data: (services) {
                final filtered = _filteredServices(services);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No services found. Create your first service.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final service = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ServiceCard(
                        service: service,
                        onEdit: () => _openForm(context, service: service),
                        onDelete: () => _confirmDelete(service),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                message: error.toString(),
                onRetry: () => ref.read(servicesControllerProvider.notifier).load(),
              ),
            ),
          ),
        ],
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('New service'),
            ),
          ),
        ),
      ],
    );
  }

  List<ServiceItem> _filteredServices(List<ServiceItem> services) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredByStatus = _statusFilter == 'all'
        ? services
        : services.where((service) => service.status == _statusFilter).toList();
    if (query.isEmpty) {
      return filteredByStatus;
    }
    return filteredByStatus
        .where((service) =>
            service.name.toLowerCase().contains(query) || service.category.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _openForm(BuildContext context, {ServiceItem? service}) async {
    final result = await showModalBottomSheet<ServiceItem?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ServiceForm(initial: service),
        );
      },
    );
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service ${service == null ? 'created' : 'updated'} successfully')),
      );
    }
  }

  Future<void> _confirmDelete(ServiceItem service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service'),
        content: Text('Are you sure you want to delete ${service.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final controller = ref.read(servicesControllerProvider.notifier);
      await controller.remove(service.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${service.name}')),
        );
      }
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Failed to load services', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
