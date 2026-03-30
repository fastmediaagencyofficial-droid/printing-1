# Fast Printing & Packaging — Flutter Mobile App

Android app for Pakistan's fastest custom printing & packaging service. XFast Group, Lahore.

Flutter · BLoC · go_router · Google Sign-In · Dio · flutter_secure_storage · CachedNetworkImage

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Android only) |
| State management | flutter_bloc (BLoC + Cubit pattern) |
| Navigation | go_router (declarative, auth guard) |
| HTTP client | Dio + JWT Bearer interceptor (401 → auto logout) |
| Auth | google_sign_in → backend JWT → flutter_secure_storage |
| Images | cached_network_image (Cloudinary CDN) |
| DI | get_it (service locator) |
| Animations | flutter_animate |

---

## App Structure

```
frontend/
├── android/
│   └── app/
│       ├── build.gradle         # Package: com.xfastgroup.fastprinting
│       └── google-services.json # NOT needed (no Firebase)
├── lib/
│   ├── main.dart                # Entry point — init DI, run app
│   ├── app.dart                 # FastPrintingApp + GoRouter + MultiBlocProvider
│   ├── injection_container.dart # get_it service locator registrations
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart   # All endpoint URLs
│   │   │   ├── app_colors.dart      # Brand colors (#C91A20 primary red)
│   │   │   ├── app_routes.dart      # Route path constants
│   │   │   └── app_strings.dart     # UI text constants
│   │   ├── network/
│   │   │   └── api_service.dart     # Dio singleton + JWT interceptor + 401 handler
│   │   └── theme/
│   │       └── app_theme.dart       # MaterialTheme configuration
│   └── features/
│       ├── auth/
│       │   ├── presentation/bloc/auth_bloc.dart     # Google Sign-In → JWT flow
│       │   └── presentation/screens/
│       │       ├── splash_screen.dart               # CheckAuthStatus on launch
│       │       ├── onboarding_screen.dart           # First-time welcome
│       │       └── login_screen.dart                # "Sign in with Google" button
│       ├── home/
│       │   └── presentation/screens/
│       │       ├── main_screen.dart    # Bottom navigation shell
│       │       └── home_screen.dart    # Featured products + services
│       ├── products/
│       │   ├── data/models/product_model.dart
│       │   └── presentation/
│       │       ├── bloc/product_bloc.dart
│       │       └── screens/
│       │           ├── products_screen.dart      # Grid with search + category filter
│       │           └── product_detail_screen.dart # Full detail + Add to Cart/Wishlist
│       ├── services/
│       │   ├── data/models/service_model.dart
│       │   └── presentation/
│       │       ├── bloc/service_bloc.dart
│       │       └── screens/
│       │           ├── services_screen.dart
│       │           └── service_detail_screen.dart
│       ├── cart/
│       │   ├── data/models/cart_model.dart          # CartItemModel, CartModel
│       │   └── presentation/
│       │       ├── bloc/cart_bloc.dart              # API-connected, LazySingleton
│       │       └── screens/cart_screen.dart         # Qty stepper + checkout CTA
│       ├── wishlist/
│       │   └── presentation/
│       │       ├── bloc/wishlist_bloc.dart          # WishlistItemModel inside
│       │       └── screens/wishlist_screen.dart     # List with Move to Cart
│       ├── orders/
│       │   ├── data/models/order_model.dart
│       │   └── presentation/
│       │       ├── bloc/order_bloc.dart
│       │       └── screens/
│       │           └── orders_screen.dart           # History + OrderDetailScreen
│       ├── payment/
│       │   ├── data/models/payment_model.dart
│       │   └── presentation/
│       │       ├── bloc/payment_bloc.dart
│       │       └── screens/
│       │           ├── checkout_screen.dart         # Cart summary + payment method + place order
│       │           ├── payment_screen.dart          # JazzCash/EasyPaisa numbers + proof upload
│       │           └── order_confirmation_screen.dart
│       ├── quotes/
│       │   ├── data/models/quote_model.dart
│       │   └── presentation/
│       │       ├── bloc/quote_bloc.dart
│       │       └── screens/
│       │           └── my_quotes_screen.dart        # Quote history with status + response
│       ├── industries/
│       │   ├── data/models/industry_model.dart
│       │   └── presentation/
│       │       ├── cubit/industry_cubit.dart
│       │       └── screens/industries_screen.dart   # Cards + IndustryDetailScreen
│       ├── contact/
│       │   └── presentation/
│       │       ├── cubit/contact_cubit.dart
│       │       └── screens/
│       │           ├── contact_screen.dart           # Contact form
│       │           └── quote_request_screen.dart     # Custom quote form
│       └── profile/
│           └── presentation/screens/profile_screen.dart
└── pubspec.yaml
```

---

## Features

### Customer Features

| Feature | Screen(s) | BLoC/Cubit |
|---|---|---|
| Google Sign-In → 30-day JWT | `login_screen.dart` | `AuthBloc` |
| Auto re-auth on launch | `splash_screen.dart` | `AuthBloc.CheckAuthStatusEvent` |
| Browse products + search + filter by category | `products_screen.dart` | `ProductBloc` |
| Product detail with specs + Add to Cart | `product_detail_screen.dart` | `CartBloc` |
| Browse 16 services | `services_screen.dart` | `ServiceBloc` |
| Cart with quantity stepper | `cart_screen.dart` | `CartBloc` |
| Wishlist + Move to Cart | `wishlist_screen.dart` | `WishlistBloc` |
| Checkout with JazzCash/EasyPaisa | `checkout_screen.dart` | `OrderBloc` |
| Upload payment screenshot | `payment_screen.dart` | `PaymentBloc` |
| Order history + detail + cancel | `orders_screen.dart` | `OrderBloc` |
| Request custom quote | `quote_request_screen.dart` | `QuoteBloc` |
| View my quote history + responses | `my_quotes_screen.dart` | `QuoteBloc` |
| Contact support form | `contact_screen.dart` | `ContactCubit` |
| Browse industries | `industries_screen.dart` | `IndustryCubit` |
| Profile + edit phone/address | `profile_screen.dart` | `AuthBloc` |

---

## Setup

### Prerequisites

- Flutter SDK 3.x (`flutter --version`)
- Android Studio with Android SDK 21+
- A physical Android device or emulator

### 1. Install dependencies

```bash
cd frontend
flutter pub get
```

### 2. Configure the API URL

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String _base = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:5000/api/v1', // Android emulator → localhost
  // defaultValue: 'http://192.168.1.X:5000/api/v1', // Physical device (replace with your LAN IP)
  // defaultValue: 'https://your-api.railway.app/api/v1', // Production
);
```

For physical device: find your PC's LAN IP with `ipconfig` (Windows) or `ip addr` (Linux/Mac).

### 3. Google Sign-In Setup (no google-services.json needed)

1. Go to [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → Credentials
2. Create an **OAuth 2.0 Client ID** → Android
3. Package name: `com.xfastgroup.fastprinting`
4. SHA-1 fingerprint from debug keystore:
   ```bash
   # Windows
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   # Mac/Linux
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Copy the **Client ID** value and set it as `GOOGLE_CLIENT_ID` in your backend `.env`
6. **No `google-services.json` needed** — this app uses direct OAuth, not Firebase

### 4. Run the app

```bash
# With emulator running:
flutter run

# Specific device:
flutter run -d emulator-5554

# With custom API URL:
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:5000/api/v1
```

---

## Auth Flow

```
User taps "Sign in with Google"
  ↓
google_sign_in opens Google OAuth screen (no Firebase)
  ↓
Flutter receives Google idToken
  ↓
Flutter POST /api/v1/auth/google-login { idToken }
  ↓
Backend verifies idToken with google-auth-library
Backend upserts User in PostgreSQL
Backend signs 30-day JWT
  ↓
Flutter stores JWT in flutter_secure_storage
  ↓
Every Dio request: Authorization: Bearer <jwt>
  ↓
On 401 response: clear token → redirect to /login
```

---

## BLoC Architecture

All BLoCs/Cubits are registered in `injection_container.dart`:

| Class | Scope | Purpose |
|---|---|---|
| `AuthBloc` | Factory | Google Sign-In, JWT check, logout |
| `CartBloc` | LazySingleton | Cart state persists entire session |
| `WishlistBloc` | LazySingleton | Wishlist persists entire session |
| `ProductBloc` | LazySingleton | Product list loaded once on startup |
| `ServiceBloc` | LazySingleton | Service list loaded once on startup |
| `IndustryCubit` | LazySingleton | Industries loaded once |
| `OrderBloc` | Factory | Fresh instance per orders/checkout screen |
| `PaymentBloc` | Factory | Fresh instance per payment upload |
| `QuoteBloc` | Factory | Fresh instance per quote screen |
| `ContactCubit` | Factory | Fresh instance per contact form |

Global BLoCs (`Cart`, `Wishlist`, `Product`, `Service`, `IndustryCubit`) are started in `app.dart`'s `MultiBlocProvider` so they're available app-wide.

---

## Navigation Routes

| Route | Screen | Auth Required |
|---|---|---|
| `/` | `SplashScreen` | No |
| `/onboarding` | `OnboardingScreen` | No |
| `/login` | `LoginScreen` | No |
| `/home` | `HomeScreen` (shell) | Yes |
| `/products` | `ProductsScreen` | No |
| `/products/:id` | `ProductDetailScreen` | No |
| `/services` | `ServicesScreen` | No |
| `/services/:slug` | `ServiceDetailScreen` | No |
| `/industries` | `IndustriesScreen` | No |
| `/industries/:slug` | `IndustryDetailScreen` | No |
| `/cart` | `CartScreen` | Yes |
| `/wishlist` | `WishlistScreen` | Yes |
| `/checkout` | `CheckoutScreen` | Yes |
| `/payment` | `PaymentScreen` | Yes |
| `/order-confirmation/:orderId` | `OrderConfirmationScreen` | Yes |
| `/orders` | `OrdersScreen` | Yes |
| `/orders/:id` | `OrderDetailScreen` | Yes |
| `/contact` | `ContactScreen` | No |
| `/quote-request` | `QuoteRequestScreen` | No |
| `/my-quotes` | `MyQuotesScreen` | Yes |
| `/profile` | `ProfileScreen` | Yes |

---

## Building for Release

### Debug APK (for testing on device)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

```bash
# 1. Create a keystore (first time only)
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload -storepass yourpassword -keypass yourpassword

# 2. Create android/key.properties
cat > android/key.properties << EOF
storePassword=yourpassword
keyPassword=yourpassword
keyAlias=upload
storeFile=upload-keystore.jks
EOF

# 3. Build
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.railway.app/api/v1
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Play Store Bundle

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-api.railway.app/api/v1
# Output: build/app/outputs/bundle/release/app-release.aab
# Upload this to Google Play Console
```

---

## End-to-End Test Flow

Follow this sequence to verify all features work:

### 1. Auth
- [ ] Launch app → splash screen shows briefly → redirects to onboarding/login
- [ ] Tap "Sign in with Google" → Google account picker appears
- [ ] Select account → redirected to Home screen with user name visible

### 2. Products
- [ ] Home screen shows featured products with images
- [ ] Navigate to Products tab → grid loads with images
- [ ] Search for "box" → filtered results appear
- [ ] Tap a category chip → products filter correctly
- [ ] Tap a product → detail screen opens with size/material/finish options

### 3. Cart
- [ ] On product detail, select quantity and options → tap "Add to Cart"
- [ ] Cart badge increments
- [ ] Navigate to Cart → item appears with quantity stepper
- [ ] Change quantity → price updates
- [ ] Remove item → item disappears
- [ ] Clear All → cart empties

### 4. Wishlist
- [ ] On product detail, tap heart icon → item added to wishlist
- [ ] Navigate to Wishlist → product card shows with image
- [ ] Tap "Move to Cart" → item moves to cart, removed from wishlist

### 5. Checkout + Order
- [ ] From cart, tap "Proceed to Checkout"
- [ ] Select JazzCash or EasyPaisa
- [ ] (Optional) Enter delivery address
- [ ] Tap "Place Order" → success → redirected to order confirmation
- [ ] Check email for order confirmation

### 6. Payment Proof
- [ ] Open order detail → status is "Pending Payment"
- [ ] View JazzCash/EasyPaisa account numbers
- [ ] Navigate to payment screen → tap upload area → select screenshot from gallery
- [ ] Tap "Submit Payment Proof" → status changes to "Payment Uploaded"

### 7. Quotes
- [ ] Navigate to quote request form → fill all fields → submit
- [ ] Check team receives email notification
- [ ] Navigate to My Quotes → quote appears with "PENDING" status
- [ ] After admin responds (in admin dashboard), quote shows response + price

### 8. Contact
- [ ] Fill contact form → submit
- [ ] Check customer receives auto-reply email
- [ ] Check team receives notification email

### 9. Sign Out
- [ ] Profile screen → Sign Out → redirected to login
- [ ] Re-open app → stays on login (no cached auth)

---

## Troubleshooting

| Issue | Fix |
|---|---|
| "Cannot connect to server" | Check API URL; ensure backend is running on port 5000; check LAN IP for physical device |
| Google Sign-In fails | Verify SHA-1 fingerprint matches your keystore; check `GOOGLE_CLIENT_ID` in backend |
| Images not loading | Check Cloudinary credentials in backend; verify `imageUrl` is not null in product data |
| JWT expired (401) | App auto-clears token and redirects to login; just sign in again |
| `flutter pub get` fails | Check Flutter SDK version; run `flutter upgrade` |
| APK install fails | Enable "Install from unknown sources" on device |
