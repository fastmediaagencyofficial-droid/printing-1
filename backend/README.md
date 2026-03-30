# Fast Printing & Packaging — Backend API

Node.js 20 · TypeScript · Express · PostgreSQL · Prisma · Google OAuth 2.0 · JWT · Nodemailer · Cloudinary

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js 20 + TypeScript |
| Framework | Express 4 |
| Database | PostgreSQL 16 (Neon / Supabase / Railway — free tier) |
| ORM | Prisma 5 |
| Auth | Google OAuth 2.0 via `google-auth-library` → 30-day JWT |
| Images | Cloudinary (free 25 GB) — multer memory storage → upload stream |
| Email | Nodemailer + Gmail SMTP App Password |
| Logging | Winston + Morgan |
| Security | Helmet, CORS allowlist, express-rate-limit |

---

## Project Structure

```
backend/
├── prisma/
│   ├── schema.prisma        # Database schema (12 models)
│   └── seed.ts              # Seeds 16 services, 23 products, 6 categories, 4 industries
├── src/
│   ├── config/
│   │   ├── cloudinary.ts    # Cloudinary SDK init + uploadImage(Buffer|string, folder)
│   │   ├── database.ts      # Prisma client singleton
│   │   ├── email.ts         # Nodemailer transport config
│   │   └── google-auth.ts   # OAuth2Client setup
│   ├── controllers/
│   │   └── index.ts         # ALL controller functions (auth, products, services,
│   │                        #   cart, wishlist, orders, payment, quotes, contact,
│   │                        #   industries, admin CRUD + dashboard)
│   ├── middleware/
│   │   ├── auth.middleware.ts    # authMiddleware (JWT verify) + adminMiddleware (role check)
│   │   ├── error.middleware.ts   # Global Express error handler
│   │   ├── rateLimit.middleware.ts # express-rate-limit (10 req/15min on auth routes)
│   │   └── upload.middleware.ts  # multer memory storage, MIME filter, 5 MB limit
│   ├── routes/
│   │   ├── auth.routes.ts        # /api/v1/auth
│   │   ├── product.routes.ts     # /api/v1/products
│   │   ├── service.routes.ts     # /api/v1/services
│   │   ├── cart.routes.ts        # /api/v1/cart
│   │   ├── wishlist.routes.ts    # /api/v1/wishlist
│   │   ├── order.routes.ts       # /api/v1/orders
│   │   ├── payment.routes.ts     # /api/v1/payment
│   │   ├── quote.routes.ts       # /api/v1/quotes
│   │   ├── contact.routes.ts     # /api/v1/contact
│   │   ├── industry.routes.ts    # /api/v1/industries
│   │   └── admin.routes.ts       # /api/v1/admin (all protected)
│   ├── utils/
│   │   ├── jwt.ts           # signToken / verifyToken
│   │   ├── logger.ts        # Winston logger instance
│   │   ├── response.ts      # successResponse / errorResponse helpers
│   │   └── seed.ts          # Seed script entry point
│   └── server.ts            # Express app + HTTP server
├── .env.example
├── package.json
└── tsconfig.json
```

---

## Database Schema

12 models in PostgreSQL via Prisma:

| Model | Purpose |
|---|---|
| `User` | Customer/admin accounts (Google OAuth, JWT) |
| `Product` | Printable products with specs, pricing, imageUrl |
| `ProductSpec` | Custom spec options per product |
| `Service` | 16 printing services with imageUrl |
| `Category` | Product categories with slug + imageUrl |
| `Industry` | 4 industry verticals with imageUrl |
| `CartItem` | Shopping cart items (per user, per product) |
| `WishlistItem` | Saved products per user |
| `Order` | Customer orders with status workflow |
| `OrderItem` | Snapshot of product at time of order |
| `PaymentProof` | Cloudinary URL of uploaded payment screenshot |
| `Quote` | Custom quote requests with admin response |
| `ContactMessage` | Contact form submissions |

Order status flow: `PENDING_PAYMENT → PAYMENT_UPLOADED → CONFIRMED → IN_PRODUCTION → SHIPPED → DELIVERED` (or `CANCELLED`)

---

## Environment Setup

### 1. Copy and fill environment variables

```bash
cp .env.example .env
```

```env
PORT=5000
NODE_ENV=development

# PostgreSQL — get free DB from https://neon.tech
DATABASE_URL="postgresql://USER:PASS@HOST:5432/fastprinting?sslmode=require"

# Google OAuth — create at https://console.cloud.google.com
GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com

# JWT
JWT_SECRET=minimum_64_char_random_secret_change_this_in_production
JWT_EXPIRE=30d

# Gmail SMTP — use App Password (not your Gmail password)
# Enable: Google Account > Security > 2FA > App Passwords
EMAIL_USER=your.gmail@gmail.com
EMAIL_PASS=xxxx xxxx xxxx xxxx

# Cloudinary — https://cloudinary.com (free 25 GB)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Payment accounts (served from backend only — never expose in frontend)
JAZZCASH_NUMBER=0325-2467463
EASYPAISA_NUMBER=0321-0846667
PAYMENT_ACCOUNT_NAME=XFast Group

# CORS — comma-separated list of allowed origins
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### 2. Free PostgreSQL options

| Provider | Free Tier | URL |
|---|---|---|
| **Neon** (recommended) | 512 MB, 1 branch | https://neon.tech |
| Supabase | 500 MB | https://supabase.com |
| Railway | $5 credit/month | https://railway.app |

### 3. Install and run

```bash
cd backend
npm install
npx prisma generate
npm run db:push          # Apply schema to database (creates all tables)
npm run db:seed          # Seed 16 services + 23 products + 6 categories + 4 industries
npm run dev              # Development server with hot-reload (ts-node-dev)
```

---

## API Reference

All routes prefixed with `/api/v1`. Protected routes `[P]` require `Authorization: Bearer <jwt>`.

### Auth

| Method | Route | Auth | Description |
|---|---|---|---|
| POST | `/auth/google-login` | — | Verify Google idToken → return JWT + user |
| GET | `/auth/me` | [P] | Get current user profile |
| PUT | `/auth/profile` | [P] | Update phone + address |

### Products

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/products` | — | List products (filter: `?category`, `?search`, `?featured`) |
| GET | `/products/categories` | — | All categories |
| GET | `/products/:id` | — | Single product with specs |

### Services

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/services` | — | All 16 services |
| GET | `/services/:slug` | — | Single service by slug |

### Cart

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/cart` | [P] | Get cart with total |
| POST | `/cart/add` | [P] | Add item `{productId, quantity, customSpecs?}` |
| PUT | `/cart/item/:id` | [P] | Update quantity |
| DELETE | `/cart/item/:id` | [P] | Remove item |
| DELETE | `/cart/clear` | [P] | Clear all items |

### Wishlist

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/wishlist` | [P] | Get wishlist with products |
| POST | `/wishlist/add` | [P] | Add `{productId}` |
| DELETE | `/wishlist/:productId` | [P] | Remove product |
| POST | `/wishlist/move-to-cart/:productId` | [P] | Move to cart |

### Orders

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/orders` | [P] | Order history (paginated) |
| POST | `/orders` | [P] | Place order (clears cart, sends confirmation email) |
| GET | `/orders/:id` | [P] | Order detail with items |
| POST | `/orders/:id/payment-proof` | [P] | Upload payment screenshot (multipart/form-data) |
| PUT | `/orders/:id/cancel` | [P] | Cancel if still `PENDING_PAYMENT` |

### Payment

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/payment/methods` | — | JazzCash + EasyPaisa account details |

### Quotes

| Method | Route | Auth | Description |
|---|---|---|---|
| POST | `/quotes/request` | — | Submit quote request (sends email to team) |
| GET | `/quotes/my` | [P] | User's quote history |

### Contact

| Method | Route | Auth | Description |
|---|---|---|---|
| POST | `/contact` | — | Send message (team notification + auto-reply to customer) |

### Industries

| Method | Route | Auth | Description |
|---|---|---|---|
| GET | `/industries` | — | All 4 industries |

### Admin (all require ADMIN role)

| Method | Route | Description |
|---|---|---|
| GET | `/admin/dashboard` | Metrics: orders, revenue, pending, recent |
| GET/POST/PUT/DELETE | `/admin/products` | Product CRUD |
| POST | `/admin/products/:id/image` | Upload product image to Cloudinary |
| GET/POST/PUT | `/admin/services` | Service management |
| POST | `/admin/services/:id/image` | Upload service image |
| GET/POST/PUT/DELETE | `/admin/categories` | Category CRUD |
| POST | `/admin/categories/:id/image` | Upload category image |
| GET/POST/PUT | `/admin/industries` | Industry management |
| POST | `/admin/industries/:id/image` | Upload industry image |
| GET | `/admin/orders` | All orders (filter `?status`) |
| GET/PUT | `/admin/orders/:id` | Order detail / update status |
| PUT | `/admin/orders/:id/verify-payment` | Verify or reject payment proof |
| GET/PUT | `/admin/quotes` | Quote management |
| GET/PUT | `/admin/contacts` | Contact inbox |
| GET/PUT | `/admin/users` | User management + role changes |

---

## Scripts

```bash
npm run dev          # Development with hot-reload
npm run build        # Compile TypeScript to dist/
npm start            # Production (requires npm run build first)
npm run db:push      # Sync Prisma schema with database
npm run db:seed      # Seed initial data
npm run db:studio    # Open Prisma Studio (DB GUI at localhost:5555)
```

---

## Production Deployment

### Railway (recommended — free $5/month credit)

```bash
# 1. Push to GitHub
git push origin main

# 2. Create Railway project → connect GitHub repo → set root directory to backend/
# 3. Add PostgreSQL plugin in Railway dashboard
# 4. Set environment variables in Railway dashboard (all from .env)
# 5. Railway auto-deploys on git push

# First deploy — run these manually via Railway shell:
npm run db:push
npm run db:seed
```

### Render (alternative — free tier available)

```bash
# Build command: npm install && npx prisma generate && npm run build
# Start command: npm start
# Set all environment variables in Render dashboard
```

### Docker

```bash
cd backend
docker build -t fast-printing-api .
docker run -p 5000:5000 --env-file .env fast-printing-api
```

---

## Testing the API

### Quick health check

```bash
curl http://localhost:5000/health
```

### Test auth flow

```bash
# 1. Get a Google idToken from the Flutter app or OAuth Playground
# 2. POST to /api/v1/auth/google-login
curl -X POST http://localhost:5000/api/v1/auth/google-login \
  -H "Content-Type: application/json" \
  -d '{"idToken": "YOUR_GOOGLE_ID_TOKEN"}'

# Response: { "success": true, "data": { "token": "JWT...", "user": {...} } }
```

### Test protected routes

```bash
export JWT="eyJ..."  # from login response

curl http://localhost:5000/api/v1/cart \
  -H "Authorization: Bearer $JWT"

curl http://localhost:5000/api/v1/orders \
  -H "Authorization: Bearer $JWT"
```

### Test admin dashboard

```bash
# Must be a user with role='ADMIN' in the users table
# SQL to promote: UPDATE users SET role = 'ADMIN' WHERE email = 'your@email.com';

curl http://localhost:5000/api/v1/admin/dashboard \
  -H "Authorization: Bearer $ADMIN_JWT"
```

---

## End-to-End Test Checklist

- [ ] `GET /health` → `{ status: "ok" }`
- [ ] `POST /auth/google-login` with valid idToken → returns JWT
- [ ] `GET /products` → returns seeded products with imageUrl
- [ ] `GET /services` → returns 16 services
- [ ] `GET /payment/methods` → returns JazzCash + EasyPaisa numbers
- [ ] `POST /cart/add` with JWT → cart item created
- [ ] `POST /orders` with JWT → order created, confirmation email sent
- [ ] `POST /orders/:id/payment-proof` → image uploaded to Cloudinary, status = PAYMENT_UPLOADED
- [ ] `GET /admin/dashboard` with ADMIN JWT → metrics returned
- [ ] `PUT /admin/orders/:id/verify-payment` with `{ "action": "VERIFY" }` → status = CONFIRMED

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `DATABASE_URL` connection error | Check Neon/Supabase connection string; ensure `?sslmode=require` |
| Google login fails | Verify `GOOGLE_CLIENT_ID` matches your OAuth app; check idToken is fresh (expires in 1 hour) |
| Emails not sending | Use Gmail App Password (not account password); enable 2FA first |
| Cloudinary upload fails | Check `CLOUD_NAME`, `API_KEY`, `API_SECRET` in `.env` |
| `prisma generate` fails | Run `npm install` first; check Node.js version is 18+ |
| 401 on protected routes | JWT may be expired (30-day); re-login to get fresh token |
| CORS errors from admin | Add admin origin to `ALLOWED_ORIGINS` in `.env` |
