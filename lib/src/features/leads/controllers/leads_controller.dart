import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline_queue.dart';
import '../../../models/lead.dart';
import '../../../providers/service_providers.dart';

class LeadsState {
  const LeadsState({
    required this.status,
    required this.leads,
  });

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
    final queue = _ref.read(offlineQueueProvider);
    try {
      await vendorService.updateLeadStatus(id, status);
      await load();
    } catch (error, stackTrace) {
      if (_shouldQueue(error)) {
        await queue.enqueue(OfflineAction.leadStatus(leadId: id, status: status));
        state = state.copyWith(
          leads: state.leads.whenData((leads) {
            return leads
                .map((lead) => lead.id == id ? lead.copyWith(status: status) : lead)
                .toList();
          }),
        );
      } else {
        state = state.copyWith(leads: AsyncValue.error(error, stackTrace));
      }
    }
  }

  bool _shouldQueue(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          (error.response?.statusCode != null && error.response!.statusCode! >= 500);
    }
    return false;
  }
}

final leadsControllerProvider =
    StateNotifierProvider<LeadsController, LeadsState>((ref) => LeadsController(ref));
