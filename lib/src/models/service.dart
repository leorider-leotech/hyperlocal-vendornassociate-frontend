class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String status;
  final String? imageUrl;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      status: json['status'] as String? ?? 'draft',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'price': price,
        'status': status,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}
