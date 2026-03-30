# Fast Printing & Packaging — Mobile App

Pakistan's Fastest Custom Printing & Packaging | XFast Group

Stack: Flutter · Node.js · PostgreSQL + Prisma · Google OAuth 2.0 + JWT · Nodemailer · Cloudinary
Zero Firebase. All free resources.

---

## Tech Stack

### Backend
- Node.js 20 + TypeScript + Express
- PostgreSQL 16 (free via Neon/Supabase/Railway)
- Prisma ORM
- Google OAuth 2.0 via google-auth-library → issues our own JWT
- Nodemailer + Gmail SMTP (free)
- Cloudinary for payment screenshot uploads (free 25GB)

### Flutter Frontend
- flutter_bloc for state management
- go_router for navigation
- google_sign_in → sends idToken to backend → receives JWT
- flutter_secure_storage for JWT
- Dio with JWT Bearer interceptor

---

## Auth Flow

1. User taps "Sign in with Google" in the app
2. google_sign_in opens Google OAuth — no Firebase needed
3. Flutter receives a Google idToken
4. Flutter POSTs idToken to /api/v1/auth/google-login
5. Backend verifies the idToken with google-auth-library (free Google API)
6. Backend upserts user in PostgreSQL, signs a 30-day JWT
7. Flutter receives the JWT and stores it securely
8. Every API call attaches: Authorization: Bearer <jwt>

---

## Backend Setup

### Install & configure
```bash
cd backend
npm install
npx prisma generate
cp .env.example .env
# fill in DATABASE_URL, GOOGLE_CLIENT_ID, EMAIL_PASS, CLOUDINARY_*
```

### Free PostgreSQL — pick one
- Neon (recommended):   https://neon.tech  — free 512 MB
- Supabase:             https://supabase.com — free 500 MB
- Railway:              https://railway.app — $5 credit/mo

```bash
# Apply schema
npm run db:push

# Seed 16 services + 23 products
npm run db:seed

# Dev server (hot-reload)
npm run dev

# Production
npm run build && npm start

# Docker (includes PostgreSQL)
docker-compose up -d
```

---

## Flutter Setup

### Install & run
```bash
cd frontend
flutter pub get
flutter run
```

### Google Sign-In setup (no google-services.json needed)
1. Google Cloud Console → APIs & Services → Credentials
2. Create OAuth 2.0 Client ID → Android
3. Package: com.xfastgroup.fastprinting
4. SHA-1 fingerprint from debug keystore
5. Copy Client ID → set GOOGLE_CLIENT_ID in backend .env

### API URL — edit lib/core/constants/api_constants.dart
- Emulator:  http://10.0.2.2:5000/api/v1
- Device:    http://192.168.1.x:5000/api/v1
- Production: https://your-server.com/api/v1

---

## Environment Variables

```env
PORT=5000
NODE_ENV=development

# PostgreSQL (Neon/Supabase/Railway)
DATABASE_URL="postgresql://USER:PASS@HOST:5432/fastprinting?sslmode=require"

# Google OAuth 2.0
GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com

# JWT
JWT_SECRET=minimum_64_char_random_string
JWT_EXPIRE=30d

# Gmail SMTP — App Password (not your Gmail password)
EMAIL_USER=fastmediaagencyofficial@gmail.com
EMAIL_PASS=rlyr jiuf oipr rabz

# Cloudinary (free 25GB) — https://cloudinary.com
CLOUDINARY_CLOUD_NAME=your_cloud
CLOUDINARY_API_KEY=your_key
CLOUDINARY_API_SECRET=your_secret

# Payment accounts (served from backend only)
JAZZCASH_NUMBER=0325-2467463
EASYPAISA_NUMBER=0321-0846667
PAYMENT_ACCOUNT_NAME=XFast Group
```

---

## API Endpoints

All routes prefixed with /api/v1  |  Protected routes require: Authorization: Bearer <jwt>

AUTH
  POST   /auth/google-login         Verify Google idToken → return JWT
  GET    /auth/me              [P]  Get current user
  PUT    /auth/profile         [P]  Update profile

PRODUCTS
  GET    /products                  List all (filter: category, search, featured)
  GET    /products/categories       All categories
  GET    /products/:id              Single product

SERVICES
  GET    /services                  All 16 services
  GET    /services/:slug            Service detail

CART
  GET    /cart                 [P]  Get cart + total
  POST   /cart/add             [P]  Add item
  PUT    /cart/item/:id        [P]  Update quantity
  DELETE /cart/item/:id        [P]  Remove item
  DELETE /cart/clear           [P]  Clear cart

WISHLIST
  GET    /wishlist             [P]  Get wishlist
  POST   /wishlist/add         [P]  Add product
  DELETE /wishlist/:productId  [P]  Remove product
  POST   /wishlist/move-to-cart/:productId  [P]  Move to cart

ORDERS
  GET    /orders               [P]  Order history
  POST   /orders               [P]  Create order (clears cart, sends email)
  GET    /orders/:id           [P]  Order detail
  POST   /orders/:id/payment-proof [P]  Upload proof (base64 image → Cloudinary)
  PUT    /orders/:id/cancel    [P]  Cancel order

PAYMENT
  GET    /payment/methods           JazzCash + EasyPaisa account details

QUOTES
  POST   /quotes/request            Submit quote (sends email to team)
  GET    /quotes/my            [P]  User's quotes

CONTACT
  POST   /contact                   Send message (sends email, auto-reply)

INDUSTRIES
  GET    /industries                All 4 industries

---

## Play Store Build

```bash
cd frontend
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Contact

Website:   https://printing-services-orpin.vercel.app
Email:     xfastgroup001@gmail.com
WhatsApp:  +92 325 2467463
Phone:     +92 321 0846667
Address:   101A, J1 Block, Valencia Town, Main Defence Road, Lahore
Hours:     Mon-Sat 10:00 AM - 8:00 PM

XFast Group — Fast Printing & Packaging · Lahore, Pakistan
