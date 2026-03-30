import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/services/presentation/bloc/service_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'features/industries/presentation/cubit/industry_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/main_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/products/presentation/screens/products_screen.dart';
import 'features/products/presentation/screens/product_detail_screen.dart';
import 'features/services/presentation/screens/services_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/wishlist/presentation/screens/wishlist_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/payment/presentation/screens/checkout_screen.dart';
import 'features/payment/presentation/screens/payment_screen.dart';
import 'features/payment/presentation/screens/order_confirmation_screen.dart';
import 'features/industries/presentation/screens/industries_screen.dart';
import 'features/portfolio/presentation/screens/portfolio_screen.dart';
import 'features/contact/presentation/screens/contact_screen.dart';
import 'features/contact/presentation/screens/quote_request_screen.dart';
import 'features/quotes/presentation/screens/my_quotes_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'core/network/api_service.dart' show navigatorKey;
import 'injection_container.dart' as di;

class FastPrintingApp extends StatelessWidget {
  const FastPrintingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent())),
        BlocProvider(create: (_) => di.sl<CartBloc>()..add(LoadCartEvent())),
        BlocProvider(create: (_) => di.sl<WishlistBloc>()),
        BlocProvider(create: (_) => di.sl<ProductBloc>()..add(LoadProductsEvent())),
        BlocProvider(create: (_) => di.sl<ServiceBloc>()..add(LoadServicesEvent())),
        BlocProvider(create: (_) => di.sl<IndustryCubit>()..loadIndustries()),
      ],
      child: MaterialApp.router(
        title: 'Fast Printing & Packaging',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    // ── Auth flow ─────────────────────────────────────────────────────────
    GoRoute(path: AppRoutes.splash,      builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.onboarding,  builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: AppRoutes.login,       builder: (_, __) => const LoginScreen()),

    // ── Main shell (bottom nav) ───────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(path: AppRoutes.home,       builder: (_, __) => const HomeScreen()),
        GoRoute(path: AppRoutes.services,   builder: (_, __) => const ServicesScreen()),
        GoRoute(path: AppRoutes.products,   builder: (_, __) => const ProductsScreen()),
        GoRoute(path: AppRoutes.industries, builder: (_, __) => const IndustriesScreen()),
        GoRoute(path: AppRoutes.profile,    builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // ── Detail screens ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (ctx, state) =>
          ProductDetailScreen(productId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: AppRoutes.serviceDetail,
      builder: (ctx, state) =>
          ServiceDetailScreen(serviceSlug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: AppRoutes.industryDetail,
      builder: (ctx, state) =>
          IndustryDetailScreen(industrySlug: state.pathParameters['slug']!),
    ),

    // ── Commerce ──────────────────────────────────────────────────────────
    GoRoute(path: AppRoutes.cart,      builder: (_, __) => const CartScreen()),
    GoRoute(path: AppRoutes.wishlist,  builder: (_, __) => const WishlistScreen()),
    GoRoute(path: AppRoutes.checkout,  builder: (_, __) => const CheckoutScreen()),
    GoRoute(
      path: AppRoutes.payment,
      builder: (ctx, state) =>
          PaymentScreen(extra: state.extra as Map<String, dynamic>),
    ),
    GoRoute(
      path: AppRoutes.orderConfirmation,
      builder: (ctx, state) =>
          OrderConfirmationScreen(orderId: state.pathParameters['orderId']!),
    ),
    GoRoute(path: AppRoutes.orders,   builder: (_, __) => const OrdersScreen()),
    GoRoute(
      path: AppRoutes.orderDetail,
      builder: (ctx, state) =>
          OrderDetailScreen(orderId: state.pathParameters['id']!),
    ),

    // ── Content ───────────────────────────────────────────────────────────
    GoRoute(path: AppRoutes.portfolio,     builder: (_, __) => const PortfolioScreen()),
    GoRoute(path: AppRoutes.contact,       builder: (_, __) => const ContactScreen()),
    GoRoute(path: AppRoutes.quoteRequest,  builder: (_, __) => const QuoteRequestScreen()),
    GoRoute(path: '/my-quotes',            builder: (_, __) => const MyQuotesScreen()),
    GoRoute(path: AppRoutes.notifications, builder: (_, __) => const _NotificationsPlaceholder()),
  ],
);

class _NotificationsPlaceholder extends StatelessWidget {
  const _NotificationsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('No notifications yet', style: TextStyle(fontFamily: 'Inter'))),
    );
  }
}
