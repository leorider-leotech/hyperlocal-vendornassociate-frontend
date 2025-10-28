import '../models/lead.dart';
import '../models/order.dart';
import '../models/service.dart';
import 'api_service.dart';

class VendorService {
  VendorService(this._api);

  final ApiService _api;

  Future<List<ServiceItem>> fetchServices() async {
    final response = await _api.get<List<dynamic>>('/vendors/services');
    final data = response.data ?? [];
    return data
        .map(
          (item) =>
              ServiceItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<ServiceItem> createService(ServiceItem service) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/vendors/services',
      data: service.toJson(),
    );
    return ServiceItem.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<ServiceItem> updateService(String id, ServiceItem service) async {
    final response = await _api.put<Map<String, dynamic>>(
      '/vendors/services/$id',
      data: service.toJson(),
    );
    return ServiceItem.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteService(String id) async {
    await _api.delete<void>('/vendors/services/$id');
  }

  Future<List<LeadItem>> fetchLeads({String status = 'new'}) async {
    final response = await _api.get<List<dynamic>>(
      '/vendors/leads',
      queryParameters: {'status': status},
    );
    final data = response.data ?? [];
    return data
        .map(
          (item) => LeadItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> updateLeadStatus(String id, String status) async {
    await _api.put<void>('/vendors/leads/$id/status', data: {'status': status});
  }

  Future<List<OrderItem>> fetchOrders() async {
    final response = await _api.get<List<dynamic>>('/vendors/orders');
    final data = response.data ?? [];
    return data
        .map(
          (item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _api.put<void>(
      '/vendors/orders/$id/status',
      data: {'status': status},
    );
  }
}
