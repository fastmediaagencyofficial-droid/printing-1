class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // Main tabs
  static const String home = '/home';
  static const String services = '/services';
  static const String products = '/products';
  static const String industries = '/industries';
  static const String profile = '/profile';

  // Detail screens
  static const String productDetail = '/products/:id';
  static const String serviceDetail = '/services/:slug';
  static const String industryDetail = '/industries/:slug';

  // Commerce
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orderConfirmation = '/order-confirmation/:orderId';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';

  // Content
  static const String portfolio = '/portfolio';
  static const String contact = '/contact';
  static const String quoteRequest = '/quote-request';
  static const String myQuotes = '/my-quotes';
  static const String faq = '/faq';
  static const String about = '/about';
  static const String notifications = '/notifications';
}
