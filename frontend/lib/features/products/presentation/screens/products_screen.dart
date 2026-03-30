import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isGridView = true;

  final List<String> _categories = [
    'All', 'Business Printing', 'Marketing', 'Packaging',
    'Large Format', 'Speciality', 'Labels',
  ];

  final List<_Product> _allProducts = [
    _Product(id: '1', name: 'Business Cards', category: 'Business Printing', startingPrice: 1500, icon: Icons.credit_card_rounded),
    _Product(id: '2', name: 'Brochures', category: 'Marketing', startingPrice: 2500, icon: Icons.menu_book_rounded),
    _Product(id: '3', name: 'Flyers', category: 'Marketing', startingPrice: 800, icon: Icons.article_rounded),
    _Product(id: '4', name: 'Posters', category: 'Large Format', startingPrice: 1200, icon: Icons.image_rounded),
    _Product(id: '5', name: 'Banners', category: 'Large Format', startingPrice: 2000, icon: Icons.panorama_rounded),
    _Product(id: '6', name: 'Custom Boxes', category: 'Packaging', startingPrice: 0, isCustomQuote: true, icon: Icons.inventory_rounded),
    _Product(id: '7', name: 'Stickers and Labels', category: 'Labels', startingPrice: 500, icon: Icons.label_rounded),
    _Product(id: '8', name: 'Letterheads', category: 'Business Printing', startingPrice: 1200, icon: Icons.description_rounded),
    _Product(id: '9', name: 'Envelopes', category: 'Business Printing', startingPrice: 900, icon: Icons.mail_rounded),
    _Product(id: '10', name: 'Presentation Folders', category: 'Business Printing', startingPrice: 3500, icon: Icons.folder_rounded),
    _Product(id: '11', name: 'Catalogs', category: 'Marketing', startingPrice: 5000, icon: Icons.collections_bookmark_rounded),
    _Product(id: '12', name: 'Roll-Up Banners', category: 'Large Format', startingPrice: 3500, icon: Icons.filter_rounded),
    _Product(id: '13', name: 'Window Graphics', category: 'Large Format', startingPrice: 0, isCustomQuote: true, icon: Icons.window_rounded),
    _Product(id: '14', name: 'Wall Graphics', category: 'Large Format', startingPrice: 0, isCustomQuote: true, icon: Icons.wallpaper_rounded),
    _Product(id: '15', name: 'Shopping Bags', category: 'Packaging', startingPrice: 2000, icon: Icons.shopping_bag_rounded),
    _Product(id: '16', name: 'Food Packaging', category: 'Packaging', startingPrice: 0, isCustomQuote: true, icon: Icons.fastfood_rounded),
    _Product(id: '17', name: 'Wedding Cards', category: 'Speciality', startingPrice: 5000, icon: Icons.favorite_rounded),
    _Product(id: '18', name: 'Calendars', category: 'Speciality', startingPrice: 1800, icon: Icons.calendar_month_rounded),
    _Product(id: '19', name: 'Notepads', category: 'Business Printing', startingPrice: 1500, icon: Icons.note_rounded),
    _Product(id: '20', name: 'Certificates', category: 'Speciality', startingPrice: 2500, icon: Icons.workspace_premium_rounded),
    _Product(id: '21', name: 'Tissue Papers', category: 'Packaging', startingPrice: 3000, icon: Icons.spa_rounded),
    _Product(id: '22', name: 'Bill Books', category: 'Business Printing', startingPrice: 1200, icon: Icons.receipt_long_rounded),
    _Product(id: '23', name: 'Flag Printing', category: 'Large Format', startingPrice: 0, isCustomQuote: true, icon: Icons.flag_rounded),
  ];

  List<_Product> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryRed),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
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
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
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
                  '${_filteredProducts.length} products',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          // Product grid/list
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmpty()
                : _isGridView
                    ? _buildGrid()
                    : _buildList(),
          ),
        ],
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
            onPressed: () => setState(() { _searchQuery = ''; _selectedCategory = 'All'; }),
            child: const Text('Clear filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (_, i) => _ProductCard(
        product: _filteredProducts[i],
        index: i,
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _filteredProducts.length,
      itemBuilder: (_, i) => _ProductListTile(
        product: _filteredProducts[i],
        index: i,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.index});
  final _Product product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
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
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(product.icon, size: 48, color: AppColors.primaryRed),
                  ),
                  if (product.isCustomQuote)
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
                    product.isCustomQuote
                        ? 'Custom Quote'
                        : 'From PKR ${product.startingPrice}',
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
                        'Add to Cart',
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

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product, required this.index});
  final _Product product;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
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
              child: Icon(product.icon, color: AppColors.primaryRed, size: 30),
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
                    product.isCustomQuote ? 'Custom Quote' : 'From PKR ${product.startingPrice}',
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

class _Product {
  final String id, name, category;
  final int startingPrice;
  final bool isCustomQuote;
  final IconData icon;
  const _Product({
    required this.id,
    required this.name,
    required this.category,
    required this.startingPrice,
    this.isCustomQuote = false,
    required this.icon,
  });
}
