# ════════════════════════════════════════════════════════════════════════════
#  CONSTITUTION OF FAST PRINTING & PACKAGING MOBILE APPLICATION
#  Version 2.0 — No Firebase Edition
#  XFast Group · Lahore, Pakistan
# ════════════════════════════════════════════════════════════════════════════

---

## TABLE OF CONTENTS

| Article | Title |
|---------|-------|
| I | Identity, Mission & Governing Principles |
| II | Technology Stack & Tooling Decisions |
| III | Architecture & Design Patterns |
| IV | Full Project Directory Structure |
| V | Brand & UI Design System |
| VI | Screen Inventory & Navigation Map |
| VII | Authentication System (Google OAuth 2.0 + JWT) |
| VIII | Backend API — Full Endpoint Reference |
| IX | PostgreSQL Database Schema |
| X | Prisma ORM Rules & Conventions |
| XI | Frontend State Management (BLoC) |
| XII | HTTP Layer — Dio Client & Interceptors |
| XIII | Cart & Wishlist System |
| XIV | Order Lifecycle |
| XV | Payment System (JazzCash & EasyPaisa) |
| XVI | Email System (Nodemailer + Gmail SMTP) |
| XVII | File Upload System (Cloudinary) |
| XVIII | Product & Service Catalog |
| XIX | Industries |
| XX | Contact & Quote System |
| XXI | Security Policies |
| XXII | Environment Variables Reference |
| XXIII | Code Standards & Conventions |
| XXIV | Performance Standards |
| XXV | Deployment & Infrastructure |
| XXVI | Google Play Store Requirements |
| XXVII | Pre-Launch Checklist |
| XXVIII | Amendments & Version History |

---

## PREAMBLE

This Constitutional Document governs the complete architecture, design, data, API, and code standards for the **Fast Printing & Packaging** official mobile application — a product of **XFast Group**, headquartered at 101A J1 Block, Valencia Town, Main Defence Road, Lahore, Pakistan.

This document is the **supreme authority** on all technical decisions. Any contributor, developer, or maintainer working on this codebase must read and follow this constitution in its entirety. Decisions that conflict with this document require a formal amendment (see Article XXVIII).

**Design Principle:** The entire stack runs on free-tier services. No Firebase. No paid APIs. No vendor lock-in beyond Google Sign-In.

---

## ARTICLE I — IDENTITY, MISSION & GOVERNING PRINCIPLES

### 1.1 Application Identity

| Field | Value |
|-------|-------|
| App Name | Fast Printing & Packaging |
| Organisation | XFast Group |
| Package Name | `com.xfastgroup.fastprinting` |
| App Version | 1.0.0+1 |
| Target Platform | Android (Google Play Store) |
| Min Android SDK | API 21 (Android 5.0 Lollipop) |
| Target Android SDK | API 34 (Android 14) |
| Website | https://printing-services-orpin.vercel.app |

### 1.2 Contact & Business Information

| Type | Value |
|------|-------|
| Primary Phone / WhatsApp | +92 325 2467463 |
| Secondary Phone | +92 321 0846667 |
| Business Email | xfastgroup001@gmail.com |
| SMTP Email | fastmediaagencyofficial@gmail.com |
| SMTP App Password | `rlyr jiuf oipr rabz` |
| Address | 101A, J1 Block, Valencia Town, Main Defence Road, Lahore, Pakistan |
| Business Hours | Monday–Saturday: 10:00 AM – 8:00 PM |
| Sunday | Closed |
| JazzCash Account | 0325-2467463 (XFast Group) |
| EasyPaisa Account | 0321-0846667 (XFast Group) |

### 1.3 Mission Statement

Deliver a premium, fast, and intuitive mobile experience that allows customers across Pakistan to browse printing services and products, place orders, and pay securely — all without requiring Firebase or paid cloud infrastructure.

### 1.4 Governing Principles

1. **Free-first:** Every service used must have a viable free tier (Neon, Cloudinary, Gmail SMTP).
2. **No Firebase:** Firebase is permanently excluded from this project. No exceptions.
3. **Ownership:** All tokens, sessions, and user data are managed by our own backend — not a third-party auth provider.
4. **Simplicity:** Prefer one clear pattern over multiple competing approaches.
5. **Security:** Secrets never appear in Flutter code or Git history.

---

## ARTICLE II — TECHNOLOGY STACK & TOOLING DECISIONS

### 2.1 Backend Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Runtime | Node.js | ≥ 20 LTS | Server runtime |
| Language | TypeScript | ≥ 5.5 | Type safety |
| Framework | Express.js | ≥ 4.19 | HTTP routing |
| Database | PostgreSQL | 16 | Relational data store |
| ORM | Prisma | ≥ 5.16 | Type-safe DB queries |
| Auth | google-auth-library | ≥ 9 | Verify Google ID tokens |
| Sessions | jsonwebtoken (JWT) | ≥ 9 | Stateless auth tokens |
| Email | Nodemailer | ≥ 6.9 | Gmail SMTP emails |
| File Upload | Cloudinary SDK | ≥ 2.4 | Payment screenshot storage |
| Security | helmet, cors, express-rate-limit | Latest | HTTP security hardening |
| Logging | Winston | ≥ 3.13 | Structured server logs |
| Process Manager | PM2 (prod) | Latest | Process management |
| Containerisation | Docker + docker-compose | Latest | Dev & prod containers |

### 2.2 Frontend Stack (Flutter)

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Framework | Flutter | ≥ 3.24 | Cross-platform UI |
| Language | Dart | ≥ 3.5 | Application logic |
| State Management | flutter_bloc | ≥ 8.1 | BLoC / Cubit pattern |
| Navigation | go_router | ≥ 14 | Declarative routing |
| HTTP Client | Dio | ≥ 5.4 | API requests |
| Auth | google_sign_in | ≥ 6.2 | Google OAuth flow |
| Token Storage | flutter_secure_storage | ≥ 9.2 | Encrypted JWT storage |
| Local Prefs | shared_preferences | ≥ 2.3 | Flags (first launch, etc.) |
| Images | cached_network_image | ≥ 3.4 | Cached remote images |
| Animations | flutter_animate | ≥ 4.5 | UI transitions |
| Connectivity | connectivity_plus | ≥ 6.0 | Network status detection |
| Image Pick | image_picker | ≥ 1.1 | Payment screenshot upload |
| Links | url_launcher | ≥ 6.3 | WhatsApp / phone / email |
| DI | get_it + injectable | ≥ 8.0 | Dependency injection |

### 2.3 Free Infrastructure

| Service | Provider | Free Limit | Usage |
|---------|----------|-----------|-------|
| PostgreSQL | Neon / Supabase / Railway | 512 MB | Main database |
| File CDN | Cloudinary | 25 GB storage | Payment screenshots |
| Email | Gmail SMTP + App Password | Free | Order & contact emails |
| Hosting | Railway / Render / Fly.io | Free tier | Backend API server |

### 2.4 Rejected Technologies (and why)

| Technology | Reason for Rejection |
|-----------|---------------------|
| Firebase Auth | Vendor lock-in, requires google-services.json, costs money at scale |
| Firebase Firestore | NoSQL doesn't fit our relational data, cost spikes at volume |
| Firebase Storage | Replaced by Cloudinary free tier |
| Firebase Messaging | Removed — notifications handled by order status in-app |
| MongoDB / Mongoose | PostgreSQL + Prisma gives stronger type safety and free hosting |
| AWS / GCP | No free tier that's genuinely free long-term |

---

## ARTICLE III — ARCHITECTURE & DESIGN PATTERNS

### 3.1 Backend Architecture

The backend follows **MVC + Service layer** with clear separation:

```
HTTP Request
    │
    ▼
Router (routes/*.ts)
    │  maps URL + method to controller function
    ▼
Middleware Chain
    │  auth.middleware → validate JWT
    │  rateLimit.middleware → throttle requests
    │  error.middleware → catch unhandled errors
    ▼
Controller (controllers/index.ts)
    │  validates request body
    │  calls Prisma
    │  calls external services (email, cloudinary)
    │  returns standardised response
    ▼
Prisma Client (config/database.ts)
    │  type-safe queries
    ▼
PostgreSQL
```

**One controller file** (`src/controllers/index.ts`) contains all controller functions grouped by domain. This keeps the codebase navigable for a small team.

### 3.2 Frontend Architecture — Clean Architecture

Each feature follows three strict layers:

```
┌─────────────────────────────────────┐
│  PRESENTATION                       │
│  screens/*.dart — widgets + BLoC    │
├─────────────────────────────────────┤
│  DOMAIN  (future expansion)         │
│  use_cases + entities               │
├─────────────────────────────────────┤
│  DATA                               │
│  api_service.dart (Dio + JWT)       │
│  ApiConstants (all endpoints)       │
└─────────────────────────────────────┘
```

**Rules:**
- Screens must never call `ApiService.instance.dio` directly.
- All business logic lives in BLoC/Cubit classes only.
- `ApiConstants` is the single source of truth for every URL — never hardcode a path in a screen file.

### 3.3 State Management Rules

| Rule | Detail |
|------|--------|
| All server calls | Through BLoC events only — never from `initState` or `build()` |
| Loading indicator | Every BLoC must emit a Loading state before async work |
| Error handling | Every BLoC must emit an Error state with human-readable message |
| Optimistic UI | Not used — always wait for server confirmation |
| Shared state | CartBloc is registered as `LazySingleton` via get_it — one instance globally |

### 3.4 Dependency Injection

All dependencies registered in `injection_container.dart` via **get_it**:

```
Singletons (one instance for entire app lifetime):
  GoogleSignIn
  CartBloc

Factories (new instance on each request):
  AuthBloc
```

---

## ARTICLE IV — FULL PROJECT DIRECTORY STRUCTURE

```
fast_printing_app/
│
├── Constitution.md              ← This document (supreme law)
├── README.md                    ← Developer setup guide
│
├── backend/                     ← Node.js + Express + Prisma API
│   ├── prisma/
│   │   └── schema.prisma        ← Complete PostgreSQL schema (9 models)
│   ├── src/
│   │   ├── server.ts            ← App entry point, middleware setup
│   │   ├── config/
│   │   │   ├── database.ts      ← Prisma client singleton + connect/disconnect
│   │   │   ├── google-auth.ts   ← verifyGoogleToken() using google-auth-library
│   │   │   ├── email.ts         ← Nodemailer transporter + HTML templates
│   │   │   └── cloudinary.ts    ← Cloudinary upload helper
│   │   ├── middleware/
│   │   │   ├── auth.middleware.ts    ← JWT verification, attaches req.user
│   │   │   ├── error.middleware.ts   ← Global error handler + authRateLimit
│   │   │   └── rateLimit.middleware.ts ← Re-exports rateLimitMiddleware
│   │   ├── routes/
│   │   │   ├── auth.routes.ts
│   │   │   ├── product.routes.ts
│   │   │   ├── service.routes.ts
│   │   │   ├── cart.routes.ts
│   │   │   ├── wishlist.routes.ts
│   │   │   ├── order.routes.ts
│   │   │   ├── payment.routes.ts
│   │   │   ├── quote.routes.ts
│   │   │   ├── contact.routes.ts
│   │   │   └── industry.routes.ts
│   │   ├── controllers/
│   │   │   └── index.ts         ← All controller functions (grouped by domain)
│   │   └── utils/
│   │       ├── jwt.ts           ← signToken() + verifyToken()
│   │       ├── response.ts      ← sendSuccess, sendError, sendCreated, etc.
│   │       ├── logger.ts        ← Winston logger (coloured dev / JSON prod)
│   │       └── seed.ts          ← Seeds 16 services + 23 products
│   ├── .env.example             ← All env vars documented
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile               ← Multi-stage build
│   └── docker-compose.yml       ← API + PostgreSQL services
│
└── frontend/                    ← Flutter mobile application
    ├── pubspec.yaml             ← Dependencies (no Firebase packages)
    ├── android/
    │   ├── build.gradle         ← Project-level (no google-services plugin)
    │   └── app/
    │       └── build.gradle     ← App-level (package: com.xfastgroup.fastprinting)
    └── lib/
        ├── main.dart            ← Entry point (no Firebase.initializeApp)
        ├── app.dart             ← MaterialApp.router + GoRouter config
        ├── injection_container.dart ← get_it DI setup
        ├── core/
        │   ├── constants/
        │   │   ├── api_constants.dart   ← SINGLE SOURCE for all API URLs
        │   │   ├── app_colors.dart      ← Brand colour palette
        │   │   ├── app_routes.dart      ← Route path constants
        │   │   └── app_strings.dart     ← All UI text strings
        │   ├── network/
        │   │   └── api_service.dart     ← Dio singleton + JWT interceptor
        │   └── theme/
        │       └── app_theme.dart       ← Full MaterialTheme (light)
        └── features/
            ├── auth/
            │   └── presentation/
            │       ├── bloc/auth_bloc.dart      ← Google Sign-In → JWT flow
            │       └── screens/
            │           ├── splash_screen.dart   ← JWT check → routing
            │           ├── onboarding_screen.dart
            │           └── login_screen.dart
            ├── home/
            │   └── presentation/screens/
            │       ├── main_screen.dart        ← Bottom navigation shell
            │       └── home_screen.dart        ← Hero, stats, grids, CTA
            ├── products/
            │   └── presentation/screens/
            │       ├── products_screen.dart    ← 23 products, filter, search
            │       └── product_detail_screen.dart
            ├── services/
            │   └── presentation/screens/
            │       ├── services_screen.dart    ← All 16 services
            │       └── service_detail_screen.dart
            ├── industries/
            │   └── presentation/screens/
            │       └── industries_screen.dart  ← 4 industries + detail
            ├── cart/
            │   └── presentation/screens/
            │       └── cart_screen.dart        ← Cart + CartBloc
            ├── wishlist/
            │   └── presentation/screens/
            │       └── wishlist_screen.dart
            ├── orders/
            │   └── presentation/screens/
            │       └── orders_screen.dart      ← History + OrderDetailScreen
            ├── payment/
            │   └── presentation/screens/
            │       ├── checkout_screen.dart
            │       ├── payment_screen.dart     ← JazzCash/EasyPaisa + upload
            │       └── order_confirmation_screen.dart
            ├── portfolio/
            │   └── presentation/screens/
            │       └── portfolio_screen.dart
            ├── contact/
            │   └── presentation/screens/
            │       ├── contact_screen.dart     ← WhatsApp, call, form, map
            │       └── quote_request_screen.dart
            └── profile/
                └── presentation/screens/
                    └── profile_screen.dart     ← User info + menu + sign out
```

---

## ARTICLE V — BRAND & UI DESIGN SYSTEM

### 5.1 Colour Palette (IMMUTABLE — never deviate)

| Name | Hex | Dart Constant | Usage |
|------|-----|---------------|-------|
| XFast Red | `#C91A20` | `AppColors.primaryRed` | Buttons, accents, icons, headers |
| Red Dark | `#9E141A` | `AppColors.redDark` | Gradient end, pressed states |
| Red Light | `#E8353B` | `AppColors.redLight` | Hover / highlight |
| Red Surface | `#FFF0F0` | `AppColors.redSurface` | Chip backgrounds, info boxes |
| Red Border | `#FFCDD2` | `AppColors.redBorder` | Borders on red-tinted containers |
| White | `#FFFFFF` | `AppColors.white` | Primary background |
| Black | `#000000` | `AppColors.black` | Primary text, dark surfaces |
| Dark Grey | `#1A1A1A` | `AppColors.darkGrey` | Hero sections, dark cards |
| Charcoal | `#2D2D2D` | `AppColors.charcoal` | Gradient start for dark areas |
| Medium Grey | `#666666` | `AppColors.mediumGrey` | Subtitle text |
| Soft Grey | `#999999` | `AppColors.softGrey` | Placeholder text, inactive icons |
| Light Grey | `#F5F5F5` | `AppColors.lightGrey` | Card backgrounds, input fills |
| Border Grey | `#E0E0E0` | `AppColors.borderGrey` | Dividers, borders |
| Divider Grey | `#F0F0F0` | `AppColors.dividerGrey` | Subtle separators |
| Success | `#2E7D32` | `AppColors.success` | Order confirmed, payment verified |
| Warning | `#E65100` | `AppColors.warning` | Pending states |
| Info | `#1565C0` | `AppColors.info` | Informational badges |

### 5.2 Typography

**Heading font:** Poppins (loaded from local assets)
**Body font:** Inter (loaded from local assets)

| Style | Font | Weight | Size | Line Height |
|-------|------|--------|------|-------------|
| Display Large | Poppins | 700 Bold | 32sp | 1.2 |
| Display Medium | Poppins | 600 SemiBold | 28sp | 1.2 |
| Headline Large | Poppins | 700 Bold | 24sp | 1.3 |
| Headline Medium | Poppins | 600 SemiBold | 20sp | 1.3 |
| Headline Small | Poppins | 600 SemiBold | 18sp | 1.3 |
| Title Large | Poppins | 600 SemiBold | 16sp | 1.4 |
| Title Medium | Inter | 500 Medium | 14sp | 1.4 |
| Body Large | Inter | 400 Regular | 16sp | 1.6 |
| Body Medium | Inter | 400 Regular | 14sp | 1.6 |
| Body Small | Inter | 400 Regular | 12sp | 1.5 |
| Label Large | Poppins | 600 SemiBold | 14sp | 1.0 |
| Label Medium | Inter | 500 Medium | 12sp | 1.0 |

### 5.3 Spacing System

All spacing uses an **8px base grid**:

```
xs   = 4px
sm   = 8px
md   = 16px
lg   = 24px
xl   = 32px
xxl  = 48px
xxxl = 64px
```

### 5.4 Border Radius

| Component | Radius |
|-----------|--------|
| Cards | 16px |
| Buttons (all) | 12px |
| Input fields | 12px |
| Chips / Badges | 20px |
| Bottom sheets / Modals | 24px top corners only |
| Small icon containers | 8–12px |
| Circular avatars | 50% |

### 5.5 Elevation & Shadows

```dart
// Standard card shadow
AppColors.cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
]

// Red accent shadow (featured, CTA buttons)
AppColors.redShadow = [
  BoxShadow(
    color: Color(0xFFC91A20).withOpacity(0.25),
    blurRadius: 20,
    offset: Offset(0, 8),
  ),
]

// Elevated surface shadow
AppColors.elevatedShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
]
```

### 5.6 Button Standards

| Type | Background | Text Colour | Height | Font |
|------|-----------|------------|--------|------|
| Primary | `#C91A20` | White | 52px | Poppins SemiBold 15sp |
| Outlined | White | `#C91A20` | 52px | Poppins SemiBold 15sp |
| Ghost | Transparent | Black | 52px | Poppins SemiBold 15sp |
| Disabled | `#E0E0E0` | `#999999` | 52px | Poppins SemiBold 15sp |
| Danger | `#C91A20` | White | 52px | Poppins SemiBold 15sp |

---

## ARTICLE VI — SCREEN INVENTORY & NAVIGATION MAP

### 6.1 Complete Screen List

| # | Screen | File | Tab / Route |
|---|--------|------|-------------|
| 1 | Splash | `splash_screen.dart` | `/` |
| 2 | Onboarding | `onboarding_screen.dart` | `/onboarding` |
| 3 | Login | `login_screen.dart` | `/login` |
| 4 | Home | `home_screen.dart` | `/home` (Tab 1) |
| 5 | Services | `services_screen.dart` | `/services` (Tab 2) |
| 6 | Service Detail | `service_detail_screen.dart` | `/services/:slug` |
| 7 | Products | `products_screen.dart` | `/products` (Tab 3) |
| 8 | Product Detail | `product_detail_screen.dart` | `/products/:id` |
| 9 | Industries | `industries_screen.dart` | `/industries` (Tab 4) |
| 10 | Industry Detail | `IndustryDetailScreen` | `/industries/:slug` |
| 11 | Profile | `profile_screen.dart` | `/profile` (Tab 5) |
| 12 | Cart | `cart_screen.dart` | `/cart` |
| 13 | Wishlist | `wishlist_screen.dart` | `/wishlist` |
| 14 | Checkout | `checkout_screen.dart` | `/checkout` |
| 15 | Payment | `payment_screen.dart` | `/payment` |
| 16 | Order Confirmation | `order_confirmation_screen.dart` | `/order-confirmation/:orderId` |
| 17 | Orders History | `orders_screen.dart` | `/orders` |
| 18 | Order Detail | `OrderDetailScreen` | `/orders/:id` |
| 19 | Portfolio | `portfolio_screen.dart` | `/portfolio` |
| 20 | Contact | `contact_screen.dart` | `/contact` |
| 21 | Quote Request | `quote_request_screen.dart` | `/quote-request` |

### 6.2 Navigation Flow

```
App Launch
  └─ SplashScreen (2.4s animation)
       ├─ has JWT + first launch done  ──→  HomeScreen
       ├─ no JWT + not first launch    ──→  LoginScreen
       └─ first launch ever            ──→  OnboardingScreen (3 slides)
                                               └──→ LoginScreen

LoginScreen
  └─ Google Sign-In button
       └─ Google OAuth popup
            └─ Success → POST /auth/google-login → save JWT
                └──→ HomeScreen (ShellRoute)

HomeScreen (Bottom Navigation — 5 tabs)
  Tab 1 ── Home
  Tab 2 ── Services ── ServiceDetail
  Tab 3 ── Products ── ProductDetail ── Cart ── Wishlist
  Tab 4 ── Industries ── IndustryDetail
  Tab 5 ── Profile ── Orders ── Wishlist ── QuoteRequest ── Contact

Order Flow (from Cart):
  Cart → Checkout → Payment (JazzCash/EasyPaisa)
                        └─ Upload screenshot
                             └─ POST /orders/:id/payment-proof
                                  └──→ OrderConfirmation

Sign Out:
  Profile → Confirm dialog → delete JWT → LoginScreen
```

### 6.3 Bottom Navigation Items

| Index | Label | Icon (inactive / active) | Route |
|-------|-------|--------------------------|-------|
| 0 | Home | home_outlined / home_rounded | `/home` |
| 1 | Services | build_outlined / build_rounded | `/services` |
| 2 | Products | inventory_2_outlined / inventory_2_rounded | `/products` |
| 3 | Industries | business_outlined / business_rounded | `/industries` |
| 4 | Profile | person_outline / person_rounded | `/profile` |

Products tab shows a red badge with cart item count.

---

## ARTICLE VII — AUTHENTICATION SYSTEM

### 7.1 Strategy

**Google OAuth 2.0 → Custom JWT**

No Firebase is involved at any point. The Google ID token is verified server-side using the free `google-auth-library` npm package, which calls Google's public key API. A 30-day JWT is then issued and stored on device in encrypted storage.

### 7.2 Step-by-Step Auth Flow

```
Step 1  (Flutter)
  google_sign_in.signIn()
  → Google opens OAuth consent screen
  → User approves
  → google_sign_in returns GoogleSignInAuthentication
  → Extract: idToken (JWT signed by Google)

Step 2  (Flutter → Backend)
  POST /api/v1/auth/google-login
  Body: { "idToken": "eyJhbGci..." }

Step 3  (Backend: google-auth.ts)
  oauthClient.verifyIdToken({ idToken, audience: GOOGLE_CLIENT_ID })
  → Calls Google's public key endpoint to verify signature
  → Returns: { googleId, email, displayName, photoUrl, emailVerified }

Step 4  (Backend: controllers/index.ts — googleLogin)
  prisma.user.upsert({ where: { googleId }, ... })
  → Creates user on first login
  → Updates displayName/photoUrl on subsequent logins

Step 5  (Backend: utils/jwt.ts)
  signToken({ userId, email, role })
  → Signs HS256 JWT with JWT_SECRET
  → Expiry: 30 days

Step 6  (Backend → Flutter)
  Response: { success: true, data: { token: "eyJ...", user: {...} } }

Step 7  (Flutter: auth_bloc.dart)
  saveToken(jwt) → flutter_secure_storage writes to Android Keystore
  emit(AuthAuthenticated(user: UserModel))

Step 8  (Every subsequent API call)
  Dio interceptor reads token from secure storage
  Appends: Authorization: Bearer eyJ...
```

### 7.3 JWT Specification

| Property | Value |
|----------|-------|
| Algorithm | HS256 |
| Payload fields | `userId`, `email`, `role` |
| Expiry | 30 days (`JWT_EXPIRE` env var) |
| Secret | `JWT_SECRET` env var (minimum 64 chars recommended) |
| Storage (Flutter) | `flutter_secure_storage` → Android Keystore |
| Storage key | `jwt_token` |

### 7.4 Token Refresh Strategy

There is no refresh token. After 30 days, the user is redirected to the login screen. The SplashScreen checks validity by calling `GET /auth/me` — a 401 response triggers logout and navigation to `/login`.

### 7.5 Logout

```dart
// auth_bloc.dart — _onSignOut()
await _googleSignIn.signOut();   // revoke Google session
await deleteToken();              // erase JWT from secure storage
emit(AuthUnauthenticated());
context.go(AppRoutes.login);
```

### 7.6 Protected vs Public Endpoints

| Category | Auth Required | Middleware |
|----------|--------------|-----------|
| `GET /products`, `GET /services`, `GET /industries`, `GET /payment/methods` | ❌ No | None |
| `POST /quotes/request`, `POST /contact` | ❌ No | None |
| Cart, Wishlist, Orders, Profile | ✅ Yes | `authMiddleware` |
| Admin operations | ✅ Yes + ADMIN role | `authMiddleware + adminMiddleware` |

---

## ARTICLE VIII — BACKEND API — FULL ENDPOINT REFERENCE

### 8.1 Base URLs

| Environment | URL |
|-------------|-----|
| Development (emulator) | `http://10.0.2.2:5000/api/v1` |
| Development (device) | `http://192.168.x.x:5000/api/v1` |
| Production | `https://your-server.com/api/v1` |

### 8.2 Standard Response Envelope

Every endpoint returns this structure:

```json
// Success
{
  "success": true,
  "message": "Human-readable success message",
  "data": { ... },
  "pagination": { "page": 1, "limit": 20, "total": 100, "pages": 5 }
}

// Error
{
  "success": false,
  "message": "Human-readable error description",
  "code": "ERROR_CODE_CONSTANT"
}
```

### 8.3 Auth Endpoints

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| POST | `/auth/google-login` | ❌ | `{ idToken }` | Verify Google token, upsert user, return JWT |
| GET | `/auth/me` | ✅ | — | Return current user from DB |
| PUT | `/auth/profile` | ✅ | `{ phone, street, city, province, postalCode }` | Update shipping address & phone |

### 8.4 Product Endpoints

| Method | Path | Auth | Query Params | Description |
|--------|------|------|-------------|-------------|
| GET | `/products` | ❌ | `page, limit, category, search, featured` | Paginated product list |
| GET | `/products/categories` | ❌ | — | Distinct category names |
| GET | `/products/:id` | ❌ | — | Product by ID or slug, includes specs |

### 8.5 Service Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/services` | ❌ | All 16 services ordered by `sortOrder` |
| GET | `/services/:slug` | ❌ | Single service by slug |

### 8.6 Cart Endpoints

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| GET | `/cart` | ✅ | — | Cart items + computed total |
| POST | `/cart/add` | ✅ | `{ productId, productName, quantity, unitPrice, customSpecs?, note? }` | Add item; merges if same productId exists |
| PUT | `/cart/item/:itemId` | ✅ | `{ quantity }` | Update quantity, recalculate totalPrice |
| DELETE | `/cart/item/:itemId` | ✅ | — | Remove single item |
| DELETE | `/cart/clear` | ✅ | — | Delete all items for this user |

### 8.7 Wishlist Endpoints

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| GET | `/wishlist` | ✅ | — | Items with product details |
| POST | `/wishlist/add` | ✅ | `{ productId }` | Add (upsert — no duplicates) |
| DELETE | `/wishlist/:productId` | ✅ | — | Remove from wishlist |
| POST | `/wishlist/move-to-cart/:productId` | ✅ | — | Add product to cart (qty=1), remove from wishlist |

### 8.8 Order Endpoints

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| GET | `/orders` | ✅ | — | User's orders, newest first, with items |
| POST | `/orders` | ✅ | `{ items[], totalAmount, paymentMethod, shipping*, notes? }` | Create order, clear cart, send emails |
| GET | `/orders/:id` | ✅ | — | Single order by `orderId` (e.g. FP-20240601-1234) |
| POST | `/orders/:id/payment-proof` | ✅ | `{ proofBase64, paymentMethod? }` | Upload screenshot to Cloudinary, update status |
| PUT | `/orders/:id/cancel` | ✅ | — | Cancel if not IN_PRODUCTION/SHIPPED/DELIVERED |

### 8.9 Payment Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/payment/methods` | ❌ | Returns JazzCash + EasyPaisa account numbers and step-by-step instructions |

### 8.10 Quote Endpoints

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| POST | `/quotes/request` | ❌ | `{ name, email, phone, product, quantity, size?, material?, specialRequirements?, deliveryLocation?, deadline? }` | Save quote, email team + auto-reply |
| GET | `/quotes/my` | ✅ | — | Logged-in user's quote history |

### 8.11 Contact Endpoints

| Method | Path | Auth | Body | Description |
|--------|------|------|------|-------------|
| POST | `/contact` | ❌ | `{ name, email, phone, service?, message }` | Save to DB, email team, auto-reply to sender |

### 8.12 Industry Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/industries` | ❌ | Static list of 4 industries with product arrays |

---

## ARTICLE IX — POSTGRESQL DATABASE SCHEMA

### 9.1 Tables Overview

| Table | Prisma Model | Primary Key | Notes |
|-------|-------------|-------------|-------|
| `users` | `User` | cuid | Unique on `googleId` + `email` |
| `products` | `Product` | cuid | Unique on `slug` |
| `product_specs` | `ProductSpec` | cuid | FK → products, cascade delete |
| `services` | `Service` | cuid | Unique on `slug` |
| `cart_items` | `CartItem` | cuid | FK → users + products |
| `wishlist_items` | `WishlistItem` | cuid | Unique on `[userId, productId]` |
| `orders` | `Order` | cuid | Unique on `orderId` (FP-YYYYMMDD-XXXX) |
| `order_items` | `OrderItem` | cuid | FK → orders (cascade delete) |
| `payment_proofs` | `PaymentProof` | cuid | No FK relation (orderId is string ref) |
| `quotes` | `Quote` | cuid | Unique on `quoteId` |
| `contact_messages` | `ContactMessage` | cuid | No FK — anonymous allowed |

### 9.2 Enums

```sql
Role:          CUSTOMER | ADMIN
OrderStatus:   PENDING_PAYMENT | PAYMENT_UPLOADED | CONFIRMED |
               IN_PRODUCTION | SHIPPED | DELIVERED | CANCELLED
PaymentMethod: JAZZCASH | EASYPAISA
ProofStatus:   PENDING | VERIFIED | REJECTED
QuoteStatus:   PENDING | REVIEWED | SENT | ACCEPTED | REJECTED
```

### 9.3 Key Relationships

```
User ──(1:many)──> CartItem
User ──(1:many)──> WishlistItem
User ──(1:many)──> Order
User ──(1:many)──> Quote (optional)

Product ──(1:many)──> ProductSpec     (cascade delete)
Product ──(1:many)──> CartItem
Product ──(1:many)──> WishlistItem
Product ──(1:many)──> OrderItem       (optional ref — product may be deleted)

Order ──(1:many)──> OrderItem          (cascade delete)
```

### 9.4 ID Format

All IDs use `cuid()` — collision-resistant, URL-safe, not guessable. Example: `clxyz1234567890abcdef`

Human-readable order IDs are stored separately in `orderId` field:

```
Format:  FP-YYYYMMDD-XXXX
Example: FP-20240601-4721
```

---

## ARTICLE X — PRISMA ORM RULES & CONVENTIONS

### 10.1 Prisma Client Usage

The Prisma client is a **singleton** defined in `src/config/database.ts`. All files that need DB access import `prisma` from this file — never call `new PrismaClient()` anywhere else.

```typescript
// CORRECT
import { prisma } from '../config/database';

// WRONG — never do this in route/controller files
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient(); // ❌
```

### 10.2 Transactions

When multiple operations must succeed or fail together (e.g., create order + clear cart), use `prisma.$transaction`:

```typescript
const [order, _] = await prisma.$transaction([
  prisma.order.create({ ... }),
  prisma.cartItem.deleteMany({ where: { userId } }),
]);
```

### 10.3 After Schema Changes

```bash
# Development — auto-migrate
npm run db:push

# Production — create migration file and apply
npm run db:migrate

# Always regenerate client after schema changes
npm run db:generate
```

### 10.4 Seeding

The seed script at `src/utils/seed.ts` uses `upsert` (not `create`) so it is idempotent — safe to run multiple times:

```bash
npm run db:seed
# Seeds: 16 services + 23 products
# Uses upsert on slug — will not create duplicates
```

---

## ARTICLE XI — FRONTEND STATE MANAGEMENT (BLoC)

### 11.1 BLoC Naming Convention

```
Events:  verb + noun + "Event"      → SignInWithGoogleEvent, LoadCartEvent
States:  adjective/noun + "State"   → AuthLoading, AuthAuthenticated, CartLoaded
BLoCs:   noun + "Bloc" or "Cubit"   → AuthBloc, CartBloc
```

### 11.2 AuthBloc

```
Events:
  CheckAuthStatusEvent  → checks JWT validity via GET /auth/me
  SignInWithGoogleEvent → Google OAuth → POST /auth/google-login → save JWT
  SignOutEvent          → Google signOut + delete JWT + emit Unauthenticated

States:
  AuthInitial           → app just opened, not yet checked
  AuthLoading           → async operation in progress
  AuthAuthenticated     → { UserModel user } — valid JWT + user data
  AuthUnauthenticated   → no JWT or invalid JWT
  AuthError             → { String message } — show SnackBar

UserModel fields:
  id, email, displayName, photoUrl, role
```

### 11.3 CartBloc

```
Events:
  LoadCartEvent         → GET /cart
  AddToCartEvent        → { CartItem item }
  UpdateCartItemEvent   → { String cartItemId, int quantity }
  RemoveFromCartEvent   → { String cartItemId }
  ClearCartEvent        → DELETE /cart/clear

States:
  CartInitial, CartLoading, CartLoaded { List<CartItem> }, CartError

CartItem fields:
  cartItemId, productId, productName, productImage?,
  quantity, unitPrice, totalPrice, customSpecs?, note?
```

### 11.4 BLoC Rules

- BLoC is provided at the **app level** for CartBloc (global state)
- BLoC is provided at the **screen level** for feature-specific blocs
- **Never call API directly from a Widget** — always dispatch an event
- **Never store business logic in setState** — use BLoC for everything

---

## ARTICLE XII — HTTP LAYER — DIO CLIENT & INTERCEPTORS

### 12.1 ApiService

A singleton Dio instance at `lib/core/network/api_service.dart`. One instance for the entire app lifetime.

### 12.2 JWT Interceptor (automatic)

Every outgoing request automatically has the JWT header attached:

```dart
onRequest: (options, handler) async {
  final token = await _storage.read(key: 'jwt_token');
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}
```

This means **no screen or BLoC ever manually sets the Authorization header**. It's always handled transparently.

### 12.3 ApiConstants

`lib/core/constants/api_constants.dart` contains **every endpoint URL** as a static constant or method. This is the **single source of truth** for all paths.

```dart
// Usage in BLoC
final res = await ApiService.instance.dio.post(ApiConstants.googleLogin, data: {...});
final products = await ApiService.instance.dio.get(ApiConstants.products);
final order = await ApiService.instance.dio.get(ApiConstants.orderById(orderId));
```

**Law:** No URL string may appear anywhere outside `api_constants.dart`.

### 12.4 Error Handling

```dart
try {
  final res = await ApiService.instance.dio.get(ApiConstants.cart);
  // handle success
} on DioException catch (e) {
  final msg = e.response?.data?['message'] as String?
      ?? 'Network error. Please check your connection.';
  emit(CartError(message: msg));
}
```

---

## ARTICLE XIII — CART & WISHLIST SYSTEM

### 13.1 Cart Rules

| Rule | Detail |
|------|--------|
| Storage | PostgreSQL `cart_items` table — persists across sessions and devices |
| Per-user | Each user has their own cart rows |
| Duplication | Adding same `productId` again **merges quantities** (not duplicates) |
| Custom specs | Stored as `Json?` column — e.g. `{ "Size": "Standard", "Material": "350gsm" }` |
| Price unit | PKR — all prices are in Pakistani Rupees |
| Max quantity | No hard limit enforced — business decides |
| Cart cleared on | Successful order creation (`POST /orders` calls `deleteMany`) |

### 13.2 Wishlist Rules

| Rule | Detail |
|------|--------|
| Storage | PostgreSQL `wishlist_items` table |
| Uniqueness | Prisma `@@unique([userId, productId])` prevents duplicates |
| Upsert | `prisma.wishlistItem.upsert` is used — safe to call "add" repeatedly |
| Move to cart | `POST /wishlist/move-to-cart/:productId` — creates CartItem with qty=1, then removes wishlist row |

---

## ARTICLE XIV — ORDER LIFECYCLE

### 14.1 Order Status State Machine

```
PENDING_PAYMENT
  └─ Customer uploads payment screenshot
       ↓
  PAYMENT_UPLOADED
  └─ Admin verifies screenshot manually
       ↓
  CONFIRMED
  └─ Team starts printing
       ↓
  IN_PRODUCTION
  └─ Printing complete, handed to courier
       ↓
  SHIPPED
  └─ Customer receives order
       ↓
  DELIVERED

  At any point before IN_PRODUCTION:
  └─ CANCELLED (customer requests, or admin cancels)
```

### 14.2 Order ID Format

```
FP-YYYYMMDD-XXXX
FP = Fast Printing
YYYYMMDD = date created
XXXX = 4-digit random number (1000–9999)

Example: FP-20240601-4721
```

### 14.3 Order Creation Flow

```
1. Customer reviews cart (GET /cart)
2. Customer fills checkout form (shipping address, notes)
3. Customer selects payment method (JAZZCASH or EASYPAISA)
4. POST /orders
   - Validates items, totalAmount, paymentMethod
   - Creates Order + OrderItems in a single transaction
   - Clears user's cart
   - Sends confirmation email to customer
   - Sends notification email to team (fastmediaagencyofficial@gmail.com)
   - Returns: { orderId, order }
5. Flutter navigates to PaymentScreen with orderId + amount
6. Customer transfers money via their banking app
7. Customer uploads screenshot: POST /orders/:id/payment-proof
   - Uploads base64 image to Cloudinary
   - Updates order status to PAYMENT_UPLOADED
   - Saves PaymentProof record
   - Emails team to verify
8. Flutter navigates to OrderConfirmationScreen
```

---

## ARTICLE XV — PAYMENT SYSTEM

### 15.1 Philosophy

Fast Printing uses **manual bank transfer** only. There is no automated payment gateway. This is by design — it matches current business operations and requires zero setup fees.

### 15.2 Payment Accounts

| Method | Account Number | Account Name |
|--------|---------------|-------------|
| JazzCash | 0325-2467463 | XFast Group |
| EasyPaisa | 0321-0846667 | XFast Group |

**Security Rule:** These numbers are **never hardcoded in Flutter**. They are fetched from `GET /payment/methods` which reads from `.env` server-side.

### 15.3 Payment Flow in App

```
PaymentScreen receives: { orderId, amount, paymentMethod }
  ↓
Shows account number + exact amount (copy button on each)
Shows step-by-step transfer instructions
  ↓
Customer completes bank transfer in their JazzCash/EasyPaisa app
  ↓
Customer taps "Upload Payment Screenshot"
  → image_picker opens gallery
  → Selected image converted to base64
  → POST /orders/:id/payment-proof { proofBase64, paymentMethod }
  → Backend: base64 → Cloudinary → secure_url stored in DB
  → Order status → PAYMENT_UPLOADED
  ↓
Navigate to OrderConfirmationScreen
  Shows orderId, "We'll verify within 1-2 hours" message
```

### 15.4 Verification (Manual by Admin)

Admin receives email → opens Cloudinary URL → verifies amount matches → updates order status to CONFIRMED in the admin panel (future feature) or directly in Prisma Studio.

---

## ARTICLE XVI — EMAIL SYSTEM (NODEMAILER + GMAIL SMTP)

### 16.1 Configuration

| Setting | Value |
|---------|-------|
| Host | `smtp.gmail.com` |
| Port | 587 (STARTTLS) |
| User | `fastmediaagencyofficial@gmail.com` |
| Password | Gmail App Password: `rlyr jiuf oipr rabz` |
| From name | `Fast Printing & Packaging` |

**Note:** An App Password is different from your Gmail password. Enable 2FA → Google Account → Security → App Passwords → Generate.

### 16.2 Email Templates (all in `src/config/email.ts`)

| Function | Trigger | Recipients |
|----------|---------|-----------|
| `orderConfirmationHtml` | `POST /orders` success | Customer |
| `adminNewOrderHtml` | `POST /orders` success | Admin team |
| `paymentVerifiedHtml` | Future: admin confirms payment | Customer |
| `quoteReceivedHtml` | `POST /quotes/request` | Customer (auto-reply) |
| Admin quote notification | `POST /quotes/request` | Admin team |
| `contactAutoReplyHtml` | `POST /contact` | Customer (auto-reply) |
| Admin contact notification | `POST /contact` | Admin team |

### 16.3 Non-Blocking Rule

All `sendEmail()` calls are **fire-and-forget** — they do not use `await` in the main flow. Email failure must never cause an order creation or quote submission to fail:

```typescript
// CORRECT — non-blocking
sendEmail({ to: user.email, subject: '...', html: '...' });

// WRONG — blocks and can fail the request
await sendEmail({ ... }); // ❌
```

---

## ARTICLE XVII — FILE UPLOAD SYSTEM (CLOUDINARY)

### 17.1 Usage

Cloudinary is used **only** for payment proof screenshots. Product images are managed manually through the admin interface or direct DB entry.

### 17.2 Upload Specification

| Setting | Value |
|---------|-------|
| Folder | `fast-printing/payment-proofs` |
| Allowed formats | jpg, jpeg, png, webp |
| Max file size | 5 MB |
| Transformation | `quality: auto, fetch_format: auto` |
| Access | Public URL (returned as `secure_url`) |

### 17.3 Flutter → Backend Upload

Flutter sends the image as a **base64 string** in the request body. The backend decodes and uploads to Cloudinary. This avoids multipart/form-data complexity.

```typescript
// backend/src/config/cloudinary.ts
const result = await cloudinary.uploader.upload(base64Data, {
  folder: 'fast-printing/payment-proofs',
  ...
});
return result.secure_url;
```

---

## ARTICLE XVIII — PRODUCT & SERVICE CATALOG

### 18.1 The 16 Official Services

| # | Name | Slug |
|---|------|------|
| 1 | Digital Printing | `digital-printing` |
| 2 | Offset Printing | `offset-printing` |
| 3 | Screen Printing | `screen-printing` |
| 4 | Large Format Printing | `large-format-printing` |
| 5 | Custom Boxes | `custom-boxes` |
| 6 | Labels and Stickers | `labels-stickers` |
| 7 | Bags and Pouches | `bags-pouches` |
| 8 | Eco Friendly Packaging | `eco-friendly-packaging` |
| 9 | Brand Identity | `brand-identity` |
| 10 | Logo Design | `logo-design` |
| 11 | Packaging Design | `packaging-design` |
| 12 | Marketing Materials | `marketing-materials` |
| 13 | Business Printing | `business-printing` |
| 14 | Promotional Products | `promotional-products` |
| 15 | Speciality Printing | `speciality-printing` |
| 16 | Flexography | `flexography` |

### 18.2 The 23 Official Products

| # | Name | Category | Starting Price |
|---|------|----------|---------------|
| 1 | Business Cards | Business Printing | PKR 1,500 / 100 |
| 2 | Brochures | Marketing | PKR 2,500 / 100 |
| 3 | Flyers | Marketing | PKR 800 / 100 |
| 4 | Posters | Large Format | PKR 1,200 / piece |
| 5 | Banners | Large Format | PKR 2,000 / piece |
| 6 | Custom Boxes | Packaging | Custom Quote |
| 7 | Stickers and Labels | Labels | PKR 500 / 100 |
| 8 | Letterheads | Business Printing | PKR 1,200 / 100 |
| 9 | Envelopes | Business Printing | PKR 900 / 100 |
| 10 | Presentation Folders | Business Printing | PKR 3,500 / 50 |
| 11 | Catalogs | Marketing | PKR 5,000 / 50 |
| 12 | Roll-Up Banners | Large Format | PKR 3,500 / piece |
| 13 | Window Graphics | Large Format | Custom Quote |
| 14 | Wall Graphics | Large Format | Custom Quote |
| 15 | Shopping Bags | Packaging | PKR 2,000 / 100 |
| 16 | Food Packaging | Packaging | Custom Quote |
| 17 | Wedding Cards | Speciality | PKR 5,000 / 100 |
| 18 | Calendars | Speciality | PKR 1,800 / 50 |
| 19 | Notepads | Business Printing | PKR 1,500 / 50 |
| 20 | Certificates | Speciality | PKR 2,500 / 100 |
| 21 | Tissue Papers | Packaging | PKR 3,000 / 100 |
| 22 | Bill Books | Business Printing | PKR 1,200 / 50 |
| 23 | Flag Printing | Large Format | Custom Quote |

All products and services are **seeded automatically** via `npm run db:seed`. The seed uses `upsert` on slug — idempotent and safe to re-run.

---

## ARTICLE XIX — INDUSTRIES

### 19.1 The 4 Official Industries

| # | Name | Slug | Target Customers |
|---|------|------|-----------------|
| 1 | Schools & Education | `schools-education` | Schools, colleges, universities, tutoring centres |
| 2 | Healthcare & Medical | `healthcare-medical` | Hospitals, clinics, pharmacies, diagnostic labs |
| 3 | Restaurants & Food | `restaurants-food` | Restaurants, cafes, bakeries, food delivery brands |
| 4 | Retail & E-commerce | `retail-ecommerce` | Online stores, retail shops, boutiques, startups |

Industries are returned as **static JSON** from `GET /industries` — no DB table. The IndustriesScreen also displays them from the Flutter `_industries` constant in `industries_screen.dart`.

---

## ARTICLE XX — CONTACT & QUOTE SYSTEM

### 20.1 Contact Form Fields

| Field | Required | Validation |
|-------|----------|-----------|
| name | ✅ | Non-empty |
| email | ✅ | Contains @ |
| phone | ✅ | Non-empty |
| service | ❌ | Dropdown — 16 services |
| message | ✅ | Min 20 characters |

On submission: saved to `contact_messages` table + email to team + auto-reply to sender.

### 20.2 Quick Contact Options (ContactScreen)

| Option | Action |
|--------|--------|
| WhatsApp | `https://wa.me/923252467463?text=Hello...` |
| Call | `tel:+923210846667` |
| Email | `mailto:xfastgroup001@gmail.com` |
| Maps | Google Maps search for full address |
| Get Quote | Navigate to `/quote-request` |

### 20.3 Quote Request Form Fields

| Field | Required |
|-------|----------|
| name | ✅ |
| email | ✅ |
| phone | ✅ |
| product (dropdown — 23 products) | ✅ |
| quantity | ✅ |
| size / dimensions | ❌ |
| material preference | ❌ |
| specialRequirements | ❌ |
| deliveryLocation | ❌ |
| deadline | ❌ |

Quote ID format: `QT-{unix_timestamp}` (e.g. `QT-1717200000000`)

---

## ARTICLE XXI — SECURITY POLICIES

### 21.1 Backend Security Checklist

| Rule | Implementation |
|------|----------------|
| HTTP security headers | `helmet()` middleware on all routes |
| CORS | Only `ALLOWED_ORIGINS` env var (comma-separated) |
| Rate limiting | 100 requests / 15 min per IP (`rateLimitMiddleware`) |
| Auth rate limiting | 10 requests / 15 min for `/auth/*` (`authRateLimit`) |
| JWT verification | Every protected route: `authMiddleware` reads + verifies token |
| Admin gate | `adminMiddleware` checks `req.user.role === 'ADMIN'` |
| Secrets in env only | No secret, key, or account number in source code |
| Payment accounts | Only served via `/payment/methods` from `.env` — never in Flutter |
| File upload limit | Max 5MB, JPEG/PNG/WebP only (Cloudinary enforced) |
| SQL injection | Impossible — Prisma uses parameterised queries exclusively |
| Input validation | Request body validated in controllers before DB operations |

### 21.2 Flutter Security Checklist

| Rule | Implementation |
|------|----------------|
| JWT storage | `flutter_secure_storage` → Android Keystore (encrypted) |
| Never hardcode API keys | Use `ApiConstants` only — no string literals in screens |
| Never hardcode payment numbers | Fetch from `GET /payment/methods` at runtime |
| HTTPS only in production | Dio `BaseOptions` — base URL must be `https://` in prod |
| Token auto-attached | Dio interceptor — developers never manually set auth header |
| Token on logout | `deleteToken()` called — cleared from Keystore |

### 21.3 Git Security Rules

- `.env` is in `.gitignore` — NEVER committed
- `firebase-service-account.json` does not exist in this project
- No API keys, passwords, or tokens in any `.dart` or `.ts` file

---

## ARTICLE XXII — ENVIRONMENT VARIABLES REFERENCE

```bash
# ─── SERVER ──────────────────────────────────────────────────────────────────
PORT=5000                          # Express listen port
NODE_ENV=development               # development | production

# ─── DATABASE ────────────────────────────────────────────────────────────────
# Free PostgreSQL options:
#   Neon:     https://neon.tech           → free 512 MB
#   Supabase: https://supabase.com        → free 500 MB
#   Railway:  https://railway.app         → free $5 credit/mo
DATABASE_URL="postgresql://USER:PASS@HOST:5432/fastprinting?sslmode=require"

# ─── GOOGLE OAUTH 2.0 ─────────────────────────────────────────────────────────
# Setup: console.cloud.google.com → APIs & Services → Credentials
# Create OAuth 2.0 Client ID → Android → Package: com.xfastgroup.fastprinting
GOOGLE_CLIENT_ID=123456789-abc.apps.googleusercontent.com

# ─── JWT ─────────────────────────────────────────────────────────────────────
JWT_SECRET=use_minimum_64_random_characters_here_for_hs256_security
JWT_EXPIRE=30d                     # token validity period

# ─── EMAIL (Gmail SMTP) ───────────────────────────────────────────────────────
# App Password: Google Account → Security → 2FA → App Passwords
EMAIL_USER=fastmediaagencyofficial@gmail.com
EMAIL_PASS=rlyr jiuf oipr rabz    # Gmail App Password (not Gmail login password)

# ─── CLOUDINARY ───────────────────────────────────────────────────────────────
# Signup: https://cloudinary.com/users/register/free
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# ─── PAYMENT ACCOUNTS (served from backend only — not in Flutter) ─────────────
JAZZCASH_NUMBER=0325-2467463
EASYPAISA_NUMBER=0321-0846667
PAYMENT_ACCOUNT_NAME=XFast Group

# ─── RATE LIMITING ────────────────────────────────────────────────────────────
RATE_LIMIT_WINDOW_MS=900000        # 15 minutes in ms
RATE_LIMIT_MAX=100                 # max requests per window

# ─── CORS ────────────────────────────────────────────────────────────────────
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

---

## ARTICLE XXIII — CODE STANDARDS & CONVENTIONS

### 23.1 TypeScript / Backend

| Rule | Example |
|------|---------|
| File names | `kebab-case.ts` |
| Functions | `camelCase` |
| Classes / Interfaces | `PascalCase` |
| Constants | `SCREAMING_SNAKE_CASE` |
| Async controllers | Always `async (req, res): Promise<void>` |
| Response | Always use `sendSuccess` / `sendError` from `utils/response.ts` |
| Logging | Always use `logger` from `utils/logger.ts` — never `console.log` |
| Try/catch | Every async controller must have try/catch with meaningful error message |

### 23.2 Dart / Flutter

| Rule | Example |
|------|---------|
| File names | `snake_case.dart` |
| Classes | `PascalCase` |
| Variables / methods | `camelCase` |
| Private members | `_privateVariable` |
| Constants | `kConstantName` or `SCREAMING_SNAKE_CASE` |
| Widget files | One widget class per file |
| Max widget build() length | 100 lines — extract sub-widgets if longer |
| Never `print()` | Use `Logger` package only |

### 23.3 BLoC Naming

```dart
// Events — always suffix "Event"
class CheckAuthStatusEvent extends AuthEvent {}
class AddToCartEvent extends CartEvent { final CartItem item; }

// States — always suffix "State" (or use descriptive name)
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState { final UserModel user; }

// BLoCs — always suffix "Bloc" or "Cubit"
class AuthBloc extends Bloc<AuthEvent, AuthState> {}
class CartBloc extends Bloc<CartEvent, CartState> {}
```

### 23.4 API Calls — Always Through ApiConstants

```dart
// ✅ CORRECT
final res = await ApiService.instance.dio.get(ApiConstants.products);

// ❌ WRONG — hardcoded URL
final res = await dio.get('http://10.0.2.2:5000/api/v1/products');
```

### 23.5 Git Branch Naming

```
feature/add-order-tracking
fix/cart-quantity-overflow
refactor/auth-bloc-cleanup
hotfix/payment-screen-null-crash
chore/update-dependencies
```

### 23.6 Commit Message Format

```
type(scope): short description

feat(auth): add Google Sign-In with JWT backend
fix(cart): resolve quantity going negative on removal
refactor(orders): extract order status widget
chore(deps): update Prisma to 5.17
```

---

## ARTICLE XXIV — PERFORMANCE STANDARDS

### 24.1 Backend Targets

| Metric | Target |
|--------|--------|
| API response time (P95) | < 300ms |
| DB query time (simple) | < 50ms |
| DB query time (complex join) | < 150ms |
| Cold start (Node.js) | < 2 seconds |
| Email send | Non-blocking — max 3s, doesn't affect response |
| Cloudinary upload | < 5 seconds for 5MB |
| Uptime | ≥ 99% on free hosting |

### 24.2 Flutter Targets

| Metric | Target |
|--------|--------|
| App cold start | < 2.5 seconds |
| Screen transition | < 300ms |
| Scroll performance | 60fps minimum |
| List render (20 items) | < 500ms |
| API call perceived response | Shimmer shown within 100ms |
| APK size | < 30 MB |
| Image loads (cached) | < 200ms |

### 24.3 Image Optimisation

- Product images: max 800×800px, WebP preferred
- Thumbnails: 300×300px
- Use `CachedNetworkImage` for all remote images
- Payment screenshots compressed via Cloudinary's `quality: auto`
- Never load full-resolution in lists — use thumbnail URL when available

---

## ARTICLE XXV — DEPLOYMENT & INFRASTRUCTURE

### 25.1 Backend Deployment Options (all free)

| Provider | Free Tier | Notes |
|----------|-----------|-------|
| Railway | $5 credit/mo | Easiest — connects to GitHub, auto-deploys |
| Render | 750 hrs/mo | Sleeps after 15min inactivity on free tier |
| Fly.io | 3 shared VMs | Best performance on free tier |
| Koyeb | 1 instance free | EU/US regions |

### 25.2 Database Hosting Options (all free)

| Provider | Free Tier | Notes |
|----------|-----------|-------|
| **Neon** (recommended) | 512 MB, 1 project | Serverless PostgreSQL, never sleeps |
| Supabase | 500 MB, 2 projects | Has built-in Studio UI |
| Railway | $5 credit/mo | Same provider as backend |

### 25.3 Docker Deployment (Self-Hosted)

```bash
# Production with Docker Compose
docker-compose up -d

# This starts:
#   - fast_printing_api (Node.js on port 5000)
#   - fast_printing_postgres (PostgreSQL on port 5432)

# After first deploy, seed the database:
docker exec fast_printing_api npx ts-node src/utils/seed.ts
```

### 25.4 Backend Production Checklist

```
[ ] NODE_ENV=production in .env
[ ] DATABASE_URL points to production PostgreSQL (sslmode=require)
[ ] JWT_SECRET is a 64+ character random string
[ ] GOOGLE_CLIENT_ID is the production OAuth credential
[ ] CLOUDINARY_* values are set
[ ] EMAIL_USER and EMAIL_PASS are set
[ ] ALLOWED_ORIGINS includes the Flutter app's domain / * for mobile
[ ] npm run db:push run on production database
[ ] npm run db:seed run to populate services + products
[ ] npm run build succeeds with zero TypeScript errors
[ ] GET /health returns { status: "ok" }
```

---

## ARTICLE XXVI — GOOGLE PLAY STORE REQUIREMENTS

### 26.1 App Configuration

| Requirement | Value |
|-------------|-------|
| Application ID | `com.xfastgroup.fastprinting` |
| Min SDK | 21 (Android 5.0) |
| Target SDK | 34 (Android 14) |
| multiDexEnabled | true |
| Version name | `1.0` |
| Version code | `1` |

### 26.2 Google OAuth Setup for Production

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. APIs & Services → Credentials → Create Credentials → OAuth 2.0 Client ID
3. Application type: **Android**
4. Package name: `com.xfastgroup.fastprinting`
5. SHA-1 certificate fingerprint (from **release** keystore):
   ```bash
   keytool -list -v -keystore android/app/fast-printing-key.jks \
     -alias fast-printing
   ```
6. Copy the resulting **Client ID** → set as `GOOGLE_CLIENT_ID` in backend `.env`

### 26.3 Release Build Steps

```bash
# Step 1 — Generate keystore (one time only)
keytool -genkey -v \
  -keystore android/app/fast-printing-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias fast-printing \
  -dname "CN=XFast Group, O=XFast Group, L=Lahore, ST=Punjab, C=PK"

# Step 2 — Create android/key.properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fast-printing
storeFile=fast-printing-key.jks

# Step 3 — Build release AAB for Play Store
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 26.4 Play Store Assets Required

| Asset | Specification |
|-------|--------------|
| App icon | 512×512px PNG |
| Feature graphic | 1024×500px |
| Screenshots | Minimum 2, maximum 8 (phone) |
| Privacy Policy URL | Required before publish |
| Short description | Max 80 characters |
| Full description | Max 4000 characters |

---

## ARTICLE XXVII — PRE-LAUNCH CHECKLIST

### 27.1 Backend

```
[ ] All TypeScript compiles: npm run build (zero errors)
[ ] Health check responds: GET /health → { status: "ok" }
[ ] Database connected: Prisma can run a simple query
[ ] All 16 services seeded: GET /services returns 16 items
[ ] All 23 products seeded: GET /products returns 23 items
[ ] Google OAuth verified: POST /auth/google-login succeeds with real token
[ ] JWT issued and accepted: protected route works with token
[ ] Cart CRUD works: add → update → remove → clear
[ ] Wishlist CRUD works: add → move-to-cart → remove
[ ] Order creation works: POST /orders creates order and clears cart
[ ] Payment methods returned: GET /payment/methods shows both accounts
[ ] Email sending works: quote request triggers both emails
[ ] Cloudinary upload works: payment proof uploads and returns URL
[ ] Rate limiting active: > 100 requests/15min returns 429
[ ] CORS configured for production origin
[ ] NODE_ENV=production
[ ] No console.log in production code (only Winston logger)
```

### 27.2 Flutter

```
[ ] flutter pub get succeeds with no errors
[ ] App launches on Android emulator (API 21 minimum)
[ ] App launches on physical Android device
[ ] Splash screen shows then navigates correctly
[ ] Onboarding shows on first launch, skips on subsequent
[ ] Google Sign-In completes and user data shows in Profile
[ ] JWT stored — app stays logged in after force-close
[ ] Home screen loads all sections
[ ] All 16 services visible in ServicesScreen
[ ] All 23 products visible in ProductsScreen
[ ] Filter chips work on ProductsScreen
[ ] Search works on ProductsScreen
[ ] Add to cart from ProductDetailScreen works
[ ] Cart shows item count badge on Products tab
[ ] Cart add / quantity update / remove / clear all work
[ ] Wishlist add and remove work
[ ] Move wishlist item to cart works
[ ] Checkout screen loads with correct total
[ ] Payment screen shows correct account number (from API, not hardcoded)
[ ] Copy button copies account number to clipboard
[ ] Screenshot upload from gallery works
[ ] Order confirmation screen shows correct orderId
[ ] Contact form sends (check email inbox)
[ ] WhatsApp button opens WhatsApp app
[ ] Phone button initiates call
[ ] Quote request form submits (check email inbox)
[ ] Sign out clears JWT and returns to login screen
[ ] App handles no-internet gracefully (shows error, not crash)
[ ] Colors match brand palette (#C91A20, #FFFFFF, #000000)
[ ] Poppins and Inter fonts loading correctly
[ ] All screens scroll smoothly without jank
[ ] No print() calls in production build
[ ] flutter build apk --release succeeds
[ ] flutter build appbundle --release succeeds
[ ] Release APK installs and runs on a physical device
```

---

## ARTICLE XXVIII — AMENDMENTS & VERSION HISTORY

### 28.1 Amendment Process

This document may only be amended by:

1. A written proposal describing the change and the reason
2. Review and approval by the lead developer + XFast Group management
3. Update of the relevant article(s) in this file
4. Version bump in the table below
5. Commit message: `docs(constitution): amendment — [brief description]`

No code change that contradicts this document is permitted without a prior amendment.

### 28.2 Version History

| Version | Date | Author | Summary of Changes |
|---------|------|--------|-------------------|
| 1.0 | 2025 | Dev Team | Initial constitution — Firebase stack |
| 2.0 | 2025 | Dev Team | Complete rewrite — Firebase removed, PostgreSQL + Prisma + JWT, all articles updated to reflect final codebase |

---

*This Constitution is the supreme governing document of the Fast Printing & Packaging mobile application. All contributors must read and comply with its provisions. In case of conflict between this document and any other document, this Constitution prevails.*

---

**XFast Group — Fast Printing & Packaging**
101A, J1 Block, Valencia Town, Main Defence Road, Lahore, Pakistan
xfastgroup001@gmail.com · +92 325 2467463 (WhatsApp)
https://printing-services-orpin.vercel.app
