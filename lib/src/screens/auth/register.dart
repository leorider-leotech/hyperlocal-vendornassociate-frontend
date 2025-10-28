import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _category = TextEditingController();
  final _address = TextEditingController();
  final _gstin = TextEditingController();
  final _pan = TextEditingController();
  bool _acceptTerms = true;

  @override
  void dispose() {
    _businessName.dispose();
    _category.dispose();
    _address.dispose();
    _gstin.dispose();
    _pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Onboarding')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tell us about your business',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _businessName,
                        decoration: const InputDecoration(labelText: 'Business name'),
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _address,
                        decoration: const InputDecoration(labelText: 'Business address'),
                        minLines: 2,
                        maxLines: 3,
                        validator: Validators.requiredField,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _gstin,
                        decoration: const InputDecoration(labelText: 'GSTIN (optional)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pan,
                        decoration: const InputDecoration(labelText: 'PAN (optional)'),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: _acceptTerms,
                        onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('I confirm the above details are accurate'),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() == true && _acceptTerms) {
                                    controller.completeOnboarding({
                                      'business_name': _businessName.text.trim(),
                                      'category': _category.text.trim(),
                                      'address': _address.text.trim(),
                                      if (_gstin.text.trim().isNotEmpty) 'gstin': _gstin.text.trim(),
                                      if (_pan.text.trim().isNotEmpty) 'pan': _pan.text.trim(),
                                    });
                                  }
                                },
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Complete setup'),
                        ),
                      ),
                      if (!_acceptTerms)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Accept the confirmation to proceed.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            state.errorMessage!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
