import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/cart_model.dart';
import '../bloc/cart_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () { try { context.pop(); } catch (_) { context.go('/'); } },
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cartItems.isNotEmpty) {
                return TextButton(
                  onPressed: () => _showClearCartDialog(context),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }
          if (state is CartError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(fontFamily: 'Inter', color: AppColors.mediumGrey)),
            );
          }
          if (state is CartLoaded && state.cartItems.isEmpty) {
            return _EmptyCart();
          }
          if (state is CartLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.cartItems.length,
                    itemBuilder: (context, index) {
                      return _CartItemCard(item: state.cartItems[index], index: index);
                    },
                  ),
                ),
                _CartSummary(items: state.cartItems, total: state.total),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart?',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCartEvent());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.redSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: AppColors.primaryRed,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text(
            AppStrings.cartEmpty,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.cartEmptySubtitle,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.mediumGrey),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.products),
              child: const Text('Browse Products'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.index});
  final CartItemModel item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryRed, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<CartBloc>().add(RemoveCartItemEvent(item.id)),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.softGrey),
                    ),
                  ],
                ),
                if (item.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.note!,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 11, color: AppColors.mediumGrey),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityBtn(
                            icon: Icons.remove_rounded,
                            onTap: item.quantity > 1
                                ? () => context.read<CartBloc>().add(
                                      UpdateCartItemEvent(
                                          itemId: item.id, quantity: item.quantity - 1),
                                    )
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                  fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          _QuantityBtn(
                            icon: Icons.add_rounded,
                            onTap: () => context.read<CartBloc>().add(
                                  UpdateCartItemEvent(
                                      itemId: item.id, quantity: item.quantity + 1),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'PKR ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed,
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
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}

class _QuantityBtn extends StatelessWidget {
  const _QuantityBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.lightGrey : AppColors.dividerGrey,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppColors.black : AppColors.softGrey,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.items, required this.total});
  final List<CartItemModel> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} item${items.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, color: AppColors.mediumGrey),
                ),
                Text(
                  'PKR ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              '* Final price may vary based on specifications',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.softGrey),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.checkout),
              child: const Text(AppStrings.proceedToCheckout),
            ),
          ],
        ),
      ),
    );
  }
}
