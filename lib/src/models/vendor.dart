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
    this.businessName,
    this.category,
    this.address,
    this.referralCode,
    this.referralDays = 0,
    this.bankAccountMasked,
    this.documents,
    this.onboardingComplete = true,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final Subscription? subscription;
  final VendorStats? stats;
  final String? businessName;
  final String? category;
  final String? address;
  final String? referralCode;
  final int referralDays;
  final String? bankAccountMasked;
  final Map<String, dynamic>? documents;
  final bool onboardingComplete;

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
      businessName: json['business_name'] as String? ?? json['businessName'] as String?,
      category: json['category'] as String?,
      address: json['address'] as String?,
      referralCode: json['referral_code'] as String? ?? json['referralCode'] as String?,
      referralDays: (json['referral_days'] as num?)?.toInt() ?? (json['referralDays'] as num?)?.toInt() ?? 0,
      bankAccountMasked: json['bank_account_masked'] as String?,
      documents: (json['documents'] as Map<String, dynamic>?),
      onboardingComplete: json['onboarding_complete'] as bool? ?? true,
    );
  }

  Vendor copyWith({
    Subscription? subscription,
    VendorStats? stats,
    String? businessName,
    String? category,
    String? address,
    String? referralCode,
    int? referralDays,
    String? bankAccountMasked,
    Map<String, dynamic>? documents,
    bool? onboardingComplete,
  }) {
    return Vendor(
      id: id,
      name: name,
      email: email,
      phone: phone,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      address: address ?? this.address,
      referralCode: referralCode ?? this.referralCode,
      referralDays: referralDays ?? this.referralDays,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      documents: documents ?? this.documents,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
