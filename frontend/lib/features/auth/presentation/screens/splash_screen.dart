import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Minimum 2.4 s to show brand animation
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.white, Color(0xFFFFF5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Center brand
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo box
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.redShadow,
                  ),
                  child: const Icon(Icons.print_rounded, color: Colors.white, size: 52),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                const Text(
                  'Fast Printing & Packaging',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 22,
                    fontWeight: FontWeight.w700, color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                const Text(
                  'Trusted Since 2020',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 14,
                    color: AppColors.mediumGrey,
                  ),
                ).animate(delay: 500.ms).fadeIn(),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.redSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Pakistan's Fastest Printing",
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12,
                      fontWeight: FontWeight.w500, color: AppColors.primaryRed,
                    ),
                  ),
                ).animate(delay: 700.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),

          // Bottom loader
          Positioned(
            bottom: 60, left: 0, right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: AppColors.borderGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'XFast Group',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w500, color: AppColors.softGrey,
                  ),
                ),
              ],
            ).animate(delay: 600.ms).fadeIn(),
          ),
        ],
      ),
    );
  }
}
