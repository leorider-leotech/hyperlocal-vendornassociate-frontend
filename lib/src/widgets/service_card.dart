import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final ServiceItem service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: _ServiceAvatar(imageUrl: service.imageUrl, name: service.name),
        title: Text(service.name),
        subtitle: Text('${service.category} • ₹${service.price.toStringAsFixed(2)}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(service.status.toUpperCase())),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit service',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete service',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceAvatar extends StatelessWidget {
  const _ServiceAvatar({required this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return CircleAvatar(
      child: Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?'),
    );
  }
}
