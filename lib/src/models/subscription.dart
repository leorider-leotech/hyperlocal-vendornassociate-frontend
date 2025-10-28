class Subscription {
  const Subscription({
    required this.plan,
    required this.expiry,
    required this.remainingDays,
  });

  final String plan;
  final DateTime? expiry;
  final int remainingDays;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json['plan'] as String? ?? 'unknown',
      expiry: json['expiry'] != null ? DateTime.tryParse(json['expiry'] as String) : null,
      remainingDays: (json['remaining_days'] ?? json['remainingDays'] ?? 0) as int,
    );
  }
}
