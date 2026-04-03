import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroBanner(),
                _StatsRow(),
                _SectionHeader(
                  title: AppStrings.featuredServices,
                  onViewAll: () => context.go(AppRoutes.services),
                ),
                _ServicesGrid(),
                _SectionHeader(
                  title: AppStrings.featuredProducts,
                  onViewAll: () => context.go(AppRoutes.products),
                ),
                _ProductsHorizontalList(),
                _WhyChooseUsSection(),
                _SectionHeader(
                  title: AppStrings.ourIndustries,
                  onViewAll: () => context.go(AppRoutes.industries),
                ),
                _IndustriesGrid(),
                _HowItWorksSection(),
                _TestimonialsSection(),
                _CTASection(context: context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: AppColors.white,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.print_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            'Fast Printing',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.black),
          onPressed: () => context.go(AppRoutes.notifications),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.black),
          onPressed: () => context.go(AppRoutes.cart),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── HERO BANNER ─────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.black, AppColors.charcoal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryRed.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🔥 Pakistan\'s Fastest',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Premium Quality\nPrinting & Packaging',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.quoteRequest),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: AppColors.redShadow,
                        ),
                        child: const Text(
                          'Get Free Quote',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.products),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'View Products',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2);
  }
}

// ─── STATS ROW ───────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(value: '1000+', label: 'Happy Clients', icon: Icons.people_rounded),
          SizedBox(width: 10),
          _StatCard(value: '5 ⭐', label: 'Star Rated', icon: Icons.star_rounded),
          SizedBox(width: 10),
          _StatCard(value: '2020', label: 'Est. Since', icon: Icons.verified_rounded),
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn()
        .slideY(begin: 0.3);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryRed, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});
  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View All →',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SERVICES GRID ───────────────────────────────────────────────────────────
class _ServicesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> _featuredServices = const [
    {'name': 'Digital Printing', 'icon': Icons.print_rounded, 'slug': 'digital-printing'},
    {'name': 'Custom Boxes', 'icon': Icons.inventory_rounded, 'slug': 'custom-boxes'},
    {'name': 'Logo Design', 'icon': Icons.design_services_rounded, 'slug': 'logo-design'},
    {'name': 'Large Format', 'icon': Icons.panorama_rounded, 'slug': 'large-format-printing'},
    {'name': 'Eco Packaging', 'icon': Icons.eco_rounded, 'slug': 'eco-friendly-packaging'},
    {'name': 'Offset Printing', 'icon': Icons.layers_rounded, 'slug': 'offset-printing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _featuredServices.length,
        itemBuilder: (context, index) {
          final service = _featuredServices[index];
          return GestureDetector(
            onTap: () => context.push('/services/${service['slug']}'),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGrey),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.redSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      color: AppColors.primaryRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['name'] as String,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: index * 80))
              .fadeIn()
              .scale(begin: const Offset(0.9, 0.9));
        },
      ),
    );
  }
}

// ─── PRODUCTS HORIZONTAL LIST ────────────────────────────────────────────────
class _ProductsHorizontalList extends StatelessWidget {
  final List<Map<String, dynamic>> _products = const [
    {'name': 'Business Cards', 'price': 'From PKR 1,500', 'category': 'Business Printing'},
    {'name': 'Roll-Up Banners', 'price': 'From PKR 3,500', 'category': 'Large Format'},
    {'name': 'Custom Boxes', 'price': 'Custom Quote', 'category': 'Packaging'},
    {'name': 'Wedding Cards', 'price': 'From PKR 5,000', 'category': 'Speciality'},
    {'name': 'Stickers', 'price': 'From PKR 800', 'category': 'Labels'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primaryRed,
                      size: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product['price'] as String,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: index * 80))
              .fadeIn()
              .slideX(begin: 0.2);
        },
      ),
    );
  }
}

// ─── WHY CHOOSE US ───────────────────────────────────────────────────────────
class _WhyChooseUsSection extends StatelessWidget {
  final List<Map<String, dynamic>> _features = const [
    {'icon': Icons.bolt_rounded, 'title': 'Lightning Fast', 'desc': '24-48h turnaround'},
    {'icon': Icons.verified_rounded, 'title': 'Premium Quality', 'desc': '100% guaranteed'},
    {'icon': Icons.eco_rounded, 'title': 'Eco Friendly', 'desc': 'FSC certified materials'},
    {'icon': Icons.support_agent_rounded, 'title': '24/7 Support', 'desc': 'Always here for you'},
    {'icon': Icons.local_shipping_rounded, 'title': 'Nationwide', 'desc': 'Delivery across Pakistan'},
    {'icon': Icons.design_services_rounded, 'title': 'Free Design', 'desc': 'Expert consultation'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.black, AppColors.charcoal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose XFast Group?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: AppColors.primaryRed,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature['desc'] as String,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: AppColors.softGrey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── INDUSTRIES GRID ─────────────────────────────────────────────────────────
class _IndustriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> _industries = const [
    {
      'name': 'Schools &\nEducation',
      'icon': Icons.school_rounded,
      'slug': 'schools-education',
      'color': Color(0xFF1565C0),
    },
    {
      'name': 'Healthcare &\nMedical',
      'icon': Icons.local_hospital_rounded,
      'slug': 'healthcare-medical',
      'color': Color(0xFF2E7D32),
    },
    {
      'name': 'Restaurants\n& Food',
      'icon': Icons.restaurant_rounded,
      'slug': 'restaurants-food',
      'color': Color(0xFFE65100),
    },
    {
      'name': 'Retail &\nE-commerce',
      'icon': Icons.storefront_rounded,
      'slug': 'retail-ecommerce',
      'color': Color(0xFF6A1B9A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _industries.length,
        itemBuilder: (context, index) {
          final industry = _industries[index];
          return GestureDetector(
            onTap: () => context.push('/industries/${industry['slug']}'),
            child: Container(
              decoration: BoxDecoration(
                color: (industry['color'] as Color).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (industry['color'] as Color).withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: industry['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      industry['icon'] as IconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      industry['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn()
              .scale(begin: const Offset(0.95, 0.95));
        },
      ),
    );
  }
}

// ─── HOW IT WORKS ─────────────────────────────────────────────────────────────
class _HowItWorksSection extends StatelessWidget {
  final List<Map<String, String>> _steps = const [
    {'num': '01', 'title': 'Consultation', 'desc': 'Share your vision with our experts'},
    {'num': '02', 'title': 'Design & Approval', 'desc': 'Review digital mockups'},
    {'num': '03', 'title': 'Production', 'desc': 'Premium quality printing'},
    {'num': '04', 'title': 'Quality Check', 'desc': 'Every detail inspected'},
    {'num': '05', 'title': 'Delivery', 'desc': 'Fast, secure nationwide shipping'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'How It Works',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (index) {
            final step = _steps[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        step['num']!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          step['desc']!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < _steps.length - 1)
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.softGrey),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── TESTIMONIALS ─────────────────────────────────────────────────────────────
class _TestimonialsSection extends StatelessWidget {
  final List<Map<String, String>> _testimonials = const [
    {
      'name': 'Ahmed Hassan',
      'role': 'Owner, Sunrise Restaurants',
      'review': 'Fast Printing transformed our restaurant branding. The custom menus and packaging are exceptional quality!',
      'initials': 'AH',
    },
    {
      'name': 'Dr. Fatima Khan',
      'role': 'Medical Director, MediCare Clinic',
      'review': 'We needed compliant medical labels urgently. Fast Printing delivered beyond expectations — perfect quality!',
      'initials': 'FK',
    },
    {
      'name': 'Sarah Malik',
      'role': 'Principal, BrightMinds School',
      'review': 'Working with Fast Printing for school materials has been wonderful. Bulk pricing and quality are unbeatable.',
      'initials': 'SM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Row(
            children: [
              SizedBox(
                width: 4, height: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.primaryRed),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'What Our Clients Say',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final t = _testimonials[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGrey),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppColors.primaryRed, size: 22),
                        const Spacer(),
                        Row(
                          children: List.generate(
                            5,
                            (_) => const Icon(Icons.star_rounded,
                                color: Color(0xFFFFB300), size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        t['review']!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.darkGrey,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryRed,
                          child: Text(
                            t['initials']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['name']!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              Text(
                                t['role']!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: AppColors.mediumGrey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── CTA SECTION ─────────────────────────────────────────────────────────────
class _CTASection extends StatelessWidget {
  const _CTASection({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.redDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.redShadow,
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Make Your\nBrand Unforgettable?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Get a free quote in 24 hours. No commitment required.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.quoteRequest),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primaryRed,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Get Your Free Quote Now',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.contact),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: Colors.white54),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.phone_rounded, size: 18),
            label: const Text(
              'Call: 0325 2467463',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
