import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../bloc/wishlist_bloc.dart';

String _fixImageUrl(String url) =>
    url.replaceFirst('http://localhost:', 'http://10.0.2.2:');

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('My Wishlist'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            try {
              context.pop();
            } catch (_) {
              context.go('/');
            }
          },
        ),
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          final items =
              state is WishlistLoaded ? state.items : <WishlistItemModel>[];

          if (items.isEmpty) return _EmptyWishlist();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _WishlistItemCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                color: AppColors.redSurface, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_outline_rounded,
                size: 48, color: AppColors.primaryRed),
          ),
          const SizedBox(height: 20),
          const Text('Your wishlist is empty',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Save products you love for later',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.mediumGrey)),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
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

class _WishlistItemCard extends StatelessWidget {
  const _WishlistItemCard({required this.item});
  final WishlistItemModel item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl ?? '';

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
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    _fixImageUrl(imageUrl),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
          const SizedBox(width: 14),
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
                      onTap: () => context
                          .read<WishlistBloc>()
                          .add(RemoveFromWishlistEvent(item.productId)),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.softGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.mediumGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      item.startingPrice > 0
                          ? 'PKR ${item.startingPrice.toStringAsFixed(0)}+'
                          : 'Custom Quote',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Add to local cart
                        context.read<CartBloc>().add(AddToCartEvent(
                          productId: item.productId,
                          productName: item.productName,
                          unitPrice: item.startingPrice,
                          quantity: 1,
                        ));
                        // Remove from wishlist
                        context
                            .read<WishlistBloc>()
                            .add(RemoveFromWishlistEvent(item.productId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Moved to cart!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            action: SnackBarAction(
                              label: 'View Cart',
                              textColor: Colors.white,
                              onPressed: () => context.push(AppRoutes.cart),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 14),
                      label: const Text('Move to Cart',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() => Container(
        width: 80,
        height: 80,
        color: AppColors.lightGrey,
        child: const Icon(Icons.inventory_2_outlined,
            color: AppColors.primaryRed, size: 32),
      );
}
