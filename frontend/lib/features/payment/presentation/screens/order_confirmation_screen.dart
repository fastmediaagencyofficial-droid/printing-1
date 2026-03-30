import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  const OrderConfirmationScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, size: 64, color: Color(0xFF2E7D32)),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 28),
              const Text('Order Placed!', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.black)).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 10),
              Text('Order ID: $orderId', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryRed)).animate(delay: 400.ms).fadeIn(),
              const SizedBox(height: 12),
              const Text(
                'Your payment proof has been submitted. Our team will verify your payment within 1-2 hours and begin production.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.mediumGrey, height: 1.6),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn(),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primaryRed, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('You\'ll receive a push notification once your payment is confirmed.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.darkGrey, height: 1.4))),
                ]),
              ).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () => context.go(AppRoutes.orders), child: const Text('Track Your Order')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Back to Home')),
            ],
          ),
        ),
      ),
    );
  }
}
