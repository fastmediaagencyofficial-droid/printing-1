# Quickstart: Fast Printing & Packaging — Complete App

**Date**: 2026-03-27
**Surfaces**: Backend API · Flutter Mobile · React Admin Dashboard

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | ≥ 20 LTS | https://nodejs.org |
| Flutter SDK | ≥ 3.24 | https://flutter.dev/docs/get-started |
| Dart | ≥ 3.5 | Bundled with Flutter |
| PostgreSQL client | Any | For manual DB inspection |
| Git | Any | https://git-scm.com |

**Free service accounts needed** (all free tier):
- Neon / Supabase / Railway — PostgreSQL database
- Cloudinary — image storage
- Google Cloud Console — OAuth 2.0 client ID

---

## 1. Backend Setup

```bash
# Clone and enter backend directory
cd backend
npm install
npx prisma generate

# Copy and fill environment variables
cp .env.example .env
# Edit .env with your values — see Environment Variables section below

# Apply database schema (creates all tables including Category and Industry)
npm run db:push

# Seed initial data (16 services, 23 products, 4 industries, categories)
npm run db:seed

# Start dev server with hot-reload on port 5000
npm run dev
```

**Verify**: `curl http://localhost:5000/api/v1/products` should return a product list.

### Environment Variables (backend/.env)

```env
PORT=5000
NODE_ENV=development

# PostgreSQL — get from Neon/Supabase/Railway dashboard
DATABASE_URL="postgresql://USER:PASS@HOST:5432/fastprinting?sslmode=require"

# Google OAuth — from Google Cloud Console > Credentials > OAuth 2.0 Client IDs
GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com

# JWT — generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
JWT_SECRET=minimum_64_char_random_string_replace_this
JWT_EXPIRE=30d

# Gmail SMTP — use an App Password (not your account password)
# Go to: Google Account > Security > 2-Step Verification > App passwords
EMAIL_USER=fastmediaagencyofficial@gmail.com
EMAIL_PASS=rlyr jiuf oipr rabz

# Cloudinary — from cloudinary.com > Dashboard
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Payment account numbers (served from backend only — never put in Flutter/Admin code)
JAZZCASH_NUMBER=0325-2467463
EASYPAISA_NUMBER=0321-0846667
PAYMENT_ACCOUNT_NAME=XFast Group
```

---

## 2. Flutter App Setup

```bash
cd frontend
flutter pub get

# Run on connected Android device or emulator
flutter run
```

### Configure API URL

Edit `lib/core/constants/api_constants.dart`:

```dart
// For Android Emulator (accesses host machine localhost)
static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

// For physical device on same Wi-Fi as dev machine
// static const String baseUrl = 'http://192.168.1.x:5000/api/v1';

// For production
// static const String baseUrl = 'https://your-backend.railway.app/api/v1';
```

### Google Sign-In (no google-services.json required)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. APIs & Services → Credentials → Create Credentials → OAuth 2.0 Client ID
3. Application type: **Android**
4. Package name: `com.xfastgroup.fastprinting`
5. SHA-1 fingerprint (debug):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
6. Copy the resulting Client ID
7. Set `GOOGLE_CLIENT_ID` in your backend `.env` to this value

---

## 3. Admin Dashboard Setup

```bash
cd admin
npm install

# Copy and fill environment variables
cp .env.example .env.local
```

**admin/.env.local**:
```env
VITE_API_BASE_URL=http://localhost:5000/api/v1
VITE_GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
```

```bash
# Start dev server on port 5173
npm run dev
```

**First admin setup**: After the backend and Flutter app are running, sign in to the
Flutter app with your Google account. Then in a Neon/Supabase/Railway SQL console, run:

```sql
UPDATE users SET role = 'ADMIN' WHERE email = 'your-email@gmail.com';
```

Now sign in to the admin dashboard at `http://localhost:5173` with that Google account.

---

## 4. Docker (Backend + PostgreSQL together)

```bash
# From repo root
docker-compose up -d
# Backend runs on port 5000, PostgreSQL on 5432
```

---

## 5. Production Deployment

### Backend (Railway or Render)

1. Push code to GitHub
2. Connect repo to Railway/Render
3. Set all environment variables in their dashboard
4. Deploy — they auto-detect Node.js and run `npm run build && npm start`

### Admin Dashboard (Vercel or Netlify)

1. Push `admin/` directory to GitHub
2. Connect to Vercel/Netlify
3. Set `VITE_API_BASE_URL` and `VITE_GOOGLE_CLIENT_ID` in their env settings
4. Deploy — they auto-detect Vite and run `npm run build`

### Flutter (Google Play Store)

```bash
cd frontend
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
# Upload to Google Play Console
```

---

## 6. Validation Checklist

Run through these to verify the full stack is working:

- [ ] `GET /api/v1/products` returns products list
- [ ] `GET /api/v1/services` returns 16 services
- [ ] `GET /api/v1/payment/methods` returns JazzCash + EasyPaisa details
- [ ] Flutter app launches and shows home screen
- [ ] Flutter Google Sign-In completes and returns to home with user name
- [ ] Add product to cart — cart count updates
- [ ] Place order — confirmation email received
- [ ] Upload payment proof — order status changes to PAYMENT_UPLOADED
- [ ] Admin dashboard login works (Google account with ADMIN role)
- [ ] Admin uploads product image — appears in Flutter app product list
- [ ] Admin verifies payment — order status updates in Flutter app
