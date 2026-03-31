import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/services/presentation/bloc/service_bloc.dart';
import 'features/orders/presentation/bloc/order_bloc.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'features/quotes/presentation/bloc/quote_bloc.dart';
import 'features/industries/presentation/cubit/industry_cubit.dart';
import 'features/contact/presentation/cubit/contact_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(
    () => kIsWeb
        ? GoogleSignIn(scopes: ['email', 'profile'])
        : GoogleSignIn(
            scopes: ['email', 'profile'],
            serverClientId: '263680543564-cbf6ocmcddpq8ul9o2cg792hcku0v08c.apps.googleusercontent.com',
          ),
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(() => AuthBloc(googleSignIn: sl()));

  // ── Global singletons (persist across the whole app lifetime) ─────────────
  sl.registerLazySingleton<CartBloc>(() => CartBloc());
  sl.registerLazySingleton<WishlistBloc>(() => WishlistBloc());
  sl.registerLazySingleton<ProductBloc>(() => ProductBloc());
  sl.registerLazySingleton<ServiceBloc>(() => ServiceBloc());
  sl.registerLazySingleton<IndustryCubit>(() => IndustryCubit());

  // ── Per-screen factories (fresh instance each time) ───────────────────────
  sl.registerFactory<OrderBloc>(() => OrderBloc());
  sl.registerFactory<PaymentBloc>(() => PaymentBloc());
  sl.registerFactory<QuoteBloc>(() => QuoteBloc());
  sl.registerFactory<ContactCubit>(() => ContactCubit());
}
