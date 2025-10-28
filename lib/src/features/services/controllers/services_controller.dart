import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> refresh() async {
    try {
      final vendorService = _ref.read(vendorServiceProvider);
      final services = await vendorService.fetchServices();
      state = AsyncValue.data(services);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<ServiceItem> create(ServiceItem draft) async {
    final vendorService = _ref.read(vendorServiceProvider);
    final created = await vendorService.createService(draft);
    state = state.whenData((services) => [...services, created]);
    return created;
  }

  Future<ServiceItem> update(String id, ServiceItem draft) async {
    final vendorService = _ref.read(vendorServiceProvider);
    final updated = await vendorService.updateService(id, draft);
    state = state.whenData((services) {
      return services.map((service) => service.id == id ? updated : service).toList();
    });
    return updated;
  }

  Future<void> remove(String id) async {
    final vendorService = _ref.read(vendorServiceProvider);
    await vendorService.deleteService(id);
    state = state.whenData((services) => services.where((service) => service.id != id).toList());
  }
}

final servicesControllerProvider =
    StateNotifierProvider<ServicesController, AsyncValue<List<ServiceItem>>>((ref) {
  return ServicesController(ref);
});
