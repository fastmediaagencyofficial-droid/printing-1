import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({super.key});
  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String _selectedProduct = 'Business Cards';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Request a Quote'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () { try { context.pop(); } catch (_) { context.go('/'); } }),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.redSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.redBorder)),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryRed, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('Get a free detailed quote within 24 hours. No commitment required.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.darkGrey))),
                ]),
              ),
              const SizedBox(height: 20),
              TextFormField(decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline_rounded)),
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 14),
              TextFormField(decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 14),
              TextFormField(decoration: const InputDecoration(labelText: 'Phone *', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedProduct,
                decoration: const InputDecoration(labelText: 'Product / Service *', prefixIcon: Icon(Icons.inventory_2_outlined)),
                items: AppStrings.productNames.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setState(() => _selectedProduct = v ?? ''),
              ),
              const SizedBox(height: 14),
              TextFormField(decoration: const InputDecoration(labelText: 'Quantity *', prefixIcon: Icon(Icons.numbers_rounded)), keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 14),
              TextFormField(decoration: const InputDecoration(labelText: 'Size / Dimensions', prefixIcon: Icon(Icons.straighten_rounded))),
              const SizedBox(height: 14),
              TextFormField(decoration: const InputDecoration(labelText: 'Special Requirements', prefixIcon: Icon(Icons.notes_rounded), alignLabelWithHint: true), maxLines: 4),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSubmitting = true);
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() => _isSubmitting = false);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Quote request sent! We\'ll respond within 24 hours.'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  context.pop();
                },
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit Quote Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
