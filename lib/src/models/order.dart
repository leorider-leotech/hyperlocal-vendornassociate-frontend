class OrderItem {
  const OrderItem({
    required this.id,
    required this.status,
    required this.total,
    required this.customerName,
    required this.updatedAt,
  });

  final String id;
  final String status;
  final double total;
  final String customerName;
  final DateTime? updatedAt;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] is num) ? (json['total'] as num).toDouble() : 0,
      customerName: json['customer_name'] as String? ?? json['customerName'] as String? ?? 'Customer',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : (json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null),
    );
  }

  OrderItem copyWith({String? status}) {
    return OrderItem(
      id: id,
      status: status ?? this.status,
      total: total,
      customerName: customerName,
      updatedAt: updatedAt,
    );
  }
}
