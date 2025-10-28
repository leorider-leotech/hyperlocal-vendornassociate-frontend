import 'subscription.dart';
import 'vendor_stats.dart';

class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subscription,
    required this.stats,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final Subscription? subscription;
  final VendorStats? stats;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] != null
          ? VendorStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  Vendor copyWith({
    Subscription? subscription,
    VendorStats? stats,
  }) {
    return Vendor(
      id: id,
      name: name,
      email: email,
      phone: phone,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
    );
  }
}
