# Fast Printing & Packaging

Pakistan's Fastest Custom Printing & Packaging | XFast Group, Lahore

**Three-surface app** — Flutter Android app · React admin dashboard · Node.js/Express API

Zero Firebase. All free infrastructure.

---

## Architecture Overview

```
┌─────────────────────┐     JWT (30d)      ┌─────────────────────┐
│   Flutter App       │ ◄────────────────► │   Node.js Backend   │
│  (Android)          │   Bearer header    │  Express + Prisma   │
└─────────────────────┘                    └────────┬────────────┘
                                                    │
┌─────────────────────┐     JWT (admin)             │ PostgreSQL
│   React Admin       │ ◄────────────────►          │ Cloudinary
│  (Web Dashboard)    │   Bearer header    └────────┴────────────
└─────────────────────┘
```

| Surface | Tech | Port |
|---|---|---|
| Backend API | Node.js 20 + TypeScript + Express + Prisma | 5000 |
| Flutter App | Flutter 3.x + BLoC + go_router | Android APK |
| Admin Dashboard | React 18 + Vite + TanStack Query v5 + Tailwind | 5173 |

---

## Quick Start

### 1. Backend

```bash
cd backend
npm install
npx prisma generate
cp .env.example .env          # Fill in all variables (see below)
npm run db:push               # Create all tables
npm run db:seed               # Seed 16 services, 23 products, 6 categories, 4 industries
npm run dev                   # http://localhost:5000
```

### 2. Admin Dashboard

```bash
cd admin
npm install
cp .env.example .env          # Set VITE_API_BASE_URL + VITE_GOOGLE_CLIENT_ID
npm run dev                   # http://localhost:5173
```

### 3. Flutter App

```bash
cd frontend
flutter pub get
# Edit lib/core/constants/api_constants.dart → set your backend URL
flutter run                   # Needs Android emulator or physical device
```

---

## Environment Variables (Backend)

Copy `backend/.env.example` → `backend/.env` and fill in:

```env
PORT=5000
NODE_ENV=development

# PostgreSQL — free options: neon.tech | supabase.com | railway.app
DATABASE_URL="postgresql://USER:PASS@HOST:5432/fastprinting?sslmode=require"

# Google OAuth 2.0 — console.cloud.google.com → Credentials → OAuth 2.0 Client ID
GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com

# JWT
JWT_SECRET=minimum_64_char_random_secret_here
JWT_EXPIRE=30d

# Gmail SMTP — use App Password (Google Account → Security → 2FA → App Passwords)
EMAIL_USER=your.gmail@gmail.com
EMAIL_PASS=xxxx xxxx xxxx xxxx

# Cloudinary — cloudinary.com (free 25 GB)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Payment accounts (served from backend only — never expose in frontend)
JAZZCASH_NUMBER=0325-2467463
EASYPAISA_NUMBER=0321-0846667
PAYMENT_ACCOUNT_NAME=XFast Group

# CORS — add admin and Flutter origins
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

---

## Free Infrastructure

| Service | Provider | Free Tier | URL |
|---|---|---|---|
| PostgreSQL | Neon (recommended) | 512 MB | https://neon.tech |
| PostgreSQL | Supabase | 500 MB | https://supabase.com |
| PostgreSQL | Railway | $5/mo credit | https://railway.app |
| Images/Files | Cloudinary | 25 GB | https://cloudinary.com |
| Email | Gmail SMTP | Free | Google Account → App Passwords |
| Backend hosting | Railway | $5/mo credit | https://railway.app |
| Admin hosting | Vercel | Free | https://vercel.com |

---

## Auth Flow

```
Flutter: User taps "Sign in with Google"
  ↓
google_sign_in → Google OAuth (no Firebase, no google-services.json)
  ↓
Flutter receives Google idToken
  ↓
POST /api/v1/auth/google-login { idToken }
  ↓
Backend verifies idToken with google-auth-library (free Google API)
Backend upserts user in PostgreSQL
Backend signs 30-day JWT
  ↓
Flutter stores JWT in flutter_secure_storage
Every Dio request: Authorization: Bearer <jwt>
  ↓
On 401: auto-clear token → redirect to /login
```

---

## Feature Summary

### Flutter App — Customer Features

| Feature | Description |
|---|---|
| Google Sign-In | OAuth 2.0 without Firebase |
| Products | Grid with search + category filter |
| Product Detail | Specs (size/material/finish) + Add to Cart |
| Services | 16 printing services with detail pages |
| Cart | Quantity stepper, clear all, live total |
| Wishlist | Save products, move to cart |
| Checkout | JazzCash / EasyPaisa payment selection |
| Payment Proof | Upload screenshot from gallery → Cloudinary |
| Orders | History, detail, cancel pending |
| Quotes | Request custom quote, view responses |
| Contact | Support form with auto-reply email |
| Industries | Industry vertical browsing |
| Profile | Edit phone and address |

### Admin Dashboard — Staff Features

| Section | Features |
|---|---|
| Dashboard | 6 metric cards, orders by status, recent orders, 60s auto-refresh |
| Products | Full CRUD, image upload, search/filter |
| Services | Edit name/description/image, sort order |
| Categories | Inline create/edit/delete, image upload |
| Industries | Card grid, inline create/edit, image upload |
| Orders | Status filter tabs, payment proof view, verify/reject, status update |
| Quotes | Respond with status + quoted price + notes |
| Contact Inbox | Accordion expand, auto-mark-read, unread filter |
| Users | Role management (CUSTOMER ↔ ADMIN), search |

---

## Repository Structure

```
printing-packaging-app/
├── backend/          # Node.js Express API
│   ├── prisma/       # Schema (12 models) + seed data
│   ├── src/          # Controllers, routes, middleware, config
│   └── README.md     # Full backend documentation
├── frontend/         # Flutter Android app
│   ├── lib/          # BLoC features, screens, core services
│   ├── android/      # Android build config
│   └── README.md     # Full Flutter documentation
├── admin/            # React admin dashboard
│   ├── src/          # Pages, hooks, components, stores
│   └── README.md     # Full admin documentation
└── README.md         # This file
```

---

## Production Deployment

### Backend → Railway

```bash
# 1. Push to GitHub
git push origin main

# 2. Railway dashboard:
#    New Project → Connect GitHub → Root directory: backend/
#    Add PostgreSQL plugin
#    Set all .env variables
#    Auto-deploys on push

# 3. First deploy — run via Railway shell:
npm run db:push && npm run db:seed
```

### Admin Dashboard → Vercel

```bash
# Vercel dashboard:
#   New Project → Import from GitHub
#   Root directory: admin/
#   Build command: npm run build
#   Output directory: dist
#   Environment variables:
#     VITE_API_BASE_URL = https://your-api.railway.app/api/v1
#     VITE_GOOGLE_CLIENT_ID = your_client_id.apps.googleusercontent.com
```

### Flutter App → Play Store

```bash
cd frontend

# 1. Create keystore (first time only)
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload -storepass yourpassword -keypass yourpassword

# 2. Create android/key.properties
# storePassword=yourpassword
# keyPassword=yourpassword
# keyAlias=upload
# storeFile=upload-keystore.jks

# 3. Build App Bundle
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-api.railway.app/api/v1

# Upload build/app/outputs/bundle/release/app-release.aab to Play Console
```

---

## End-to-End Test Flow

Follow this sequence to verify the complete system works:

### 1. Start All Services

```bash
# Terminal 1 — Backend
cd backend && npm run dev

# Terminal 2 — Admin Dashboard
cd admin && npm run dev

# Terminal 3 — Flutter App
cd frontend && flutter run
```

### 2. Customer Flow (Flutter App)

1. **Auth**: Launch app → onboarding → sign in with Google → lands on home
2. **Browse**: View featured products → navigate to Products tab → search → filter by category
3. **Cart**: Open product → select options → Add to Cart → cart badge increments
4. **Wishlist**: Heart icon on product → Wishlist tab → Move to Cart
5. **Checkout**: Cart → Proceed to Checkout → select JazzCash → Place Order → confirmation screen
6. **Payment**: Order detail → Upload Payment Proof → select screenshot → Submit
7. **Quote**: Quote Request screen → fill form → submit → My Quotes shows PENDING
8. **Contact**: Contact form → submit → check email for auto-reply

### 3. Admin Flow (Dashboard)

1. **Login**: `http://localhost:5173/login` → paste Google idToken → Sign In (must have ADMIN role)
2. **Dashboard**: Verify all 6 metric cards load; check recent orders table
3. **Products**: Create a product with image → verify in Flutter app
4. **Order**: Status filter → "Payment Uploaded" tab → Verify Payment → email sent to customer
5. **Quote**: Open pending quote → set price + response → Save → verify in Flutter My Quotes
6. **Contact**: Expand contact message → auto-marked as read

### 4. Promote User to Admin (SQL)

```sql
-- Run in your PostgreSQL database (Neon/Supabase dashboard or Railway shell)
UPDATE users SET role = 'ADMIN' WHERE email = 'your@email.com';
```

---

## API Reference Summary

All routes prefixed with `/api/v1` | `[P]` = requires `Authorization: Bearer <jwt>`

```
POST   /auth/google-login          Verify Google idToken → JWT
GET    /auth/me               [P]  Current user profile
PUT    /auth/profile          [P]  Update phone/address

GET    /products                   List products (filter: category, search, featured)
GET    /products/categories        All categories
GET    /products/:id               Product with specs

GET    /services                   All 16 services
GET    /services/:slug             Service detail

GET    /cart                  [P]  Cart with total
POST   /cart/add              [P]  Add item {productId, quantity, customSpecs}
PUT    /cart/item/:id         [P]  Update quantity
DELETE /cart/item/:id         [P]  Remove item
DELETE /cart/clear            [P]  Clear cart

GET    /wishlist              [P]  Wishlist
POST   /wishlist/add          [P]  Add {productId}
DELETE /wishlist/:productId   [P]  Remove
POST   /wishlist/move-to-cart/:productId  [P]  Move to cart

GET    /orders                [P]  Order history (paginated)
POST   /orders                [P]  Place order (clears cart, sends email)
GET    /orders/:id            [P]  Order detail
POST   /orders/:id/payment-proof  [P]  Upload payment screenshot
PUT    /orders/:id/cancel     [P]  Cancel (PENDING_PAYMENT only)

GET    /payment/methods            JazzCash + EasyPaisa account details

POST   /quotes/request             Submit custom quote request
GET    /quotes/my             [P]  User's quotes

POST   /contact                    Contact form (email + auto-reply)

GET    /industries                 All industries

GET    /admin/dashboard       [A]  Metrics
...    /admin/products         [A]  CRUD + image upload
...    /admin/services         [A]  Edit + image upload
...    /admin/categories       [A]  CRUD + image upload
...    /admin/industries       [A]  CRUD + image upload
...    /admin/orders           [A]  List, detail, status, verify payment
...    /admin/quotes           [A]  List, respond
...    /admin/contacts         [A]  Inbox, mark read
...    /admin/users            [A]  List, change role

[A] = requires ADMIN role JWT
```

---

## Troubleshooting

| Issue | Fix |
|---|---|
| Flutter "Cannot connect to server" | Check API URL in `api_constants.dart`; ensure backend is running; use `10.0.2.2` for emulator, LAN IP for physical device |
| Google Sign-In fails | Verify SHA-1 fingerprint matches keystore; check `GOOGLE_CLIENT_ID` in backend `.env` |
| Admin "Authentication failed" | Google idToken expired (1h TTL); get a fresh token via OAuth Playground |
| Admin "Access denied" | User role is CUSTOMER; run SQL to promote to ADMIN |
| Images not loading | Check Cloudinary credentials in backend `.env` |
| Emails not sending | Use Gmail App Password (not account password); enable 2FA first |
| CORS errors | Add origin to `ALLOWED_ORIGINS` in backend `.env` |
| `prisma generate` fails | Run `npm install` first; check Node.js ≥ 18 |
| `flutter pub get` fails | Check Flutter SDK version ≥ 3.x; run `flutter upgrade` |

---

## Contact

Website: https://printing-services-orpin.vercel.app
Email: xfastgroup001@gmail.com
WhatsApp: +92 325 2467463
Phone: +92 321 0846667
Address: 101A, J1 Block, Valencia Town, Main Defence Road, Lahore
Hours: Mon–Sat 10:00 AM – 8:00 PM

**XFast Group — Fast Printing & Packaging · Lahore, Pakistan**
