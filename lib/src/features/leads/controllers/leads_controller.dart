import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../models/lead.dart';
import '../../../providers/service_providers.dart';

class LeadsState {
  const LeadsState({required this.status, required this.leads});

  final String status;
  final AsyncValue<List<LeadItem>> leads;

  LeadsState copyWith({String? status, AsyncValue<List<LeadItem>>? leads}) {
    return LeadsState(
      status: status ?? this.status,
      leads: leads ?? this.leads,
    );
  }
}

class LeadsController extends StateNotifier<LeadsState> {
  LeadsController(this._ref)
    : super(LeadsState(status: 'new', leads: const AsyncValue.loading())) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = state.copyWith(leads: const AsyncValue.loading());
    try {
      final vendorService = _ref.read(vendorServiceProvider);
      final leads = await vendorService.fetchLeads(status: state.status);
      state = state.copyWith(leads: AsyncValue.data(leads));
    } catch (error, stackTrace) {
      state = state.copyWith(leads: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> changeStatus(String status) async {
    state = state.copyWith(status: status);
    await load();
  }

  Future<void> updateLead(String id, String status) async {
    final vendorService = _ref.read(vendorServiceProvider);
    await vendorService.updateLeadStatus(id, status);
    await load();
  }
}

final leadsControllerProvider =
    StateNotifierProvider<LeadsController, LeadsState>(
      (ref) => LeadsController(ref),
    );
