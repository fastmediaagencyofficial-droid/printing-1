---
description: "Task list for Fast Printing & Packaging — Complete App Flow"
---

# Tasks: Fast Printing & Packaging — Complete App Flow

**Input**: Design documents from `specs/001-complete-app-flow/`
**Prerequisites**: plan.md ✅ · spec.md ✅ · research.md ✅ · data-model.md ✅ · contracts/api-contracts.md ✅ · quickstart.md ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.
**Surfaces**: Backend (B) · Flutter Mobile (F) · React Admin (A)

---

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US11)
- All paths relative to repo root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project scaffolding for all three surfaces. No surface can proceed without this.

- [X] T001 Initialize `backend/` Node.js project — create `backend/package.json` with scripts (`dev`, `build`, `start`, `db:push`, `db:seed`), `backend/tsconfig.json` (strict mode), `backend/.env.example` with all required variables
- [X] T002 [P] Initialize `admin/` React project — run Vite scaffold (`npm create vite@latest admin -- --template react-ts`), install Tailwind CSS, configure `admin/tailwind.config.ts` with brand colour `#C91A20`, create `admin/.env.example` with `VITE_API_BASE_URL` and `VITE_GOOGLE_CLIENT_ID`
- [X] T003 [P] Initialize `frontend/` Flutter project — update `frontend/pubspec.yaml` with all dependencies (`flutter_bloc`, `go_router`, `dio`, `google_sign_in`, `flutter_secure_storage`, `cached_network_image`, `get_it`, `injectable`, `url_launcher`, `image_picker`), set Android package to `com.xfastgroup.fastprinting` in `frontend/android/app/build.gradle`
- [X] T004 Install backend dependencies — `express`, `@prisma/client`, `prisma`, `google-auth-library`, `jsonwebtoken`, `nodemailer`, `cloudinary`, `multer`, `helmet`, `cors`, `express-rate-limit`, `winston` and their TypeScript types in `backend/package.json`
- [X] T005 [P] Install admin dependencies — `@tanstack/react-query`, `zustand`, `axios`, `react-hook-form`, `zod`, `@hookform/resolvers`, `react-router-dom` in `admin/package.json`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Backend Foundation

- [X] T006 Update `schema.prisma` at repo root — add `imageUrl String?` to `Product` model, add `imageUrl String?` to `Service` model, add new `Category` model (id, name, slug, description, imageUrl, sortOrder, createdAt, updatedAt), add new `Industry` model (id, name, slug, description, imageUrl, sortOrder, createdAt). Move `schema.prisma` to `backend/prisma/schema.prisma` if not already there.
- [X] T007 Update `backend/prisma/seed.ts` — add seed data for `Category` (business-cards, banners, stickers, packaging, flyers, brochures, posters, labels) and `Industry` (retail, food-beverage, healthcare, corporate) records; ensure 16 services and 23 products are seeded with correct category slugs
- [X] T008 Create `backend/src/utils/response.ts` — export `successResponse(data, message)` and `errorResponse(error, code)` helpers that return `{ success: true|false, data?, message?, error?, code? }`
- [X] T009 Create `backend/src/services/jwt.service.ts` — export `signToken(payload)` (signs 30-day JWT using `JWT_SECRET` from env) and `verifyToken(token)` (returns decoded payload or throws)
- [X] T010 [P] Create `backend/src/services/cloudinary.service.ts` — export `uploadImage(buffer, folder, filename?)` that uploads a Buffer to Cloudinary using the SDK, in the specified folder (`/products`, `/services`, `/categories`, `/industries`), returns `secure_url`
- [X] T011 [P] Create `backend/src/services/email.service.ts` — configure Nodemailer transport with `EMAIL_USER`/`EMAIL_PASS` env vars; export async functions: `sendOrderConfirmation(order)`, `sendQuoteNotification(quote)`, `sendContactMessage(contact)`, `sendContactAutoReply(contact)`
- [X] T012 Create `backend/src/middleware/auth.middleware.ts` — export `authenticateToken` middleware that reads `Authorization: Bearer <token>`, calls `verifyToken`, attaches `req.user = { id, email, role }`, returns 401 if missing/invalid
- [X] T013 [P] Create `backend/src/middleware/admin.middleware.ts` — export `requireAdmin` middleware that checks `req.user.role === 'ADMIN'`, returns 403 if not; must be used after `authenticateToken`
- [X] T014 [P] Create `backend/src/middleware/error.middleware.ts` — global Express error handler that catches all thrown errors, logs with Winston, returns standardised error response with appropriate HTTP status code
- [X] T015 [P] Create `backend/src/middleware/rateLimiter.ts` — configure `express-rate-limit` for auth endpoints: max 10 requests per 15 minutes per IP; export `authRateLimit`
- [X] T016 Create `backend/src/app.ts` — create Express app, apply middleware in order: `helmet()`, `cors()`, `express.json()`, mount all route files at `/api/v1`, apply `error.middleware` last; export `app`
- [X] T017 Create `backend/src/server.ts` — create HTTP server, listen on `PORT` env var (default 5000), log startup with Winston
- [X] T018 Create `backend/src/controllers/index.ts` — empty file with sections marked for each domain (auth, products, services, categories, industries, cart, wishlist, orders, payment, quotes, contact, admin); this is where ALL controller functions will live

### Flutter Foundation

- [X] T019 Create `frontend/lib/core/constants/api_constants.dart` — static class with all endpoint paths as string constants matching `contracts/api-contracts.md`; base URL switches between emulator (`10.0.2.2:5000`), device, and production based on build flag
- [X] T020 [P] Create `frontend/lib/core/storage/secure_storage.dart` — wrapper around `flutter_secure_storage`; export `SecureStorageService` with `saveToken(String)`, `getToken()`, `deleteToken()` methods
- [X] T021 [P] Create `frontend/lib/core/network/dio_client.dart` — configure `Dio` instance with base URL from `ApiConstants`; add `Bearer` token interceptor that reads JWT from `SecureStorageService` and attaches to every request; add error interceptor that converts Dio errors to domain errors
- [X] T022 Create `frontend/lib/core/di/injection.dart` — set up `get_it` + `injectable`; register `SecureStorageService` and `DioClient` as singletons; register all repositories and BLoCs per their scopes (Factory vs LazySingleton per plan.md)
- [X] T023 Create `frontend/lib/main.dart` — entry point; initialise DI (`injection.dart`); wrap app in `MultiBlocProvider` for global BLoCs (`CartBloc`, `WishlistBloc`, `AuthBloc`); set up `go_router` with auth guard (redirect to `/login` if no JWT)

### Admin Foundation

- [X] T024 Create `admin/src/services/api.ts` — configure Axios instance with `VITE_API_BASE_URL`; add request interceptor that reads JWT from `localStorage` and attaches `Authorization: Bearer <token>`; add response interceptor that redirects to `/login` on 401
- [X] T025 [P] Create `admin/src/stores/auth.store.ts` — Zustand store with `token: string | null`, `user: AdminUser | null`, `setAuth(token, user)`, `clearAuth()`; persisted to `localStorage`
- [X] T026 [P] Create `admin/src/App.tsx` — configure `react-router-dom` routes for all admin pages; add auth guard HOC that checks Zustand auth store — redirects to `/login` if not authenticated or role is not ADMIN

**Checkpoint**: Foundation complete — all user story work can now begin.

---

## Phase 3: US1 — Customer Signs In with Google (Priority: P1) 🎯 MVP

**Goal**: Customer can sign in with Google, receive a JWT, and stay signed in for 30 days.

**Independent Test**: Launch app → tap "Sign in with Google" → complete Google account selection → verify home screen loads with user's name displayed.

### Backend — Auth

- [X] T027 [US1] Add `googleLogin` controller to `backend/src/controllers/index.ts` — accept `{ idToken }`, verify with `google-auth-library` `OAuth2Client.verifyIdToken()` using `GOOGLE_CLIENT_ID`, upsert user in PostgreSQL via Prisma, sign JWT with `jwt.service.ts`, return `{ token, user }` with `successResponse`
- [X] T028 [US1] Add `getMe` controller to `backend/src/controllers/index.ts` — return `req.user` full profile from DB
- [X] T029 [US1] Add `updateProfile` controller to `backend/src/controllers/index.ts` — accept `{ phone, street, city, province, postalCode }`, update user record, return updated user
- [X] T030 [US1] Create `backend/src/routes/auth.routes.ts` — mount `POST /google-login` (with `authRateLimit`) → `googleLogin`; mount `GET /me` (with `authenticateToken`) → `getMe`; mount `PUT /profile` (with `authenticateToken`) → `updateProfile`; register in `app.ts` at `/api/v1/auth`

### Flutter — Auth

- [X] T031 [US1] Create `frontend/lib/features/auth/models/user_model.dart` — `UserModel` with `id`, `email`, `displayName`, `photoUrl`, `phone`, `role`; `fromJson` factory; `copyWith`
- [X] T032 [US1] Create `frontend/lib/features/auth/repository/auth_repository.dart` — `AuthRepository` using `DioClient`; methods: `googleLogin(String idToken)` → calls `POST /auth/google-login`, saves JWT to `SecureStorageService`, returns `UserModel`; `getMe()` → calls `GET /auth/me`; `logout()` → deletes JWT
- [X] T033 [US1] Create `frontend/lib/features/auth/bloc/auth_bloc.dart` — `AuthBloc` (Factory); events: `AuthLoginRequested`, `AuthCheckRequested`, `AuthLogoutRequested`; states: `AuthInitial`, `AuthLoading`, `AuthAuthenticated(user)`, `AuthUnauthenticated`, `AuthError(message)`; on `AuthLoginRequested`: call `google_sign_in`, get idToken, call `authRepository.googleLogin(idToken)`
- [X] T034 [US1] Create `frontend/lib/features/auth/screens/login_screen.dart` — `LoginScreen` widget; show XFast Group logo + "Sign in with Google" button; dispatch `AuthLoginRequested` on tap; navigate to `/` on `AuthAuthenticated`; show error snackbar on `AuthError`
- [X] T035 [US1] Update `frontend/lib/main.dart` go_router — add `/login` route → `LoginScreen`; auth guard: if `AuthUnauthenticated`, redirect to `/login`; if `AuthAuthenticated` and on `/login`, redirect to `/`

### Admin — Auth

- [X] T036 [US1] Create `admin/src/pages/LoginPage.tsx` — Google Sign-In button using `@react-oauth/google` or Google Identity Services script; on success, POST `{ idToken }` to `/api/v1/auth/google-login` via `api.ts`; if `role !== 'ADMIN'`, show "Not authorised" and clear token; otherwise call `setAuth()` in Zustand store and navigate to `/`

**Checkpoint**: US1 complete — Google Sign-In works on Flutter + Admin; JWT stored securely; auth guard active.

---

## Phase 4: US2 — Customer Browses Products and Services (Priority: P1)

**Goal**: Customers can browse the full product catalogue (filter by category, search), browse all 16 services, browse industries, and view detail screens.

**Independent Test**: Navigate to Products → filter by a category → tap a product card → verify detail screen shows name, image (CachedNetworkImage), description, price. Navigate to Services → tap a service → verify detail screen shows full description.

### Backend — Catalogue

- [X] T037 [US2] Add `getProducts` controller — query all active products with optional `?category`, `?search`, `?featured`, `?page`, `?limit`; return paginated list; log with Winston
- [X] T038 [P] [US2] Add `getProductCategories` controller — query all `Category` records; return `{ categories: [...] }`
- [X] T039 [P] [US2] Add `getProduct` controller — find product by `:id` including `specs`; return full product object; 404 if not found
- [X] T040 [US2] Create `backend/src/routes/products.routes.ts` — mount `GET /` → `getProducts`; `GET /categories` → `getProductCategories`; `GET /:id` → `getProduct`; register at `/api/v1/products`
- [X] T041 [P] [US2] Add `getServices` + `getService` controllers — list all active services; get single by `:slug`; 404 if not found
- [X] T042 [P] [US2] Create `backend/src/routes/services.routes.ts` — `GET /` → `getServices`; `GET /:slug` → `getService`; register at `/api/v1/services`
- [X] T043 [P] [US2] Add `getCategories` controller + `backend/src/routes/categories.routes.ts` — `GET /` returns all categories; register at `/api/v1/categories`
- [X] T044 [P] [US2] Add `getIndustries` controller + `backend/src/routes/industries.routes.ts` — `GET /` returns all industries; register at `/api/v1/industries`

### Flutter — Catalogue

- [X] T045 [US2] Create `frontend/lib/features/products/models/product_model.dart` — `ProductModel` (id, name, slug, description, category, startingPrice, priceUnit, imageUrl, images, isFeatured, specs); `CategoryModel` (id, name, slug, imageUrl); `fromJson` factories
- [X] T046 [P] [US2] Create `frontend/lib/features/products/repository/product_repository.dart` — `getProducts({category, search, featured, page, limit})`, `getCategories()`, `getProduct(id)` using `DioClient`
- [X] T047 [US2] Create `frontend/lib/features/products/bloc/product_bloc.dart` — `ProductBloc` (LazySingleton); events: `ProductsLoadRequested`, `ProductsFilterChanged`, `ProductsSearchChanged`, `ProductDetailRequested`; states: `ProductInitial`, `ProductsLoading`, `ProductsLoaded(products, categories, total)`, `ProductDetailLoaded(product)`, `ProductError(message)`
- [X] T048 [US2] Create `frontend/lib/features/products/screens/product_list_screen.dart` — `ProductListScreen`; show category filter chips at top, search bar; product grid cards with `CachedNetworkImage` (shimmer placeholder, error fallback asset); dispatch events on filter/search change
- [X] T049 [US2] Create `frontend/lib/features/products/screens/product_detail_screen.dart` — `ProductDetailScreen`; show full `CachedNetworkImage`, name, price, description, specs chips; "Add to Cart" and "Add to Wishlist" buttons (dispatching to `CartBloc` / `WishlistBloc`)
- [X] T050 [P] [US2] Create `frontend/lib/features/services/models/service_model.dart` + `frontend/lib/features/services/repository/service_repository.dart` — `ServiceModel` (id, name, slug, shortDescription, imageUrl, features); `getServices()`, `getService(slug)`
- [X] T051 [P] [US2] Create `frontend/lib/features/services/bloc/service_bloc.dart` — `ServiceBloc` (LazySingleton); events: `ServicesLoadRequested`, `ServiceDetailRequested`; states: Loading/Loaded/Error
- [X] T052 [P] [US2] Create `frontend/lib/features/services/screens/service_list_screen.dart` + `service_detail_screen.dart` — list with `CachedNetworkImage` cards; detail with full description, features list, "Request Quote" CTA button
- [X] T053 [P] [US2] Create `frontend/lib/features/industries/cubit/industry_cubit.dart` + `industry_model.dart` + `frontend/lib/features/industries/screens/industry_screen.dart` — `IndustryCubit` (LazySingleton); fetch industries; display grid with `CachedNetworkImage`
- [X] T054 [US2] Create `frontend/lib/features/home/screens/home_screen.dart` — navigation shell with `BottomNavigationBar` (Home, Products, Services, Cart, Profile tabs); show featured products and services sections; route to each tab via go_router

**Checkpoint**: US2 complete — full catalogue browsable; all images load via CachedNetworkImage from Cloudinary CDN.

---

## Phase 5: US3 — Customer Manages Cart and Places an Order (Priority: P1)

**Goal**: Customers can add products to cart, adjust quantities, remove items, and place an order. Confirmation email is sent and order appears in history.

**Independent Test**: Add 2 products → update quantity on one → remove the other → place order → verify confirmation email received and order in history with "Pending Payment" status.

### Backend — Cart + Orders

- [X] T055 [US3] Add cart controllers to `backend/src/controllers/index.ts` — `getCart` (fetch user's CartItems with product joins, compute total); `addToCart` (upsert CartItem, snapshot productName + unitPrice + totalPrice); `updateCartItem` (update quantity + recompute totalPrice); `removeCartItem`; `clearCart`
- [X] T056 [US3] Create `backend/src/routes/cart.routes.ts` — all 5 cart endpoints with `authenticateToken`; register at `/api/v1/cart`
- [X] T057 [US3] Add order controllers to `backend/src/controllers/index.ts` — `createOrder`: validate cart non-empty, create `Order` + `OrderItem[]` (snapshot names + prices), clear cart, call `email.service.sendOrderConfirmation(order)` asynchronously, return created order with `orderId`; `getOrders`: paginated list for req.user; `getOrder`: single order with items; `cancelOrder`: only if `PENDING_PAYMENT` → set `CANCELLED`
- [X] T058 [US3] Create `backend/src/routes/orders.routes.ts` — `GET /`, `POST /`, `GET /:id`, `PUT /:id/cancel`; all with `authenticateToken`; register at `/api/v1/orders`

### Flutter — Cart + Orders

- [X] T059 [US3] Create `frontend/lib/features/cart/models/cart_model.dart` — `CartItemModel` (id, productId, productName, quantity, unitPrice, totalPrice, customSpecs); `CartModel` (items, total, itemCount); `fromJson` factories
- [X] T060 [US3] Create `frontend/lib/features/cart/repository/cart_repository.dart` — `getCart()`, `addToCart(productId, qty, specs?)`, `updateCartItem(id, qty)`, `removeCartItem(id)`, `clearCart()`
- [X] T061 [US3] Create `frontend/lib/features/cart/bloc/cart_bloc.dart` — `CartBloc` (LazySingleton); events: `CartLoadRequested`, `CartItemAdded`, `CartItemUpdated`, `CartItemRemoved`, `CartCleared`; states: `CartInitial`, `CartLoading`, `CartLoaded(cart)`, `CartError(message)`; optimistically updates count badge
- [X] T062 [US3] Create `frontend/lib/features/cart/screens/cart_screen.dart` — `CartScreen`; list `CartItemModel` rows with quantity stepper; item total; cart grand total; "Place Order" button → navigate to checkout
- [X] T063 [US3] Create `frontend/lib/features/orders/models/order_model.dart` — `OrderModel` (id, orderId, status, totalAmount, paymentMethod, items, createdAt); `OrderItemModel`; `fromJson` factories
- [X] T064 [US3] Create `frontend/lib/features/orders/repository/order_repository.dart` — `getOrders({page, limit})`, `getOrder(id)`, `placeOrder({paymentMethod, shipping, notes})`, `cancelOrder(id)`
- [X] T065 [US3] Create `frontend/lib/features/orders/bloc/order_bloc.dart` — `OrderBloc` (Factory); events: `OrdersLoadRequested`, `OrderDetailRequested`, `OrderPlaceRequested`, `OrderCancelRequested`; states: Loading/Loaded/Placed/Error
- [X] T066 [US3] Create `frontend/lib/features/orders/screens/checkout_screen.dart` — collect `paymentMethod` (JAZZCASH / EASYPAISA radio), shipping address fields, notes; "Confirm Order" → dispatch `OrderPlaceRequested`; on success navigate to `OrderDetailScreen`
- [X] T067 [US3] Create `frontend/lib/features/orders/screens/order_history_screen.dart` — list orders with status chip, orderId, date, total; tap → `OrderDetailScreen`
- [X] T068 [US3] Create `frontend/lib/features/orders/screens/order_detail_screen.dart` — show orderId, status, items, total; "Upload Payment" button (navigates to `PaymentUploadScreen`); "Cancel Order" button (only if PENDING_PAYMENT)

**Checkpoint**: US3 complete — cart → checkout → order placed → confirmation email; order history visible.

---

## Phase 6: US4 — Customer Submits Payment Proof (Priority: P1)

**Goal**: Customer uploads a payment screenshot against their order. Admin can view it and verify/reject. Order status updates accordingly.

**Independent Test**: Open a placed order → view JazzCash/EasyPaisa account numbers → tap "Upload Payment Proof" → select image from gallery → submit → verify status changes to "Payment Uploaded".

### Backend — Payment

- [X] T069 [US4] Add `getPaymentMethods` controller — read `JAZZCASH_NUMBER`, `EASYPAISA_NUMBER`, `PAYMENT_ACCOUNT_NAME` from `process.env`; return array of payment method objects; never expose these values anywhere else
- [X] T070 [US4] Create `backend/src/routes/payment.routes.ts` — `GET /methods` → `getPaymentMethods` (public); register at `/api/v1/payment`
- [X] T071 [US4] Add `uploadPaymentProof` controller — `authenticateToken` + `multer.single('image')` middleware; validate MIME type (`image/jpeg`, `image/png`, `image/webp`); upload to Cloudinary `/payments` folder via `cloudinary.service.uploadImage()`; update `Order.paymentProofUrl` and set status to `PAYMENT_UPLOADED`; create `PaymentProof` record; return `{ proofUrl, status }`
- [X] T072 [US4] Add `POST /orders/:id/payment-proof` route to `backend/src/routes/orders.routes.ts` — with `authenticateToken` + multer middleware + `uploadPaymentProof` controller

### Flutter — Payment

- [X] T073 [US4] Create `frontend/lib/features/payment/repository/payment_repository.dart` — `getPaymentMethods()`, `uploadPaymentProof(orderId, File imageFile)` (multipart/form-data POST using Dio)
- [X] T074 [US4] Create `frontend/lib/features/payment/bloc/payment_bloc.dart` — `PaymentBloc` (Factory); events: `PaymentMethodsLoadRequested`, `PaymentProofUploadRequested(orderId, imageFile)`; states: Loading/MethodsLoaded/ProofUploaded/Error
- [X] T075 [US4] Create `frontend/lib/features/payment/screens/payment_upload_screen.dart` — show payment account numbers fetched from API (JAZZCASH + EASYPAISA with `PAYMENT_ACCOUNT_NAME`); `image_picker` gallery button; preview selected image; "Submit Proof" → dispatch `PaymentProofUploadRequested`; on success navigate back to order detail with updated status

**Checkpoint**: US4 complete — payment numbers displayed from backend; proof uploaded to Cloudinary; order status updates.

---

## Phase 7: US5 — Customer Manages Wishlist (Priority: P2)

**Goal**: Customers can add/remove products to wishlist and move items to cart.

**Independent Test**: Add product to wishlist from detail screen → open wishlist → tap "Move to Cart" → verify item in cart and removed from wishlist.

### Backend — Wishlist

- [X] T076 [US5] Add wishlist controllers to `backend/src/controllers/index.ts` — `getWishlist` (fetch WishlistItems with product joins); `addToWishlist` (upsert with unique constraint); `removeFromWishlist`; `moveToCart` (add to cart + remove from wishlist in transaction)
- [X] T077 [US5] Create `backend/src/routes/wishlist.routes.ts` — all 4 endpoints with `authenticateToken`; register at `/api/v1/wishlist`

### Flutter — Wishlist

- [X] T078 [US5] Create `frontend/lib/features/wishlist/models/wishlist_item_model.dart` + `frontend/lib/features/wishlist/repository/wishlist_repository.dart` — `WishlistItemModel`; `getWishlist()`, `addToWishlist(productId)`, `removeFromWishlist(productId)`, `moveToCart(productId, qty)`
- [X] T079 [US5] Create `frontend/lib/features/wishlist/bloc/wishlist_bloc.dart` — `WishlistBloc` (LazySingleton); events: `WishlistLoadRequested`, `WishlistItemAdded`, `WishlistItemRemoved`, `WishlistItemMovedToCart`; states: Loading/Loaded/Error
- [X] T080 [US5] Create `frontend/lib/features/wishlist/screens/wishlist_screen.dart` — list wishlist items with `CachedNetworkImage`; heart/remove icon; "Move to Cart" button; empty state illustration

**Checkpoint**: US5 complete — wishlist persists across sessions; move-to-cart works.

---

## Phase 8: US6 — Customer Requests a Custom Quote (Priority: P2)

**Goal**: Customers submit quote requests; team receives email; customer views quote status/response.

**Independent Test**: Fill quote form → submit → verify quote in "My Quotes" with "Pending" status and team receives notification email.

### Backend — Quotes

- [X] T081 [US6] Add quote controllers to `backend/src/controllers/index.ts` — `createQuote`: validate required fields, create `Quote` record (link to `req.user.id` if authenticated), call `email.service.sendQuoteNotification(quote)` async, return created quote with `quoteId`; `getMyQuotes`: return quotes for `req.user.id`
- [X] T082 [US6] Create `backend/src/routes/quotes.routes.ts` — `POST /request` (public, optional auth) → `createQuote`; `GET /my` (with `authenticateToken`) → `getMyQuotes`; register at `/api/v1/quotes`

### Flutter — Quotes

- [X] T083 [US6] Create `frontend/lib/features/quotes/models/quote_model.dart` + `frontend/lib/features/quotes/repository/quote_repository.dart` — `QuoteModel` (quoteId, product, status, adminResponse, estimatedPrice, createdAt); `submitQuote(data)`, `getMyQuotes()`
- [X] T084 [US6] Create `frontend/lib/features/quotes/bloc/quote_bloc.dart` — `QuoteBloc` (Factory); events: `QuoteSubmitRequested`, `MyQuotesLoadRequested`; states: Loading/Submitted/Loaded/Error
- [X] T085 [US6] Create `frontend/lib/features/quotes/screens/quote_request_screen.dart` — form with product, quantity, size, material, specialRequirements, deliveryLocation, deadline, phone fields; validate required fields; dispatch `QuoteSubmitRequested`; show success message with quoteId
- [X] T086 [US6] Create `frontend/lib/features/quotes/screens/my_quotes_screen.dart` — list quotes with status chip; show `adminResponse` and `estimatedPrice` if present

**Checkpoint**: US6 complete — quote submitted; email sent to team; customer sees quote with admin response.

---

## Phase 9: US7 — Customer Contacts Support (Priority: P3)

**Goal**: Customer submits a contact message; receives auto-reply; team is notified.

**Independent Test**: Submit contact form → verify auto-reply email arrives; admin dashboard shows the message.

### Backend — Contact

- [X] T087 [US7] Add `createContactMessage` controller to `backend/src/controllers/index.ts` — validate required fields (name, email, phone, message), create `ContactMessage` record, call `email.service.sendContactMessage(msg)` and `email.service.sendContactAutoReply(msg)` async, return success
- [X] T088 [US7] Create `backend/src/routes/contact.routes.ts` — `POST /` (public) → `createContactMessage`; register at `/api/v1/contact`

### Flutter — Contact

- [X] T089 [US7] Create `frontend/lib/features/contact/cubit/contact_cubit.dart` + `frontend/lib/features/contact/repository/contact_repository.dart` — `ContactCubit` (Factory); state: Initial/Loading/Sent/Error; `submitContact(data)` calls `POST /contact`
- [X] T090 [US7] Create `frontend/lib/features/contact/screens/contact_screen.dart` — form with name, email, phone, service (dropdown, optional), message; submit → dispatch; on Sent: show success snackbar with "We'll get back to you soon"

**Checkpoint**: US7 complete — contact form submits; auto-reply and team notification emails sent.

---

## Phase 10: US8 — Admin Manages the Content Catalogue (Priority: P1)

**Goal**: Admin can CRUD products, services, categories, industries with image upload. Changes appear immediately in the Flutter app.

**Independent Test**: Admin creates new product with uploaded image → open Flutter app → verify product appears with correct image loaded from Cloudinary.

### Backend — Admin Content

- [X] T091 [US8] Add admin product controllers to `backend/src/controllers/index.ts` — `adminGetProducts` (all including inactive); `adminCreateProduct`; `adminUpdateProduct`; `adminDeleteProduct` (removes from cart items, retains in order snapshots); `adminUploadProductImage` (multer + Cloudinary `/products` folder, update `Product.imageUrl`)
- [X] T092 [US8] Add admin service controllers — `adminGetServices`; `adminCreateService`; `adminUpdateService`; `adminUploadServiceImage` (Cloudinary `/services`, update `Service.imageUrl`)
- [X] T093 [US8] Add admin category controllers — `adminGetCategories`; `adminCreateCategory`; `adminUpdateCategory`; `adminDeleteCategory` (only if no products reference this slug); `adminUploadCategoryImage` (Cloudinary `/categories`, update `Category.imageUrl`)
- [X] T094 [US8] Add admin industry controllers — `adminGetIndustries`; `adminCreateIndustry`; `adminUpdateIndustry`; `adminUploadIndustryImage` (Cloudinary `/industries`, update `Industry.imageUrl`)
- [X] T095 [US8] Create `backend/src/routes/admin.routes.ts` — mount all admin routes with `authenticateToken` + `requireAdmin`; image upload routes also use `multer.single('image')` middleware; register at `/api/v1/admin`

### Admin Dashboard — Content

- [X] T096 [US8] Create `admin/src/components/ImageUpload.tsx` — reusable component: file input (accept `image/jpeg,image/png,image/webp`), local preview via `FileReader`, upload progress indicator, error state; calls parent `onUpload(file: File)` callback; max 5 MB client-side validation
- [X] T097 [US8] Create `admin/src/hooks/useProducts.ts` — TanStack Query hooks: `useAdminProducts()`, `useCreateProduct()`, `useUpdateProduct()`, `useDeleteProduct()`, `useUploadProductImage()` using `api.ts`
- [X] T098 [US8] Create `admin/src/pages/products/ProductListPage.tsx` — table with name, category, price, imageUrl preview, active toggle, edit/delete actions; "New Product" button
- [X] T099 [US8] Create `admin/src/pages/products/ProductFormPage.tsx` — React Hook Form + Zod validation; all product fields; `<ImageUpload />` component that calls `useUploadProductImage()` on file select; handles create + edit modes
- [X] T100 [P] [US8] Create `admin/src/hooks/useServices.ts` + `admin/src/pages/services/ServiceListPage.tsx` + `admin/src/pages/services/ServiceFormPage.tsx` — same pattern as products; `<ImageUpload />` for service image
- [X] T101 [P] [US8] Create `admin/src/hooks/useCategories.ts` + `admin/src/pages/categories/CategoryListPage.tsx` — category CRUD table + `<ImageUpload />` inline
- [X] T102 [P] [US8] Create `admin/src/hooks/useIndustries.ts` + `admin/src/pages/industries/IndustryListPage.tsx` — industry CRUD table + `<ImageUpload />` inline
- [X] T103 [US8] Create `admin/src/components/Layout.tsx` — sidebar with nav links to all admin sections (Dashboard, Products, Services, Categories, Industries, Orders, Quotes, Contacts, Users); topbar with user name + sign-out; Tailwind `#C91A20` brand accents

**Checkpoint**: US8 complete — admin can CRUD all content + upload images; Flutter app shows updated content.

---

## Phase 11: US9 — Admin Verifies Payments and Manages Orders (Priority: P1)

**Goal**: Admin views all orders, sees payment proofs, marks VERIFIED/REJECTED, updates order status.

**Independent Test**: As admin, open order with payment proof → view proof image → click Verify → confirm order status changes to "Processing"; check Flutter app reflects updated status.

### Backend — Admin Orders

- [X] T104 [US9] Add admin order controllers to `backend/src/controllers/index.ts` — `adminGetOrders` (paginated, all users, filter by status/search); `adminGetOrder` (full detail including paymentProofUrl); `adminUpdateOrder` (update `status` + `adminNotes`); `adminVerifyPayment` (action: VERIFY → set `ProofStatus.VERIFIED` + `Order.status = CONFIRMED` + `paymentVerifiedAt`; action: REJECT → set `ProofStatus.REJECTED` + `Order.status = PAYMENT_UPLOADED`)
- [X] T105 [US9] Add admin order routes to `backend/src/routes/admin.routes.ts` — `GET /orders`, `GET /orders/:id`, `PUT /orders/:id`, `PUT /orders/:id/verify-payment`

### Admin Dashboard — Orders

- [X] T106 [US9] Create `admin/src/hooks/useOrders.ts` — TanStack Query hooks: `useAdminOrders({status, page})`, `useAdminOrder(id)`, `useUpdateOrder()`, `useVerifyPayment()`
- [X] T107 [US9] Create `admin/src/pages/orders/OrderListPage.tsx` — table with orderId, customer name, status badge, total, date; status filter tabs (All, Pending, Payment Uploaded, Confirmed, etc.); click row → `OrderDetailPage`
- [X] T108 [US9] Create `admin/src/pages/orders/OrderDetailPage.tsx` — show full order with items table; payment proof image (`<img>` with Cloudinary URL); "Verify Payment" and "Reject Payment" buttons (call `useVerifyPayment()`); order status dropdown (call `useUpdateOrder()`); admin notes textarea

**Checkpoint**: US9 complete — admin can verify payments and update order statuses; changes reflect in Flutter app.

---

## Phase 12: US10 — Admin Manages Quotes and Contact Messages (Priority: P2)

**Goal**: Admin reviews quotes (set status, add response, set price) and marks contact messages as read.

**Independent Test**: Open pending quote → set estimated price to 1500 PKR → add response → save → verify customer sees updated quote in Flutter My Quotes screen.

### Backend — Admin Quotes + Contact

- [X] T109 [US10] Add admin quote + contact controllers to `backend/src/controllers/index.ts` — `adminGetQuotes` (paginated, filter by status); `adminUpdateQuote` (status, adminResponse, estimatedPrice); `adminGetContacts` (paginated, filter isRead); `adminMarkContactRead`
- [X] T110 [US10] Add admin quote + contact routes to `backend/src/routes/admin.routes.ts` — `GET /quotes`, `PUT /quotes/:id`, `GET /contacts`, `PUT /contacts/:id/read`

### Admin Dashboard — Quotes + Contacts

- [X] T111 [US10] Create `admin/src/hooks/useQuotes.ts` + `admin/src/pages/quotes/QuoteListPage.tsx` + `admin/src/pages/quotes/QuoteDetailPage.tsx` — list with status filter; detail with customer info, project details; React Hook Form for adminResponse + estimatedPrice + status; save calls `PUT /admin/quotes/:id`
- [X] T112 [US10] Create `admin/src/hooks/useContacts.ts` + `admin/src/pages/contacts/ContactListPage.tsx` — table with sender, email, preview, read status; "Mark as Read" button; filter tabs (All / Unread)

**Checkpoint**: US10 complete — admin can respond to quotes with prices; contact inbox manageable.

---

## Phase 13: US11 — Admin Views Dashboard Metrics (Priority: P3)

**Goal**: Admin sees order counts by status, revenue summary, recent orders, unread contact count, pending quote count.

**Independent Test**: Sign in as admin → dashboard loads → verify order counts per status are displayed, revenue total shown, 5 most recent orders listed.

### Backend — Dashboard

- [X] T113 [US11] Add `adminGetDashboard` controller — aggregate: count orders by status, sum `totalAmount` for orders with verified payment, fetch 5 most recent orders, count unread contacts, count pending quotes; return as `{ orders: { total, byStatus }, revenue: { totalVerified }, recentOrders, unreadContacts, pendingQuotes }`
- [X] T114 [US11] Add admin users + dashboard routes to `backend/src/routes/admin.routes.ts` — `GET /dashboard` → `adminGetDashboard`; `GET /users`, `PUT /users/:id/role` → user management controllers

### Admin Dashboard — Metrics + Users

- [X] T115 [US11] Create `admin/src/hooks/useDashboard.ts` + `admin/src/pages/DashboardPage.tsx` — metric cards (total orders, revenue, pending payments, unread contacts); order status bar chart or count badges; recent orders table; pending quotes count; auto-refetch every 60 seconds via TanStack Query
- [X] T116 [US11] Create `admin/src/hooks/useUsers.ts` + `admin/src/pages/users/UserListPage.tsx` — paginated user table (name, email, role, join date); "Promote to Admin" / "Demote to Customer" toggle button

**Checkpoint**: US11 complete — dashboard shows live metrics; admin can manage user roles.

---

## Phase 14: Polish & Cross-Cutting Concerns

**Purpose**: Quality, error handling, and release builds across all stories.

- [X] T117 [P] Flutter — add shimmer loading widgets for all `CachedNetworkImage` placeholders in `ProductListScreen`, `ServiceListScreen`, `IndustryScreen`, `WishlistScreen`; use `shimmer` package
- [X] T118 [P] Flutter — implement expired JWT handling in `frontend/lib/core/network/dio_client.dart` — on 401 response: clear JWT from `SecureStorageService`, dispatch `AuthLogoutRequested`, redirect to `/login` via go_router
- [X] T119 [P] Flutter — add `frontend/lib/features/auth/screens/profile_screen.dart` — show user name, email, photo; edit phone + address; sign-out button
- [X] T120 [P] Backend — verify Winston logging is present in ALL controller functions in `backend/src/controllers/index.ts`; add any missing log statements (info for success, error for failures)
- [X] T121 [P] Backend — add `CORS` allowlist for admin dashboard origin and Flutter app in `backend/src/app.ts`; configure `ACCESS_CONTROL_ALLOW_ORIGIN` via env var
- [X] T122 [P] Admin — add `admin/src/components/StatusBadge.tsx` (colour-coded chips per `OrderStatus` and `QuoteStatus`) and `admin/src/components/ConfirmDialog.tsx` (reusable delete confirmation modal); retrofit across all pages
- [X] T123 [P] Admin — responsive layout audit for `admin/src/components/Layout.tsx` — collapsible sidebar for screens < 1024px wide
- [X] T124 End-to-end validation — run through all 10 checkpoints in `specs/001-complete-app-flow/quickstart.md`; fix any integration issues found
- [X] T125 [P] Flutter — production release build: run `flutter build appbundle --release` in `frontend/`; verify output at `frontend/build/app/outputs/bundle/release/app-release.aab`
- [X] T126 [P] Admin — production build: run `npm run build` in `admin/`; deploy to Vercel (set `VITE_API_BASE_URL` and `VITE_GOOGLE_CLIENT_ID` in Vercel env)
- [X] T127 Backend — production deploy: push to Railway or Render; set all env variables from `backend/.env.example`; run `npm run db:push` and `npm run db:seed` on first deploy

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — **BLOCKS all user stories**
- **US1 Auth (Phase 3)**: Depends on Foundational
- **US2 Catalogue (Phase 4)**: Depends on Foundational (can start parallel with US1)
- **US3 Cart+Orders (Phase 5)**: Depends on US2 (needs product list for cart)
- **US4 Payment (Phase 6)**: Depends on US3 (needs orders to exist)
- **US5 Wishlist (Phase 7)**: Depends on US2 (needs products); parallel with US3/US4
- **US6 Quotes (Phase 8)**: Depends on Foundational; parallel with US3–US5
- **US7 Contact (Phase 9)**: Depends on Foundational; parallel with US3–US6
- **US8 Admin Content (Phase 10)**: Depends on Foundational; parallel with Flutter stories
- **US9 Admin Orders (Phase 11)**: Depends on US8 (needs admin layout) + US3 (needs orders)
- **US10 Admin Quotes/Contacts (Phase 12)**: Depends on US6/US7 + US8
- **US11 Dashboard (Phase 13)**: Depends on US8/US9/US10
- **Polish (Phase 14)**: Depends on all user stories complete

### User Story Dependencies

- **US1** (Auth): No dependencies — first P1 story
- **US2** (Catalogue): No dependencies on other stories — can parallel with US1
- **US3** (Cart+Orders): Depends on US2 (adds to cart from product detail)
- **US4** (Payment): Depends on US3 (payment proof on an order)
- **US5** (Wishlist): Depends on US2; independent of US3/US4
- **US6** (Quotes): Independent of US1–US5 (public form); optional auth link
- **US7** (Contact): Independent — purely standalone
- **US8** (Admin Content): Independent of customer stories; parallel track
- **US9** (Admin Orders): Depends on US8 (admin auth + layout) and US3 (orders exist)
- **US10** (Admin Quotes): Depends on US8; related to US6/US7
- **US11** (Dashboard): Depends on US8/US9/US10

### Parallel Opportunities

- T002, T003 (admin + Flutter scaffold) run in parallel with T001 (backend scaffold)
- T004, T005 (install deps) run in parallel
- T010, T011 (cloudinary + email services) run in parallel with T009 (JWT)
- T013, T014, T015 (admin middleware, error, rate limit) run in parallel with T012 (auth middleware)
- Tiers 2+3 (backend domains) run fully in parallel after T018 (foundation complete)
- Tiers 4+5 (Flutter) run fully in parallel with Tiers 2+3
- Tier 6 (Admin dashboard pages) run in parallel with Tier 5 (Flutter features)
- T125, T126, T127 (release builds) run in parallel with each other

---

## Implementation Strategy

### MVP First (US1 + US2 + US3 only)

1. Complete Phase 1: Setup (T001–T005)
2. Complete Phase 2: Foundational — T006–T026 (backend + Flutter + admin foundation)
3. Complete Phase 3: US1 — T027–T036 (auth on all surfaces)
4. Complete Phase 4: US2 — T037–T054 (catalogue browsing)
5. Complete Phase 5: US3 — T055–T068 (cart + order placement)
6. **STOP and VALIDATE**: Customer can sign in, browse, cart, and order. Email works.
7. Deploy backend + Flutter debug APK for testing.

### Incremental Delivery

1. Foundation → US1 (auth) → US2 (catalogue) → **MVP**
2. US3 (orders) → US4 (payment) → **Operational MVP**
3. US8 (admin content) + US9 (admin orders) → **Admin operational**
4. US5 (wishlist) + US6 (quotes) + US7 (contact) → **Full customer features**
5. US10 (admin inbox) + US11 (metrics) → **Full admin panel**
6. Polish → Release builds → **Production**

### Parallel Team Strategy

With two developers:
- **Dev A**: Backend (Tier 1 → Tier 2 → Tier 3) + Admin dashboard
- **Dev B**: Flutter (Tier 4 → Tier 5) starting after T018 (foundation) is ready

---

## Notes

- `[P]` tasks = different files, no conflicting dependencies — safe to parallelise
- `[Story]` label maps every task to its user story for traceability
- Each user story phase should be independently completable and testable
- Image upload tasks (T071, T091–T094, T096–T102) MUST follow Article VIII pipeline
- `CartBloc` MUST be registered as `LazySingleton` — not `Factory` — in `injection.dart`
- All API calls in Flutter MUST go through `DioClient` — never raw `http` package
- Admin dashboard MUST NOT store JWT anywhere except `localStorage`
- All Cloudinary uploads MUST use folder param per Article VIII: `/products`, `/services`, `/categories`, `/industries`
- `JAZZCASH_NUMBER` and `EASYPAISA_NUMBER` MUST only appear in backend `.env` — never in Flutter or Admin source code
