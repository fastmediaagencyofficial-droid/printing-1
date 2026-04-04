import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/service_bloc.dart';
import '../../data/models/service_model.dart';

String _fixImageUrl(String url) =>
    url.replaceFirst('http://localhost:', 'http://10.0.2.2:');

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: AppColors.lightGrey,
            child: const Text(
              'Comprehensive printing & packaging solutions tailored for your business',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.mediumGrey,
                  height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServicesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryRed),
                  );
                }
                if (state is ServiceError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.mediumGrey),
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: const TextStyle(
                                fontFamily: 'Inter', color: AppColors.mediumGrey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ServiceBloc>().add(LoadServicesEvent()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ServicesLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.services.length,
                    itemBuilder: (_, i) =>
                        _ServiceCard(service: state.services[i], index: i),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.index});
  final ServiceModel service;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/services/${service.slug}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Image or icon
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                    ? Image.network(
                        _fixImageUrl(service.imageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _IconPlaceholder(),
                      )
                    : _IconPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.shortDescription,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16),
              ),
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

class _IconPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.redSurface,
      child: const Center(
        child: Icon(Icons.print_rounded, color: AppColors.primaryRed, size: 32),
      ),
    );
  }
}

// ── Service Detail Screen ──────────────────────────────────────────────────────

class ServiceDetailScreen extends StatefulWidget {
  final String serviceSlug;
  const ServiceDetailScreen({super.key, required this.serviceSlug});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ServiceBloc>().add(LoadServiceDetailEvent(widget.serviceSlug));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            try { context.pop(); } catch (_) { context.go('/services'); }
          },
        ),
      ),
      body: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          if (state is ServicesLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed));
          }
          if (state is ServiceError) {
            return Center(child: Text(state.message));
          }
          if (state is ServiceDetailLoaded) {
            return _ServiceDetailBody(service: state.service);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _ServiceDetailBody extends StatelessWidget {
  const _ServiceDetailBody({required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                  ? Image.network(
                      _fixImageUrl(service.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _HeroPlaceholder(),
                    )
                  : _HeroPlaceholder(),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            service.name,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.darkGrey,
                height: 1.6),
          ),

          if (service.features.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Key Features',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...service.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.redSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 14, color: AppColors.primaryRed),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(f,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: AppColors.darkGrey)),
                      ),
                    ],
                  ),
                )),
          ],

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
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryRed, AppColors.redDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.print_rounded, size: 80, color: Colors.white),
      ),
    );
  }
}
