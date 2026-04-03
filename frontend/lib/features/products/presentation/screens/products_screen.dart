import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/product_bloc.dart';
import '../../data/models/product_model.dart';

/// Converts a backend image URL so it works on the Android emulator.
/// Backend stores http://localhost:5000/... but emulator needs http://10.0.2.2:5000/...
String _fixImageUrl(String url) =>
    url.replaceFirst('http://localhost:', 'http://10.0.2.2:');

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isGridView = true;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    context.read<ProductBloc>().add(LoadProductsEvent(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Products'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final products = state is ProductsLoaded ? state.products : <ProductModel>[];
          final categories = state is ProductsLoaded ? state.categories : <CategoryModel>[];
          final isLoading = state is ProductsLoading;
          final error = state is ProductError ? state.message : null;

          // Build category name list (All + names from API)
          final categoryNames = ['All', ...categories.map((c) => c.name)];

          // Client-side filter (in case BLoC returned broader results)
          final filtered = products.where((p) {
            final matchesCat = _selectedCategory == 'All' || p.category == _selectedCategory;
            final matchesSearch = _searchQuery.isEmpty ||
                p.name.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCat && matchesSearch;
          }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    setState(() => _searchQuery = v);
                    if (v.isEmpty) _applyFilter();
                  },
                  onSubmitted: (_) => _applyFilter(),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryRed),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _applyFilter();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              // Category filter chips
              SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: categoryNames.length,
                  itemBuilder: (_, i) {
                    final cat = categoryNames[i];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                          _applyFilter();
                        },
                        selectedColor: AppColors.primaryRed,
                        backgroundColor: AppColors.lightGrey,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.black,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryRed : AppColors.borderGrey,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Results count
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Text(
                      isLoading ? 'Loading...' : '${filtered.length} products',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(width: 8),
                      Text(error,
                          style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 12, color: AppColors.primaryRed)),
                    ],
                  ],
                ),
              ),
              // Content
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryRed))
                    : filtered.isEmpty
                        ? _buildEmpty()
                        : _isGridView
                            ? _buildGrid(filtered)
                            : _buildList(filtered),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 60, color: AppColors.borderGrey),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() { _searchQuery = ''; _selectedCategory = 'All'; });
              _applyFilter();
            },
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(product: products[i], index: i),
    );
  }

  Widget _buildList(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductListTile(product: products[i], index: i),
    );
  }
}

// ── Product Card (grid) ───────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.index});
  final ProductModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}', extra: {
        'name': product.name,
        'category': product.category,
        'startingPrice': product.startingPrice.toInt(),
        'isCustomQuote': product.startingPrice == 0,
        'imageUrl': product.displayImage,
      }),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: product.displayImage.isNotEmpty
                          ? Image.network(
                              _fixImageUrl(product.displayImage),
                              width: double.infinity,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.inventory_2_rounded,
                                  size: 48,
                                  color: AppColors.primaryRed),
                            )
                          : const Icon(Icons.inventory_2_rounded,
                              size: 48, color: AppColors.primaryRed),
                    ),
                  ),
                  if (product.startingPrice == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Quote',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.startingPrice == 0
                        ? 'Custom Quote'
                        : 'From PKR ${product.startingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn()
        .scale(begin: const Offset(0.95, 0.95));
  }
}

// ── Product List Tile ─────────────────────────────────────────────────────────

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product, required this.index});
  final ProductModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}', extra: {
        'name': product.name,
        'category': product.category,
        'startingPrice': product.startingPrice.toInt(),
        'isCustomQuote': product.startingPrice == 0,
        'imageUrl': product.displayImage,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.displayImage.isNotEmpty
                    ? Image.network(
                        _fixImageUrl(product.displayImage),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.inventory_2_rounded,
                            color: AppColors.primaryRed,
                            size: 30),
                      )
                    : const Icon(Icons.inventory_2_rounded,
                        color: AppColors.primaryRed, size: 30),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                    product.category,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey),
                  ),
                  Text(
                    product.startingPrice == 0
                        ? 'Custom Quote'
                        : 'From PKR ${product.startingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.softGrey),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}
