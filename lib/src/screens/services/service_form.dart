import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/services/controllers/services_controller.dart';
import '../../models/service.dart';
import '../../providers/service_providers.dart';
import '../../widgets/service_card.dart';
import '../../utils/validators.dart';

class ServiceForm extends ConsumerStatefulWidget {
  const ServiceForm({super.key, this.initial});

  final ServiceItem? initial;

  @override
  ConsumerState<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends ConsumerState<ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  String _status = 'draft';
  Uint8List? _imageBytes;
  String? _imageUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nameController.text = initial.name;
      _categoryController.text = initial.category;
      _priceController.text = initial.price.toStringAsFixed(2);
      _status = initial.status;
      _imageUrl = initial.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewService = ServiceItem(
      id: widget.initial?.id ?? '',
      name: _nameController.text,
      category: _categoryController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      status: _status,
      imageUrl: _imageUrl,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.initial == null ? 'Create Service' : 'Edit Service',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Service name'),
              validator: Validators.requiredField,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: Validators.requiredField,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (INR)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'draft', child: Text('Draft')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              ],
              onChanged: (value) => setState(() => _status = value ?? 'draft'),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload image'),
              ),
            ),
            if (_imageBytes != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _imageBytes!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (_imageUrl?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ServiceCard(
                  service: previewService,
                  onTap: null,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          await _submit(context);
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.initial == null ? 'Create' : 'Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> _submit(BuildContext context) async {
    setState(() => _isSubmitting = true);
    try {
      final controller = ref.read(servicesControllerProvider.notifier);
      final vendorService = ref.read(vendorServiceProvider);
      String? imageUrl = _imageUrl;
      if (_imageBytes != null) {
        imageUrl = await vendorService.uploadServiceImage(
          bytes: _imageBytes!,
          fileName: '${_nameController.text.trim()}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          mimeType: 'image/jpeg',
        );
      }
      final draft = ServiceItem(
        id: widget.initial?.id ?? '',
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        status: _status,
        imageUrl: imageUrl,
      );
      final result = widget.initial == null
          ? await controller.create(draft)
          : await controller.update(widget.initial!.id, draft);
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save service: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
