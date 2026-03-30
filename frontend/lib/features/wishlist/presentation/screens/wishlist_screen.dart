import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../bloc/wishlist_bloc.dart';

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
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }
          if (state is WishlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.softGrey),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(
                          fontFamily: 'Inter', color: AppColors.mediumGrey)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        context.read<WishlistBloc>().add(LoadWishlistEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is WishlistLoaded && state.items.isEmpty) {
            return _EmptyWishlist();
          }
          if (state is WishlistLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) =>
                  _WishlistItemCard(item: state.items[index]),
            );
          }
          return _EmptyWishlist();
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
    final product = item.product;
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
            child: product.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.lightGrey,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.lightGrey,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: AppColors.softGrey),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: AppColors.lightGrey,
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.primaryRed, size: 32),
                  ),
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
                        product.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    // Remove from wishlist
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
                  product.category,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.mediumGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'PKR ${product.startingPrice.toStringAsFixed(0)}+',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const Spacer(),
                    // Move to cart
                    OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<WishlistBloc>()
                            .add(MoveWishlistToCartEvent(item.productId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Moved to cart!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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
}
