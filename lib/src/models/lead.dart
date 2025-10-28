class LeadItem {
  const LeadItem({
    required this.id,
    required this.customerName,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String customerName;
  final String status;
  final String message;
  final DateTime? createdAt;

  factory LeadItem.fromJson(Map<String, dynamic> json) {
    return LeadItem(
      id: json['id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? json['customerName'] as String? ?? 'Customer',
      status: json['status'] as String? ?? 'new',
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null),
    );
  }
}
