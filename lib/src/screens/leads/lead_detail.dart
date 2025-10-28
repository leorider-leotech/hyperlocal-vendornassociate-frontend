import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/leads/controllers/leads_controller.dart';
import '../../models/lead.dart';

class LeadDetailScreen extends ConsumerWidget {
  const LeadDetailScreen({super.key, required this.lead});

  final LeadItem lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = DateFormat('EEEE, dd MMM yyyy • hh:mm a');
    final createdAt = lead.createdAt != null ? format.format(lead.createdAt!) : 'Unknown';
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(lead.customerName, style: theme.textTheme.titleLarge),
            subtitle: const Text('Customer'),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Message', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    lead.message,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('Requested on', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(createdAt),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [
                      Chip(
                        label: Text(lead.status.toUpperCase()),
                        avatar: const Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Actions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.check_circle_outline,
            label: 'Accept lead',
            color: theme.colorScheme.primary,
            onPressed: () => _updateLead(context, ref, 'accepted'),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.attach_money,
            label: 'Send quote',
            color: theme.colorScheme.tertiary,
            onPressed: () => _updateLead(context, ref, 'quoted'),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.cancel_outlined,
            label: 'Reject lead',
            color: theme.colorScheme.error,
            onPressed: () => _updateLead(context, ref, 'rejected'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLead(BuildContext context, WidgetRef ref, String status) async {
    final controller = ref.read(leadsControllerProvider.notifier);
    await controller.updateLead(lead.id, status);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lead marked as $status')),
    );
    Navigator.of(context).pop(status);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
