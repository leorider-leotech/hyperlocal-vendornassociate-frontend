class VendorStats {
  const VendorStats({
    required this.todayLeads,
    required this.openOrders,
    required this.balance,
  });

  final int todayLeads;
  final int openOrders;
  final double balance;

  factory VendorStats.fromJson(Map<String, dynamic> json) {
    return VendorStats(
      todayLeads: (json['today_leads'] ?? json['todayLeads'] ?? 0) as int,
      openOrders: (json['open_orders'] ?? json['openOrders'] ?? 0) as int,
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : 0,
    );
  }
}
