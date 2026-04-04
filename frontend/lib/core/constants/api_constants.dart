class ApiConstants {
  ApiConstants._();

  // Dev emulator:  http://10.0.2.2:5000/api/v1
  // Production:    https://your-app.up.railway.app/api/v1
  static const String _base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );

  // Auth
  static const String googleLogin    = '$_base/auth/google-login';
  static const String me             = '$_base/auth/me';
  static const String updateProfile  = '$_base/auth/profile';

  // Products
  static const String products           = '$_base/products';
  static const String productCategories  = '$_base/products/categories';
  static String productById(String id)   => '$_base/products/$id';

  // Services
  static const String services            = '$_base/services';
  static String serviceBySlug(String s)  => '$_base/services/$s';

  // Cart
  static const String cart            = '$_base/cart';
  static const String cartAdd         = '$_base/cart/add';
  static String cartItem(String id)   => '$_base/cart/item/$id';
  static const String cartClear       = '$_base/cart/clear';

  // Wishlist
  static const String wishlist                 = '$_base/wishlist';
  static const String wishlistAdd              = '$_base/wishlist/add';
  static String wishlistRemove(String id)      => '$_base/wishlist/$id';
  static String wishlistMoveToCart(String id)  => '$_base/wishlist/move-to-cart/$id';

  // Orders
  static const String orders                   = '$_base/orders';
  static String orderById(String id)           => '$_base/orders/$id';
  static String orderPaymentProof(String id)   => '$_base/orders/$id/payment-proof';
  static String orderCancel(String id)         => '$_base/orders/$id/cancel';

  // Payment
  static const String paymentMethods = '$_base/payment/methods';

  // Quotes
  static const String quoteRequest = '$_base/quotes/request';
  static const String myQuotes     = '$_base/quotes/my';

  // Contact
  static const String contact = '$_base/contact';

  // Industries
  static const String industries = '$_base/industries';
}
