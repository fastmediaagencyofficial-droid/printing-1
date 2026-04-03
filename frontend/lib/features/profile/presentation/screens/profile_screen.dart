import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('More'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Brand header ──────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.redShadow,
                  ),
                  child: const Icon(Icons.print_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fast Printing & Packaging',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Text(
                  'XFast Group — Lahore, Pakistan',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 13, color: AppColors.mediumGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Menu ────────────────────────────────────────────────────
          _Tile(icon: Icons.shopping_bag_rounded,    label: 'My Orders',        onTap: () => context.push(AppRoutes.orders)),
          _Tile(icon: Icons.favorite_rounded,        label: 'My Wishlist',      onTap: () => context.push(AppRoutes.wishlist)),
          _Tile(icon: Icons.request_quote_rounded,   label: 'Request a Quote',  onTap: () => context.push(AppRoutes.quoteRequest)),
          _Tile(icon: Icons.contact_support_rounded, label: 'Contact Us',       onTap: () => context.push(AppRoutes.contact)),
          _Tile(icon: Icons.work_rounded,            label: 'Portfolio',        onTap: () => context.push(AppRoutes.portfolio)),
          _Tile(icon: Icons.info_rounded,            label: 'About Us',         onTap: () {}),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderGrey),
          ),
          tileColor: AppColors.white,
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.black, size: 20),
          ),
          title: Text(label, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500,
            color: AppColors.black)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softGrey),
        ),
      );
}
