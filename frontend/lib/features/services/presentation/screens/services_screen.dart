import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class _Service {
  final String slug;
  final String name;
  final IconData icon;
  final String desc;
  final Color color;
  const _Service({required this.slug, required this.name, required this.icon, required this.desc, required this.color});
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<_Service> _services = [
    _Service(slug: 'digital-printing', name: 'Digital Printing', icon: Icons.print_rounded, desc: 'Fast, flexible, high-quality for short runs and quick turnarounds', color: Color(0xFF1565C0)),
    _Service(slug: 'offset-printing', name: 'Offset Printing', icon: Icons.layers_rounded, desc: 'Large volume with consistent quality and cost-effectiveness', color: Color(0xFF6A1B9A)),
    _Service(slug: 'screen-printing', name: 'Screen Printing', icon: Icons.grid_on_rounded, desc: 'Bold designs on t-shirts, banners, and specialty items', color: Color(0xFF00695C)),
    _Service(slug: 'large-format-printing', name: 'Large Format Printing', icon: Icons.panorama_rounded, desc: 'Banners, billboards, and exhibition displays that make impact', color: Color(0xFFE65100)),
    _Service(slug: 'custom-boxes', name: 'Custom Boxes', icon: Icons.inventory_rounded, desc: 'Custom packaging boxes in any size, shape, and material', color: Color(0xFF4E342E)),
    _Service(slug: 'labels-stickers', name: 'Labels and Stickers', icon: Icons.label_rounded, desc: 'Any shape, size, or material for products and promotions', color: Color(0xFFAD1457)),
    _Service(slug: 'bags-pouches', name: 'Bags and Pouches', icon: Icons.shopping_bag_rounded, desc: 'Custom printed bags and pouches for retail and packaging', color: Color(0xFF558B2F)),
    _Service(slug: 'eco-friendly-packaging', name: 'Eco Friendly Packaging', icon: Icons.eco_rounded, desc: 'Sustainable, recyclable, FSC certified materials', color: Color(0xFF2E7D32)),
    _Service(slug: 'brand-identity', name: 'Brand Identity', icon: Icons.branding_watermark_rounded, desc: 'Complete visual identity packages for your brand', color: Color(0xFFC91A20)),
    _Service(slug: 'logo-design', name: 'Logo Design', icon: Icons.design_services_rounded, desc: 'Professional, memorable logo design for your business', color: Color(0xFF1565C0)),
    _Service(slug: 'packaging-design', name: 'Packaging Design', icon: Icons.inventory_2_rounded, desc: 'Eye-catching packaging designs that sell your product', color: Color(0xFF6A1B9A)),
    _Service(slug: 'marketing-materials', name: 'Marketing Materials', icon: Icons.campaign_rounded, desc: 'Brochures, flyers, catalogs, and promotional print materials', color: Color(0xFFE65100)),
    _Service(slug: 'business-printing', name: 'Business Printing', icon: Icons.business_center_rounded, desc: 'Cards, letterheads, envelopes, and stationery for your office', color: Color(0xFF00695C)),
    _Service(slug: 'promotional-products', name: 'Promotional Products', icon: Icons.card_giftcard_rounded, desc: 'Branded merchandise and giveaways for events and marketing', color: Color(0xFF4E342E)),
    _Service(slug: 'speciality-printing', name: 'Speciality Printing', icon: Icons.auto_awesome_rounded, desc: 'Wedding cards, certificates, calendars, and unique print items', color: Color(0xFFAD1457)),
    _Service(slug: 'flexography', name: 'Flexography', icon: Icons.view_module_rounded, desc: 'High-speed printing for flexible packaging and corrugated materials', color: Color(0xFF558B2F)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Our Services'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: AppColors.lightGrey,
            child: const Text(
              'Comprehensive printing & packaging solutions tailored for your business',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.mediumGrey, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _services.length,
              itemBuilder: (_, i) => _ServiceCard(service: _services[i], index: i),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.index});
  final _Service service;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/services/${service.slug}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(service.icon, color: service.color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.black),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service.desc,
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}

// Service Detail Screen
class ServiceDetailScreen extends StatelessWidget {
  final String serviceSlug;
  const ServiceDetailScreen({super.key, required this.serviceSlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(serviceSlug.replaceAll('-', ' ').split(' ').map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.redDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.print_rounded, size: 80, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Service Overview',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'We provide comprehensive, high-quality solutions tailored to your specific needs. Our team of experts uses state-of-the-art technology to deliver exceptional results that elevate your brand.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkGrey, height: 1.6),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...[
              'Premium quality guaranteed',
              'Fast turnaround times',
              'Free design consultation',
              'Competitive pricing',
              'Nationwide delivery',
            ].map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.redSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, size: 14, color: AppColors.primaryRed),
                  ),
                  const SizedBox(width: 12),
                  Text(f, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkGrey)),
                ],
              ),
            )),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.quoteRequest),
              child: const Text('Request a Quote'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.contact),
              child: const Text('Contact Us'),
            ),
          ],
        ),
      ),
    );
  }
}
