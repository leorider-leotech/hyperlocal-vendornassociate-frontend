import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../models/service.dart';
import '../../../providers/service_providers.dart';

class ServicesController extends StateNotifier<AsyncValue<List<ServiceItem>>> {
  ServicesController(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final vendorService = _ref.read(vendorServiceProvider);
      final services = await vendorService.fetchServices();
      state = AsyncValue.data(services);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final servicesControllerProvider =
    StateNotifierProvider<ServicesController, AsyncValue<List<ServiceItem>>>((
      ref,
    ) {
      return ServicesController(ref);
    });
