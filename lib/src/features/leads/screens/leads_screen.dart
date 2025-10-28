import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/leads_controller.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leadsControllerProvider);
    final controller = ref.read(leadsControllerProvider.notifier);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'new', label: Text('New')),
              ButtonSegment(value: 'in-progress', label: Text('In Progress')),
              ButtonSegment(value: 'closed', label: Text('Closed')),
            ],
            selected: {state.status},
            onSelectionChanged: (value) => controller.changeStatus(value.first),
          ),
        ),
        Expanded(
          child: state.leads.when(
            data: (leads) {
              if (leads.isEmpty) {
                return const Center(child: Text('No leads in this bucket.'));
              }
              final format = DateFormat('dd MMM, hh:mm a');
              return ListView.builder(
                itemCount: leads.length,
                itemBuilder: (context, index) {
                  final lead = leads[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(lead.customerName),
                      subtitle: Text(
                        '${lead.message}\n${lead.createdAt != null ? format.format(lead.createdAt!) : ''}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) => controller.updateLead(lead.id, value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'accepted', child: Text('Accept')),
                          PopupMenuItem(value: 'rejected', child: Text('Reject')),
                          PopupMenuItem(value: 'quoted', child: Text('Send Quote')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load leads', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(error.toString()),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
