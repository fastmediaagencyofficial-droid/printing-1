import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  static const _items = [
    {'title': 'Luxury Cosmetic Packaging', 'cat': 'Packaging'},
    {'title': 'Restaurant Brand Identity', 'cat': 'Branding'},
    {'title': 'E-commerce Shipping Boxes', 'cat': 'Packaging'},
    {'title': 'Tech Startup Branding', 'cat': 'Branding'},
    {'title': 'School Prospectus', 'cat': 'Marketing'},
    {'title': 'Food Product Labels', 'cat': 'Design'},
    {'title': 'Corporate Branding Package', 'cat': 'Branding'},
    {'title': 'Retail Display Packaging', 'cat': 'Packaging'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Our Portfolio'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () { try { context.pop(); } catch (_) { context.go('/'); } }),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: _items.length,
        itemBuilder: (_, i) {
          final item = _items[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: const Center(child: Icon(Icons.image_rounded, size: 48, color: AppColors.primaryRed)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['title']!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(item['cat']!, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.primaryRed)),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
