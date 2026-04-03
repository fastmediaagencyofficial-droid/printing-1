import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class IndustriesScreen extends StatelessWidget {
  const IndustriesScreen({super.key});

  static const List<_Industry> _industries = [
    _Industry(
      slug: 'schools-education',
      name: 'Schools & Education',
      icon: Icons.school_rounded,
      color: Color(0xFF1565C0),
      desc: 'Notebooks, ID cards, certificates, prospectuses, and educational materials for institutions of all sizes.',
      products: ['Certificates', 'Notepads', 'Brochures', 'Banners', 'Calendars', 'Bill Books'],
    ),
    _Industry(
      slug: 'healthcare-medical',
      name: 'Healthcare & Medical',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFF2E7D32),
      desc: 'Medical brochures, labels, packaging, and compliance materials with strict quality standards.',
      products: ['Labels', 'Brochures', 'Packaging', 'Flyers', 'Prescription Pads', 'Posters'],
    ),
    _Industry(
      slug: 'restaurants-food',
      name: 'Restaurants & Food',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFE65100),
      desc: 'Menus, labels, takeout packaging, and food-safe materials for restaurants, cafes, and bakeries.',
      products: ['Food Packaging', 'Tissue Papers', 'Bags', 'Stickers', 'Menus', 'Posters'],
    ),
    _Industry(
      slug: 'retail-ecommerce',
      name: 'Retail & E-commerce',
      icon: Icons.storefront_rounded,
      color: Color(0xFF6A1B9A),
      desc: 'Product packaging, labels, shipping boxes, and branded materials for retail and online stores.',
      products: ['Custom Boxes', 'Labels', 'Shopping Bags', 'Flyers', 'Catalogs', 'Roll-Up Banners'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Industries'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Specialized solutions tailored to your industry\'s unique demands',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.mediumGrey,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...List.generate(
            _industries.length,
            (i) => _IndustryCard(industry: _industries[i], index: i),
          ),
        ],
      ),
    );
  }
}

class _IndustryCard extends StatelessWidget {
  const _IndustryCard({required this.industry, required this.index});
  final _Industry industry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/industries/${industry.slug}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: industry.color.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: industry.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(industry.icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          industry.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          industry.desc,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Products',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: industry.products.map((p) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: industry.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: industry.color.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: industry.color,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push(AppRoutes.quoteRequest),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            foregroundColor: industry.color,
                            side: BorderSide(color: industry.color),
                          ),
                          child: const Text('Get Quote', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/industries/${industry.slug}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: industry.color,
                            minimumSize: const Size(0, 40),
                          ),
                          child: const Text('Learn More', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn()
        .slideY(begin: 0.1);
  }
}

class _Industry {
  final String slug, name, desc;
  final IconData icon;
  final Color color;
  final List<String> products;
  const _Industry({
    required this.slug,
    required this.name,
    required this.icon,
    required this.color,
    required this.desc,
    required this.products,
  });
}

class IndustryDetailScreen extends StatelessWidget {
  final String industrySlug;
  const IndustryDetailScreen({super.key, required this.industrySlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          industrySlug
              .split('-')
              .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
              .join(' '),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () { try { context.pop(); } catch (_) { context.go('/industries'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.redDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.business_rounded, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text('How We Serve This Industry',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
              'We provide specialized printing and packaging solutions designed specifically for the unique needs and compliance requirements of this industry. Our experienced team understands your challenges and delivers results that meet the highest standards.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkGrey, height: 1.6),
            ),
            const SizedBox(height: 28),
            ElevatedButton(onPressed: () => context.push(AppRoutes.quoteRequest), child: const Text('Get Free Quote')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.push(AppRoutes.contact), child: const Text('Contact Our Team')),
          ],
        ),
      ),
    );
  }
}
