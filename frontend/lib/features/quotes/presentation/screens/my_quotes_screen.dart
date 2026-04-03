import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/quote_model.dart';
import '../bloc/quote_bloc.dart';
import '../../../../injection_container.dart' as di;

class MyQuotesScreen extends StatelessWidget {
  const MyQuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<QuoteBloc>()..add(LoadMyQuotesEvent()),
      child: const _MyQuotesView(),
    );
  }
}

class _MyQuotesView extends StatelessWidget {
  const _MyQuotesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('My Quotes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () { try { context.pop(); } catch (_) { context.go('/'); } },
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.quoteRequest),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryRed),
          ),
        ],
      ),
      body: BlocBuilder<QuoteBloc, QuoteState>(
        builder: (context, state) {
          if (state is QuoteLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
          }
          if (state is QuoteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.softGrey),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(fontFamily: 'Inter', color: AppColors.mediumGrey)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<QuoteBloc>().add(LoadMyQuotesEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is QuotesLoaded && state.quotes.isEmpty) {
            return _EmptyQuotes();
          }
          if (state is QuotesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.quotes.length,
              itemBuilder: (context, index) => _QuoteCard(quote: state.quotes[index]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _EmptyQuotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.redSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.request_quote_outlined,
                  size: 48, color: AppColors.primaryRed),
            ),
            const SizedBox(height: 20),
            const Text(
              'No quotes yet',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'Request a custom quote for your printing needs',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, color: AppColors.mediumGrey),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.quoteRequest),
              child: const Text('Request a Quote'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});
  final QuoteModel quote;

  Color _statusColor(String status) => switch (status) {
        'PENDING' => const Color(0xFFB45309),
        'REVIEWED' => const Color(0xFF1D4ED8),
        'SENT' => const Color(0xFF6D28D9),
        'ACCEPTED' => const Color(0xFF065F46),
        'REJECTED' => const Color(0xFFB91C1C),
        _ => AppColors.mediumGrey,
      };

  Color _statusBg(String status) => switch (status) {
        'PENDING' => const Color(0xFFFEF3C7),
        'REVIEWED' => const Color(0xFFDBEAFE),
        'SENT' => const Color(0xFFEDE9FE),
        'ACCEPTED' => const Color(0xFFD1FAE5),
        'REJECTED' => const Color(0xFFFEE2E2),
        _ => AppColors.lightGrey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Expanded(
                child: Text(
                  quote.product,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(quote.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  quote.status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(quote.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Qty: ${quote.quantity.toLocaleString()}  ·  ${_formatDate(quote.createdAt)}',
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12, color: AppColors.mediumGrey),
          ),
          if (quote.estimatedPrice != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Quoted Price: ',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13, color: AppColors.mediumGrey)),
                Text(
                  'PKR ${quote.estimatedPrice!.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
          ],
          if (quote.adminResponse != null && quote.adminResponse!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Response from team:',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey)),
                  const SizedBox(height: 4),
                  Text(
                    quote.adminResponse!,
                    style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12, color: AppColors.darkGrey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

extension on int {
  String toLocaleString() {
    final s = toString();
    if (s.length <= 3) return s;
    final buffer = StringBuffer();
    final start = s.length % 3;
    if (start > 0) buffer.write(s.substring(0, start));
    for (int i = start; i < s.length; i += 3) {
      if (i > 0) buffer.write(',');
      buffer.write(s.substring(i, i + 3));
    }
    return buffer.toString();
  }
}
