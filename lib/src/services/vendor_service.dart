import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../core/api_service.dart';
import '../models/lead.dart';
import '../models/order.dart';
import '../models/service.dart';
import '../models/vendor.dart';

class VendorService {
  VendorService(this._api);

  final ApiService _api;

  Future<List<ServiceItem>> fetchServices({String? search, String? status}) async {
    final response = await _api.get<List<dynamic>>(
      '/vendors/services',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = response.data ?? [];
    return data
        .map((item) => ServiceItem.fromJson(Map<String, dynamic>.from(item as Map)))
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

  Future<String?> uploadServiceImage({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final mediaType = mimeType != null ? MediaType.parse(mimeType) : null;
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/uploads/presign',
        data: {
          'file_name': fileName,
          if (mimeType != null) 'mime_type': mimeType,
        },
      );
      final data = response.data;
      if (data != null && data['upload_url'] != null) {
        final uploadUrl = data['upload_url'] as String;
        final fields = Map<String, dynamic>.from(data['fields'] as Map? ?? {});
        final formData = FormData();
        fields.forEach((key, value) => formData.fields.add(MapEntry(key, value.toString())));
        formData.files.add(
          MapEntry(
            'file',
            MultipartFile.fromBytes(bytes, filename: fileName, contentType: mediaType),
          ),
        );
        final dio = Dio();
        await dio.post(uploadUrl, data: formData, options: Options(contentType: 'multipart/form-data'));
        return data['public_url'] as String? ?? data['file_url'] as String? ?? data['url'] as String?;
      }
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != null && status >= 400 && status != 404) {
        rethrow;
      }
    }

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName, contentType: mediaType),
    });
    final uploadResponse = await _api.post<Map<String, dynamic>>(
      '/uploads',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final uploadData = uploadResponse.data;
    return uploadData?['url'] as String? ??
        uploadData?['image_url'] as String? ??
        uploadData?['file_url'] as String?;
  }

  Future<List<LeadItem>> fetchLeads({String status = 'new'}) async {
    final response = await _api.get<List<dynamic>>(
      '/vendors/leads',
      queryParameters: {'status': status},
    );
    final data = response.data ?? [];
    return data
        .map((item) => LeadItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> updateLeadStatus(String id, String status) async {
    await _api.put<void>(
      '/vendors/leads/$id/status',
      data: {'status': status},
    );
  }

  Future<List<OrderItem>> fetchOrders({String? status}) async {
    final response = await _api.get<List<dynamic>>(
      '/vendors/orders',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final data = response.data ?? [];
    return data
        .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _api.put<void>(
      '/vendors/orders/$id/status',
      data: {'status': status},
    );
  }

  Future<Map<String, dynamic>> fetchSubscription() async {
    final response = await _api.get<Map<String, dynamic>>('/vendors/subscription');
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> createPaymentSession({
    required String gateway,
    required int amount,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/payments/create',
      data: {
        'gateway': gateway,
        'amount': amount,
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String paymentId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/payments/verify',
      data: {
        'payment_id': paymentId,
        'payload': payload,
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> fetchReferrals() async {
    final response = await _api.get<Map<String, dynamic>>('/vendors/referrals');
    return response.data ?? <String, dynamic>{};
  }

  Future<void> applyReferral(String code) async {
    await _api.post<void>(
      '/vendors/referrals/apply',
      data: {'code': code},
    );
  }

  Future<Vendor> updateVendorProfile(Map<String, dynamic> payload) async {
    final response = await _api.put<Map<String, dynamic>>('/vendors/me', data: payload);
    return Vendor.fromJson(response.data ?? <String, dynamic>{});
  }
}
