import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? productData;
  const ProductDetailScreen({super.key, required this.productId, this.productData});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 100;
  String _selectedSize = 'Standard';
  String _selectedMaterial = '350gsm Matt';
  String _selectedFinish = 'UV Gloss';

  final List<String> _sizes = ['Standard', 'Small', 'Large', 'Custom'];
  final List<String> _materials = ['350gsm Matt', '300gsm Gloss', '250gsm Uncoated', 'Premium 400gsm'];
  final List<String> _finishes = ['UV Gloss', 'Matt Laminate', 'Spot UV', 'No Finish'];

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
                _buildProductInfo(),
                _buildSpecsSection(),
                _buildQuantitySection(),
                _buildPriceEstimate(),
                _buildDescription(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: GestureDetector(
        onTap: () { try { context.pop(); } catch (_) { context.go('/products'); } },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.black),
        ),
      ),
      actions: [
        BlocBuilder<WishlistBloc, WishlistState>(
          builder: (context, wState) {
            final inWishlist = wState is WishlistLoaded &&
                wState.contains(widget.productId);
            return GestureDetector(
              onTap: () {
                final name = widget.productData?['name'] as String? ?? 'Product';
                final category = widget.productData?['category'] as String? ?? '';
                final price = (widget.productData?['startingPrice'] as int? ?? 0).toDouble();
                final imageUrl = widget.productData?['imageUrl'] as String? ?? '';
                if (inWishlist) {
                  context.read<WishlistBloc>().add(RemoveFromWishlistEvent(widget.productId));
                } else {
                  context.read<WishlistBloc>().add(AddToWishlistEvent(
                    productId: widget.productId,
                    productName: name,
                    category: category,
                    startingPrice: price,
                    imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Added to wishlist!'),
                    backgroundColor: AppColors.primaryRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: inWishlist ? AppColors.primaryRed : AppColors.black,
                  ),
                ),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.cart),
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppColors.cardShadow,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.shopping_cart_outlined, color: AppColors.black),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.lightGrey,
          child: _buildHeroImage(),
        ),
      ),
    );
  }

  String _fixImageUrl(String url) =>
      url.replaceFirst('http://localhost:', 'http://10.0.2.2:');

  Widget _buildHeroImage() {
    final imageUrl = widget.productData?['imageUrl'] as String? ?? '';
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(Icons.inventory_2_rounded, size: 100, color: AppColors.primaryRed),
      );
    }
    return Image.network(
      _fixImageUrl(imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.inventory_2_rounded, size: 100, color: AppColors.primaryRed),
      ),
    );
  }

  Widget _buildProductInfo() {
    final name = widget.productData?['name'] as String? ?? 'Product';
    final category = widget.productData?['category'] as String? ?? '';
    final startingPrice = widget.productData?['startingPrice'] as int? ?? 0;
    final isCustomQuote = widget.productData?['isCustomQuote'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.redSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              const Spacer(),
              Row(
                children: List.generate(5, (_) => const Icon(
                  Icons.star_rounded, color: Color(0xFFFFB300), size: 16)),
              ),
              const Text(
                ' (4.9)',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Starting from',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.mediumGrey),
              ),
              const SizedBox(width: 8),
              Text(
                isCustomQuote ? 'Custom Quote' : 'PKR $startingPrice',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryRed,
                ),
              ),
              if (!isCustomQuote)
                const Text(
                  ' / 100 pcs',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildSpecsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customize Your Order',
            style: TextStyle(
              fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildSpecRow('Size', _sizes, _selectedSize, (v) => setState(() => _selectedSize = v)),
          const SizedBox(height: 16),
          _buildSpecRow('Material', _materials, _selectedMaterial, (v) => setState(() => _selectedMaterial = v)),
          const SizedBox(height: 16),
          _buildSpecRow('Finish', _finishes, _selectedFinish, (v) => setState(() => _selectedFinish = v)),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, List<String> options, String selected, Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.black),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryRed : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryRed : AppColors.borderGrey,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quantity (pieces)',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              _QtyBtn(Icons.remove_rounded, () { if (_quantity > 50) setState(() => _quantity -= 50); }),
              Container(
                width: 80,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _quantity.toString(),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              _QtyBtn(Icons.add_rounded, () => setState(() => _quantity += 50)),
              const SizedBox(width: 12),
              const Text('Minimum: 50 pcs',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceEstimate() {
    final startingPrice = widget.productData?['startingPrice'] as int? ?? 0;
    final price = (startingPrice / 100 * _quantity).toStringAsFixed(0);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.redBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimated Price',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey)),
              Text(
                'PKR $price',
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryRed),
              ),
              Text(
                'for $_quantity pieces',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.mediumGrey),
              ),
            ],
          ),
          const Text(
            '* Final price confirmed\nafter review',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.mediumGrey),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product Description',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
          SizedBox(height: 10),
          Text(
            'Our premium business cards are printed on high-quality cardstock with sharp, vibrant colors. Perfect for making a lasting impression at meetings, conferences, and networking events. Available in multiple sizes, materials, and finishing options to match your brand identity.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.darkGrey, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            BlocBuilder<WishlistBloc, WishlistState>(
              builder: (context, wState) {
                final inWishlist = wState is WishlistLoaded &&
                    wState.contains(widget.productId);
                return Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final name = widget.productData?['name'] as String? ?? 'Product';
                      final category = widget.productData?['category'] as String? ?? '';
                      final price = (widget.productData?['startingPrice'] as int? ?? 0).toDouble();
                      final imageUrl = widget.productData?['imageUrl'] as String? ?? '';
                      if (inWishlist) {
                        context.read<WishlistBloc>().add(RemoveFromWishlistEvent(widget.productId));
                      } else {
                        context.read<WishlistBloc>().add(AddToWishlistEvent(
                          productId: widget.productId,
                          productName: name,
                          category: category,
                          startingPrice: price,
                          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                        ));
                      }
                    },
                    icon: Icon(
                      inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                    ),
                    label: Text(inWishlist ? 'Wishlisted' : 'Wishlist'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: inWishlist ? AppColors.primaryRed : AppColors.black,
                      side: BorderSide(
                        color: inWishlist ? AppColors.primaryRed : AppColors.borderGrey,
                      ),
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = widget.productData?['name'] as String? ?? 'Product';
                  final price = widget.productData?['startingPrice'] as int? ?? 0;
                  context.read<CartBloc>().add(AddToCartEvent(
                    productId: widget.productId,
                    productName: name,
                    unitPrice: price.toDouble(),
                    quantity: _quantity,
                    customSpecs: {
                      'Size': _selectedSize,
                      'Material': _selectedMaterial,
                      'Finish': _selectedFinish,
                    },
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Added to cart!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () => context.push(AppRoutes.cart),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                label: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
