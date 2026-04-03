import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Top hero section
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.black, AppColors.charcoal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryRed.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -20,
                            left: -30,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryRed.withValues(alpha: 0.10),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Logo
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryRed,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: AppColors.redShadow,
                                  ),
                                  child: const Icon(
                                    Icons.print_rounded,
                                    color: AppColors.white,
                                    size: 36,
                                  ),
                                )
                                    .animate()
                                    .scale(duration: 600.ms, curve: Curves.elasticOut),

                                const SizedBox(height: 24),

                                const Text(
                                  AppStrings.appFullName,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                    height: 1.2,
                                  ),
                                )
                                    .animate(delay: 200.ms)
                                    .fadeIn()
                                    .slideX(begin: -0.2),

                                const SizedBox(height: 8),

                                const Text(
                                  AppStrings.appTagline,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.softGrey,
                                    height: 1.5,
                                  ),
                                )
                                    .animate(delay: 300.ms)
                                    .fadeIn()
                                    .slideX(begin: -0.2),

                                const SizedBox(height: 24),

                                // Stats row
                                const Row(
                                  children: [
                                    _StatChip(label: '1000+', sublabel: 'Clients'),
                                    SizedBox(width: 12),
                                    _StatChip(label: '5⭐', sublabel: 'Rated'),
                                    SizedBox(width: 12),
                                    _StatChip(label: 'Since', sublabel: '2020'),
                                  ],
                                )
                                    .animate(delay: 400.ms)
                                    .fadeIn()
                                    .slideY(begin: 0.3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom login section
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.welcomeBack,
                            style: Theme.of(context).textTheme.headlineMedium,
                          )
                              .animate(delay: 300.ms)
                              .fadeIn()
                              .slideY(begin: 0.3),

                          const SizedBox(height: 8),

                          Text(
                            AppStrings.signInToContinue,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                          )
                              .animate(delay: 400.ms)
                              .fadeIn(),

                          const SizedBox(height: 32),

                          // Google Sign-In Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return _GoogleSignInButton(
                                isLoading: isLoading,
                                onTap: isLoading
                                    ? null
                                    : () {
                                        context
                                            .read<AuthBloc>()
                                            .add(SignInWithGoogleEvent());
                                      },
                              );
                            },
                          )
                              .animate(delay: 500.ms)
                              .fadeIn()
                              .slideY(begin: 0.3),

                          const Spacer(),

                          // Terms text
                          const Text(
                            AppStrings.bySigningIn,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.softGrey,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          )
                              .animate(delay: 700.ms)
                              .fadeIn(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, this.onTap});
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey, width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryRed,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google G icon (simplified)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4285F4),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      AppStrings.signInWithGoogle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.sublabel});
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          Text(
            sublabel,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.softGrey,
            ),
          ),
        ],
      ),
    );
  }
}
