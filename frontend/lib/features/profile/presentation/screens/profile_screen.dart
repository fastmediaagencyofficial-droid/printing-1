import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('My Profile'), automaticallyImplyLeading: false),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Avatar ──────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryRed,
                      backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                          ? Text(
                              (user?.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32, color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 14),
                    Text(
                      user?.displayName ?? 'Guest',
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 14, color: AppColors.mediumGrey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.redSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Google Account',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w500, color: AppColors.primaryRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats ────────────────────────────────────────────────
              Row(children: [
                _Stat(value: '0', label: 'Orders'),
                const SizedBox(width: 12),
                _Stat(value: '0', label: 'Wishlist'),
                const SizedBox(width: 12),
                _Stat(value: 'PKR 0', label: 'Spent'),
              ]),
              const SizedBox(height: 28),

              // ── Menu ─────────────────────────────────────────────────
              _Tile(icon: Icons.shopping_bag_rounded,    label: 'My Orders',        onTap: () => context.push(AppRoutes.orders)),
              _Tile(icon: Icons.favorite_rounded,        label: 'My Wishlist',      onTap: () => context.push(AppRoutes.wishlist)),
              _Tile(icon: Icons.request_quote_rounded,   label: 'Request a Quote',  onTap: () => context.push(AppRoutes.quoteRequest)),
              _Tile(icon: Icons.contact_support_rounded, label: 'Contact Us',       onTap: () => context.push(AppRoutes.contact)),
              _Tile(icon: Icons.work_rounded,            label: 'Portfolio',        onTap: () => context.push(AppRoutes.portfolio)),
              _Tile(icon: Icons.info_rounded,            label: 'About Us',         onTap: () {}),
              const SizedBox(height: 8),
              _Tile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                isDestructive: true,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(SignOutEvent());
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(children: [
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16,
                fontWeight: FontWeight.w700, color: AppColors.primaryRed)),
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                color: AppColors.mediumGrey)),
          ]),
        ),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

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
              color: isDestructive ? AppColors.redSurface : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isDestructive ? AppColors.primaryRed : AppColors.black, size: 20),
          ),
          title: Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500,
            color: isDestructive ? AppColors.primaryRed : AppColors.black)),
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14,
              color: isDestructive ? AppColors.primaryRed : AppColors.softGrey),
        ),
      );
}
