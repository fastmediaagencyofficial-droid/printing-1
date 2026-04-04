import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/order_bloc.dart';
import '../../data/models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _phoneController = TextEditingController();
  bool _searched = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _track(BuildContext context) {
    final phone = _phoneController.text.trim();
    if (phone.length < 7) return;
    setState(() => _searched = true);
    context.read<OrderBloc>().add(TrackOrdersByPhoneEvent(phone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderBloc>(),
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            title: const Text('Track Order'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () { try { context.pop(); } catch (_) { context.go('/'); } },
            ),
          ),
          body: Column(
            children: [
              // ── Phone lookup bar ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(bottom: BorderSide(color: AppColors.borderGrey)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Enter your phone number',
                          prefixIcon: Icon(Icons.phone_outlined),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _track(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _track(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),

              // ── Results ─────────────────────────────────────────
              Expanded(
                child: BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    if (!_searched) {
                      return _PhoneLookupHint();
                    }
                    if (state is OrdersLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryRed),
                      );
                    }
                    if (state is OrderError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.mediumGrey),
                            const SizedBox(height: 12),
                            Text(state.message,
                                style: const TextStyle(
                                    fontFamily: 'Inter', color: AppColors.mediumGrey)),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => _track(context),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is OrdersLoaded && state.orders.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 64, color: AppColors.borderGrey),
                            SizedBox(height: 16),
                            Text('No orders found',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 8),
                            Text('No orders placed with this phone number',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    color: AppColors.mediumGrey)),
                          ],
                        ),
                      );
                    }
                    if (state is OrdersLoaded) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.orders.length,
                        itemBuilder: (_, i) => _OrderCard(order: state.orders[i]),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PhoneLookupHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.redSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded,
                  size: 40, color: AppColors.primaryRed),
            ),
            const SizedBox(height: 20),
            const Text('Track Your Order',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Enter the phone number you used when placing your order to see your order status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13, color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING_PAYMENT': return Colors.orange;
      case 'PAYMENT_UPLOADED': return Colors.blue;
      case 'CONFIRMED': return Colors.green;
      case 'IN_PRODUCTION': return AppColors.primaryRed;
      case 'SHIPPED': return Colors.purple;
      case 'DELIVERED': return Colors.teal;
      case 'CANCELLED': return AppColors.mediumGrey;
      default: return AppColors.mediumGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(order.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''} • ${order.paymentMethod}',
              style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.createdAt.toLocal().toString().substring(0, 10),
                  style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.softGrey),
                ),
                Text(
                  'PKR ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryRed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order Detail Screen ───────────────────────────────────────────────────────

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<OrderBloc>()..add(LoadOrderDetailEvent(orderId)),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text('Order Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () { try { context.pop(); } catch (_) { context.go('/orders'); } },
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed));
            }
            if (state is OrderError) {
              return Center(child: Text(state.message));
            }
            if (state is OrderDetailLoaded) {
              return _OrderDetailBody(order: state.order);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});
  final OrderModel order;

  Color _statusColor(String s) {
    switch (s) {
      case 'PENDING_PAYMENT': return Colors.orange;
      case 'PAYMENT_UPLOADED': return Colors.blue;
      case 'CONFIRMED': return Colors.green;
      case 'IN_PRODUCTION': return AppColors.primaryRed;
      case 'SHIPPED': return Colors.purple;
      case 'DELIVERED': return Colors.teal;
      case 'CANCELLED': return AppColors.mediumGrey;
      default: return AppColors.mediumGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Status badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order #${order.orderId}',
                style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(order.statusLabel,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(order.status))),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          order.createdAt.toLocal().toString().substring(0, 16),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.softGrey),
        ),
        const SizedBox(height: 24),

        // Items
        const Text('Order Items',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...order.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      color: AppColors.primaryRed, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.productName,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text('Qty: ${item.quantity}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.mediumGrey)),
                    ]),
                  ),
                  Text('PKR ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed)),
                ],
              ),
            )),

        const Divider(height: 32),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total',
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700)),
            Text('PKR ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryRed)),
          ],
        ),

        if (order.shippingCity != null) ...[
          const SizedBox(height: 16),
          Text('Delivery to: ${order.shippingCity}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.mediumGrey)),
        ],

        if (order.adminNotes != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Note: ${order.adminNotes}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13)),
          ),
        ],

        // Upload proof button
        if (order.canUploadProof) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.payment,
                extra: {'orderId': order.id, 'paymentMethod': order.paymentMethod}),
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Upload Payment Proof'),
          ),
        ],

        // Cancel button
        if (order.canCancel) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              context.read<OrderBloc>().add(CancelOrderEvent(order.id));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ],
    );
  }
}
