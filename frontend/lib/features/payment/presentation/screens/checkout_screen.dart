import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/data/models/cart_model.dart';
import '../../../orders/presentation/bloc/order_bloc.dart';
import '../../../../injection_container.dart' as di;

const _kSizes = [
  'A4 (210×297mm)', 'A5 (148×210mm)', 'A6 (105×148mm)',
  'A3 (297×420mm)', 'Business Card (90×50mm)',
  'DL (99×210mm)', 'Square (150×150mm)', 'Custom',
];

const _kCategories = [
  'Business Cards', 'Flyers', 'Brochures', 'Banners',
  'Posters', 'Stickers', 'Packaging', 'Letterheads',
  'Envelopes', 'Books & Catalogs', 'Other',
];

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'JAZZCASH';
  String? _selectedSize;
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderBloc>(),
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderPlaced) {
            context.pushReplacement('/order-confirmation/${state.order.id}');
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: const Text('Checkout'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () { try { context.pop(); } catch (_) { context.go('/cart'); } },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order Summary ──────────────────────────────────────
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      if (cartState is CartLoaded) {
                        return _OrderSummary(items: cartState.cartItems, total: cartState.total);
                      }
                      return const SizedBox();
                    },
                  ),

                  // ── Your Information ───────────────────────────────────
                  const SizedBox(height: 24),
                  const _SectionTitle('Your Information'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone number (e.g. 03xx-xxxxxxx)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Email address (optional)',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  // ── Print Job Details ──────────────────────────────────
                  const SizedBox(height: 24),
                  const _SectionTitle('Print Job Details'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      hintText: 'Select category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _kCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) => v == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedSize,
                    decoration: const InputDecoration(
                      hintText: 'Select size',
                      prefixIcon: Icon(Icons.straighten_outlined),
                    ),
                    items: _kSizes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSize = v),
                    validator: (v) => v == null ? 'Please select a size' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Describe what you want to print (e.g. company logo, text, colors…)',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.description_outlined),
                      ),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                  ),

                  // ── Payment Method ─────────────────────────────────────
                  const SizedBox(height: 24),
                  const _SectionTitle('Payment Method'),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(
                    value: 'JAZZCASH',
                    groupValue: _paymentMethod,
                    label: 'JazzCash',
                    icon: Icons.phone_android_rounded,
                    onTap: () => setState(() => _paymentMethod = 'JAZZCASH'),
                  ),
                  const SizedBox(height: 8),
                  _PaymentMethodTile(
                    value: 'EASYPAISA',
                    groupValue: _paymentMethod,
                    label: 'EasyPaisa',
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () => setState(() => _paymentMethod = 'EASYPAISA'),
                  ),

                  // ── Delivery Address ───────────────────────────────────
                  const SizedBox(height: 24),
                  const _SectionTitle('Delivery Address (optional)'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      hintText: 'Street address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'City',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),

                  // ── Special Instructions ───────────────────────────────
                  const SizedBox(height: 24),
                  const _SectionTitle('Special Instructions (optional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any additional requirements…',
                    ),
                  ),

                  // ── Place Order Button ─────────────────────────────────
                  const SizedBox(height: 32),
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, cartState) {
                      return BlocBuilder<OrderBloc, OrderState>(
                        builder: (context, orderState) {
                          return ElevatedButton(
                            onPressed: orderState is OrdersLoading
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate()) return;
                                    if (cartState is! CartLoaded || cartState.cartItems.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Your cart is empty')),
                                      );
                                      return;
                                    }
                                    context.read<OrderBloc>().add(PlaceGuestOrderEvent(
                                      customerName: _nameController.text.trim(),
                                      customerPhone: _phoneController.text.trim(),
                                      customerEmail: _emailController.text.trim().isEmpty
                                          ? null : _emailController.text.trim(),
                                      productDescription: _descController.text.trim().isEmpty
                                          ? null : _descController.text.trim(),
                                      productSize: _selectedSize,
                                      productCategory: _selectedCategory,
                                      paymentMethod: _paymentMethod,
                                      items: cartState.cartItems.map((item) => {
                                        'productId': item.productId,
                                        'productName': item.productName,
                                        'quantity': item.quantity,
                                        'unitPrice': item.unitPrice,
                                        'totalPrice': item.totalPrice,
                                      }).toList(),
                                      totalAmount: cartState.total,
                                      shippingStreet: _streetController.text.trim().isEmpty
                                          ? null : _streetController.text.trim(),
                                      shippingCity: _cityController.text.trim().isEmpty
                                          ? null : _cityController.text.trim(),
                                      notes: _notesController.text.trim().isEmpty
                                          ? null : _notesController.text.trim(),
                                    ));
                                  },
                            child: orderState is OrdersLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Place Order'),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Payment account details will be shown after placing the order.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11, color: AppColors.mediumGrey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700),
      );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.items, required this.total});
  final List<CartItemModel> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...items.map<Widget>((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName} ×${item.quantity}',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'PKR ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16)),
              Text(
                'PKR ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primaryRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String value, groupValue, label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primaryRed : AppColors.borderGrey,
              width: selected ? 2 : 1),
          color: selected ? AppColors.redSurface : AppColors.white,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primaryRed : AppColors.softGrey, size: 22),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: selected ? AppColors.primaryRed : AppColors.black)),
            const Spacer(),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primaryRed : AppColors.softGrey,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
