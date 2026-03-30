# Research: Fast Printing & Packaging — Complete App Flow

**Feature**: 001-complete-app-flow
**Date**: 2026-03-27
**Status**: Complete — all decisions resolved, no NEEDS CLARIFICATION remaining

---

## 1. Authentication Architecture

**Decision**: Google OAuth 2.0 → backend-issued JWT (30-day expiry)

**Rationale**: Eliminates password management, leverages Google's trusted identity
infrastructure, and keeps XFast in full control of session tokens. Firebase Auth is
explicitly prohibited by the project constitution.

**Flow**:
1. Flutter `google_sign_in` prompts the user — no `google-services.json` required
2. Flutter receives a Google `idToken` (short-lived, signed by Google)
3. Flutter POSTs `{ idToken }` to `POST /api/v1/auth/google-login`
4. Backend verifies the `idToken` using `google-auth-library` (free Google public key API)
5. Backend upserts the user in PostgreSQL, signs a 30-day JWT with `jsonwebtoken`
6. Flutter stores the JWT in `flutter_secure_storage` (hardware-backed keystore on Android)
7. All subsequent API calls include `Authorization: Bearer <jwt>`

**Alternatives considered**:
- Firebase Auth: Rejected (NON-NEGOTIABLE in constitution — vendor lock-in, cost at scale)
- Email/password: Rejected (increases friction; Google covers all Pakistani users)
- Supabase Auth: Rejected (adds another vendor dependency; own JWT is cleaner)

---

## 2. Database — Schema Additions Required

**Decision**: Extend existing `schema.prisma` with the following additions for Article VIII compliance:

```prisma
// Add imageUrl to Product (products already use images String[] — Article VIII
// requires a primary imageUrl String? for admin-managed Cloudinary URL)
model Product {
  imageUrl String?   // primary Cloudinary image (admin-managed)
  // images String[] retained for multi-image future use
}

// Add imageUrl to Service
model Service {
  imageUrl String?
}

// New model: Category (currently stored as String on Product)
model Category {
  id          String    @id @default(cuid())
  name        String    @unique
  slug        String    @unique
  description String?
  imageUrl    String?
  sortOrder   Int       @default(0)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  products    Product[]
}

// New model: Industry (currently stored as String[] on Product)
model Industry {
  id          String   @id @default(cuid())
  name        String   @unique
  slug        String   @unique
  description String?
  imageUrl    String?
  sortOrder   Int      @default(0)
  createdAt   DateTime @default(now())
}
```

**Rationale**: Article VIII of the constitution mandates `imageUrl String?` on Product,
Service, Category, and Industry. Category and Industry are currently implicit (stored as
strings); extracting them to proper models enables admin CRUD and image management.

**Migration approach**: `npx prisma db push` for dev; migration file for production.
The seed script must be updated to populate Category and Industry records.

---

## 3. Image Upload Architecture

**Decision**: Backend-mediated Cloudinary upload via `multer` + Cloudinary SDK

**Flow**:
```
Admin Panel → multipart/form-data POST
  → Express multer (memory storage, 5 MB limit)
    → Cloudinary SDK uploader (folder: /products|/services|/categories|/industries)
      → Returns secure_url
        → Backend saves secure_url to DB column imageUrl
          → Returns { success: true, data: { imageUrl: "https://res.cloudinary.com/..." } }
```

**Rationale**: Direct-from-browser Cloudinary uploads would expose the API secret.
The backend acts as the secure upload proxy per Article VIII of the constitution.

**Cloudinary configuration**:
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` in `.env`
- Upload preset: none (using signed upload via SDK)
- Folder structure: `/products`, `/services`, `/categories`, `/industries`
- Transformation: auto format + quality optimization on upload

**Alternatives considered**:
- Direct browser upload with unsigned preset: Rejected (exposes upload capabilities; Article VIII forbids it)
- AWS S3: Rejected (no genuine free tier; Article I forbids it)
- Base64 in JSON body: Supported as fallback but multipart preferred for efficiency

---

## 4. Email Notifications

**Decision**: Nodemailer + Gmail SMTP with App Password

**Triggers**:
| Event | Recipient | Type |
|-------|-----------|------|
| Order placed | Customer | Confirmation email with order details |
| Quote submitted | XFast team | New quote notification |
| Contact message | XFast team | Message content |
| Contact message | Customer | Auto-reply confirmation |

**Configuration**:
- `EMAIL_USER=fastmediaagencyofficial@gmail.com`
- `EMAIL_PASS=rlyr jiuf oipr rabz` (Gmail App Password — not the account password)
- Emails sent asynchronously (non-blocking to API response)

**Alternatives considered**:
- SendGrid: Has free tier but adds vendor dependency; Gmail SMTP is zero-cost and sufficient
- Firebase Cloud Messaging: Rejected (NON-NEGOTIABLE — no Firebase)

---

## 5. State Management — Flutter

**Decision**: flutter_bloc (BLoC pattern) with get_it + injectable for DI

**BLoC registry**:
| BLoC/Cubit | Scope | Responsibility |
|------------|-------|----------------|
| `AuthBloc` | Factory | Sign-in, sign-out, session check |
| `ProductBloc` | LazySingleton | Product list, filters, search, detail |
| `ServiceBloc` | LazySingleton | Service list and detail |
| `CartBloc` | LazySingleton | Cart CRUD, total calculation |
| `WishlistBloc` | LazySingleton | Wishlist add/remove/move |
| `OrderBloc` | Factory | Order placement, history, detail, cancel |
| `PaymentBloc` | Factory | Upload proof, view methods |
| `QuoteBloc` | Factory | Submit quote, view my quotes |
| `ContactCubit` | Factory | Submit contact form |
| `IndustryCubit` | LazySingleton | Industry list |
| `CategoryCubit` | LazySingleton | Category list |

**Rules** (Article V of constitution):
- Every BLoC emits `Loading` before async work
- Every BLoC emits `Error` with human-readable message on failure
- No direct API calls from `build()`, `initState()`, or widget constructors
- `CartBloc` is a global singleton — one instance across the app lifetime

---

## 6. Navigation — Flutter

**Decision**: `go_router` with authentication guard

**Route structure**:
```
/                     → HomeScreen (requires auth)
/login                → LoginScreen (public)
/products             → ProductListScreen
/products/:id         → ProductDetailScreen
/services             → ServiceListScreen
/services/:slug       → ServiceDetailScreen
/cart                 → CartScreen (requires auth)
/wishlist             → WishlistScreen (requires auth)
/orders               → OrderHistoryScreen (requires auth)
/orders/:id           → OrderDetailScreen (requires auth)
/orders/:id/payment   → PaymentUploadScreen (requires auth)
/quotes               → MyQuotesScreen (requires auth)
/quotes/request       → QuoteRequestScreen (public)
/contact              → ContactScreen (public)
/industries           → IndustryScreen
/profile              → ProfileScreen (requires auth)
```

**Auth guard**: `go_router` `redirect` checks JWT existence in `flutter_secure_storage`.
If missing, redirects to `/login`. After sign-in, redirects to original destination.

---

## 7. Admin Dashboard Architecture

**Decision**: React 18 + Vite + TypeScript SPA, deployed to Vercel/Netlify

**State management split**:
- TanStack Query (React Query v5): All server state — products, orders, users, quotes
- Zustand: UI state — auth token, sidebar open/close, modal state

**Page structure**:
```
/login               → AdminLoginPage
/                    → DashboardPage (metrics, recent activity)
/products            → ProductListPage
/products/new        → ProductFormPage
/products/:id/edit   → ProductFormPage
/services            → ServiceListPage
/services/:id/edit   → ServiceFormPage
/categories          → CategoryListPage
/industries          → IndustryListPage
/orders              → OrderListPage
/orders/:id          → OrderDetailPage (payment verification)
/quotes              → QuoteListPage
/quotes/:id          → QuoteDetailPage
/contacts            → ContactListPage
/users               → UserListPage
```

**Auth**: Same Google Sign-In flow → POSTs idToken to backend → receives JWT →
stored in `localStorage` → Axios interceptor attaches `Authorization: Bearer <jwt>`.
If `role !== ADMIN`, redirect to a "not authorised" page.

---

## 8. API Structure

**Decision**: MVC + Service layer, all controllers in `src/controllers/index.ts`

**Route files** (one per domain):
```
src/routes/
├── auth.routes.ts
├── products.routes.ts
├── services.routes.ts
├── categories.routes.ts
├── industries.routes.ts
├── cart.routes.ts
├── wishlist.routes.ts
├── orders.routes.ts
├── payment.routes.ts
├── quotes.routes.ts
├── contact.routes.ts
└── admin.routes.ts       ← image upload + admin management endpoints
```

**Middleware stack** (applied in order):
1. `helmet()` — security headers
2. `cors()` — allow Flutter app origin + admin dashboard origin
3. `express.json()` — parse JSON bodies
4. `rateLimiter` — auth endpoints only (via `express-rate-limit`)
5. `authenticateToken` — parses and verifies JWT, attaches `req.user`
6. `requireAdmin` — checks `req.user.role === 'ADMIN'`

---

## 9. Performance & Offline Strategy

**Decision**: Standard RESTful caching + Flutter `cached_network_image`

- Images served from Cloudinary CDN — global edge caching, no backend load
- `cached_network_image` caches images locally on device after first load
- Product list and service list are paginated (default 20 items, `?page=&limit=`)
- No offline mode required per spec assumptions; graceful error states on no-network

---

## 10. Security Summary

| Risk | Mitigation |
|------|-----------|
| Google idToken forgery | Verified server-side via google-auth-library |
| JWT theft | flutter_secure_storage (hardware keystore); 30-day expiry |
| Admin endpoint abuse | requireAdmin middleware on all /admin/* routes |
| Image upload abuse | multer 5 MB limit; MIME type check; admin-only |
| Payment account exposure | Served only from backend env; never in client code |
| Brute force auth | express-rate-limit on /auth/* endpoints |
| SQL injection | Prisma ORM parameterised queries — no raw SQL |
| XSS (admin) | React DOM escaping; no dangerouslySetInnerHTML |
| Secret exposure | .env.example contains no real values; .gitignore covers .env |
