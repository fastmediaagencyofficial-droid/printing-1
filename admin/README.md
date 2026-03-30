# Fast Printing & Packaging — Admin Dashboard

React 18 · Vite · TypeScript · TanStack Query v5 · Zustand · Tailwind CSS · React Hook Form · Zod

Internal dashboard for XFast Group staff to manage products, orders, quotes, and customers.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | React 18 + TypeScript |
| Build tool | Vite 5 |
| Styling | Tailwind CSS (brand color: `#C91A20`) |
| Server state | TanStack Query v5 (auto-refetch, caching) |
| Client state | Zustand (auth token, persisted to localStorage) |
| HTTP | Axios + Bearer token interceptor |
| Forms | React Hook Form + Zod validation |
| Icons | Lucide React |
| Router | React Router v6 |

---

## Project Structure

```
admin/
├── public/
├── src/
│   ├── components/
│   │   ├── Layout.tsx          # Collapsible sidebar + nav + user info + sign out
│   │   ├── StatusBadge.tsx     # Color-coded status chips (order + quote statuses)
│   │   └── ImageUpload.tsx     # File input + local preview + MIME/size validation
│   ├── hooks/
│   │   ├── useDashboard.ts     # Dashboard metrics query (60s auto-refetch)
│   │   ├── useProducts.ts      # Product CRUD + image upload mutations
│   │   ├── useServices.ts      # Service update + image upload mutations
│   │   ├── useCategories.ts    # Category CRUD + image upload mutations
│   │   ├── useIndustries.ts    # Industry CRUD + image upload mutations
│   │   ├── useOrders.ts        # Order list/detail + status update + payment verify
│   │   ├── useQuotes.ts        # Quote list + update with response + price
│   │   ├── useContacts.ts      # Contact inbox + mark-read
│   │   └── useUsers.ts         # User list + role change
│   ├── pages/
│   │   ├── LoginPage.tsx              # Paste Google idToken → POST /auth/google-login
│   │   ├── DashboardPage.tsx          # Metric cards + order status breakdown + recent orders
│   │   ├── products/
│   │   │   ├── ProductListPage.tsx    # Searchable table + delete
│   │   │   └── ProductFormPage.tsx    # Create/edit with ImageUpload + Zod validation
│   │   ├── services/
│   │   │   ├── ServiceListPage.tsx    # Service table (edit only)
│   │   │   └── ServiceFormPage.tsx    # Edit name/description/image/sort order
│   │   ├── categories/
│   │   │   └── CategoryListPage.tsx   # Inline create/edit/delete + image upload
│   │   ├── industries/
│   │   │   └── IndustryListPage.tsx   # Card grid + inline form
│   │   ├── orders/
│   │   │   ├── OrderListPage.tsx      # Status-filter tabs + payment proof link
│   │   │   └── OrderDetailPage.tsx    # Items + verify/reject payment + status update
│   │   ├── quotes/
│   │   │   ├── QuoteListPage.tsx      # Status filter + customer info
│   │   │   └── QuoteDetailPage.tsx    # Respond with status/price/notes
│   │   ├── contacts/
│   │   │   └── ContactListPage.tsx    # Expandable accordion + auto-mark-read
│   │   └── users/
│   │       └── UserListPage.tsx       # Inline role selector (CUSTOMER ↔ ADMIN)
│   ├── services/
│   │   └── api.ts              # Axios instance + Bearer interceptor + 401 → /login
│   ├── stores/
│   │   └── auth.store.ts       # Zustand auth store (persisted to localStorage)
│   ├── App.tsx                 # Routes + ProtectedRoute guard
│   ├── main.tsx                # ReactDOM + QueryClient + BrowserRouter
│   └── index.css               # Tailwind directives
├── index.html
├── tailwind.config.ts
├── vite.config.ts
├── tsconfig.json
├── .env.example
└── package.json
```

---

## Features

### Dashboard (Home)

- **6 metric cards**: Total Orders, Revenue (PKR), Pending Payments, Unread Contacts, Total Products, Pending Quotes
- **Orders by Status**: Visual breakdown of all status counts
- **Recent Orders table**: Last 10 orders with customer, amount, status
- **Auto-refresh**: Data refreshes every 60 seconds automatically

### Products Management

- View all products with thumbnail, category, price, active/featured status
- **Search** products by name or category
- **Create** new product with name, slug, description, price, category, active/featured toggles
- **Edit** existing product (all fields)
- **Upload product image** → stored on Cloudinary, served via CDN
- **Delete** product (safely removes from cart items, preserves order snapshots)

### Services Management

- View 16 seeded services with thumbnails
- **Edit** service name, short description, full description, icon emoji, sort order
- **Upload service image** → Cloudinary

### Categories

- **Create** categories (name, slug, description, sort order)
- **Edit** any category inline (no page navigation)
- **Upload category image**
- **Delete** category (blocked if products reference this slug)

### Industries

- **Create/Edit** industries with card grid layout
- **Upload industry image**

### Orders

- **Filter by status**: All / Pending Payment / Payment Uploaded / Confirmed / In Production / Shipped / Delivered / Cancelled
- View payment proof images from Cloudinary
- **Verify** or **Reject** payment proofs (updates order status + sends confirmation email)
- **Update order status** (any valid transition)

### Quotes

- **Filter by status**: All / Pending / Reviewed / Sent / Accepted / Rejected
- **Respond to quotes** with: new status, quoted price (PKR), response message to customer

### Contact Inbox

- View all contact messages sorted by date
- **Accordion expand** to read full message
- **Auto-mark as read** when expanded
- **Filter**: All messages / Unread only

### User Management

- View all registered users with order count
- **Change role** inline: CUSTOMER ↔ ADMIN
- Search users by name or email

---

## Setup

### 1. Environment variables

```bash
cd admin
cp .env.example .env
```

```env
VITE_API_BASE_URL=http://localhost:5000/api/v1
VITE_GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
```

### 2. Install and run

```bash
cd admin
npm install
npm run dev
# Opens at http://localhost:5173
```

---

## First-Time Login

The admin dashboard uses **direct Google idToken auth** (paste a token, not a Google sign-in button) to avoid OAuth redirect complexity for internal tools.

### How to get your first admin token:

**Option A — From Flutter app (developer mode)**

1. Sign in to the Flutter app with your Google account
2. In `auth_bloc.dart`, temporarily log the JWT or idToken to console
3. Copy the idToken (valid for 1 hour)

**Option B — Google OAuth Playground**

1. Open https://developers.google.com/oauthplayground
2. In Step 1: select `https://www.googleapis.com/auth/userinfo.email`
3. In Settings (gear icon): check "Use your own OAuth credentials", enter your client ID + secret
4. Authorize → Exchange code → copy `id_token` from the response

**Option C — curl**

```bash
# If you have a refresh token, use:
curl -X POST https://oauth2.googleapis.com/token \
  -d "grant_type=refresh_token&refresh_token=YOUR_REFRESH_TOKEN&client_id=YOUR_CLIENT_ID&client_secret=YOUR_SECRET"
```

### Promote yourself to Admin

After signing into the Flutter app at least once (to create your user record):

```sql
-- Run in your PostgreSQL database (Neon/Supabase/Railway dashboard)
UPDATE users SET role = 'ADMIN' WHERE email = 'your@email.com';
```

### Sign In to Dashboard

1. Go to `http://localhost:5173/login`
2. Paste your Google idToken in the text area
3. Click "Sign In"
4. You'll be redirected to the dashboard if your account has ADMIN role

---

## Production Deployment

### Vercel (recommended — free)

```bash
# 1. Build locally to verify
npm run build

# 2. Push admin/ to GitHub (or connect the repo root)

# 3. In Vercel:
#    - New Project → Import from GitHub
#    - Root directory: admin
#    - Build command: npm run build
#    - Output directory: dist
#    - Set environment variables:
#      VITE_API_BASE_URL = https://your-api.railway.app/api/v1
#      VITE_GOOGLE_CLIENT_ID = your_client_id.apps.googleusercontent.com
```

### Netlify (alternative)

```bash
# Build command: npm run build
# Publish directory: dist
# Add _redirects file to dist/:
echo "/* /index.html 200" > dist/_redirects
```

### Self-hosted

```bash
npm run build
# Serve the dist/ folder with nginx or any static file server
# Example nginx config (SPA routing):
# location / { try_files $uri $uri/ /index.html; }
```

---

## End-to-End Test Checklist

### Auth
- [ ] Go to `/login` → paste a valid Google idToken → click Sign In
- [ ] If email has ADMIN role → redirected to `/dashboard`
- [ ] If email has CUSTOMER role → shows "Access denied" error
- [ ] Invalid/expired token → shows error message
- [ ] Click Sign Out → redirected to login; direct URL access redirects back to login

### Dashboard
- [ ] Metric cards load (total orders, revenue, pending, contacts, products, quotes)
- [ ] Orders by status shows correct breakdown
- [ ] Recent orders table populates
- [ ] Wait 60 seconds → data auto-refreshes (check timestamp in recent orders)

### Products
- [ ] Products list loads with images
- [ ] Search "box" → filtered results
- [ ] Click "Add Product" → create form opens
- [ ] Fill form → click "Create Product" → product appears in list
- [ ] Click edit (pencil icon) → edit form opens with existing values
- [ ] Upload image → image preview updates; saved to Cloudinary
- [ ] Delete product → confirm dialog → product removed from list
- [ ] Open Flutter app → new product appears in product grid

### Services
- [ ] Services list shows 16 services with thumbnails
- [ ] Edit a service → change description → save → Flutter app shows updated description

### Categories
- [ ] Create new category → appears in list
- [ ] Edit category → inline form → save
- [ ] Delete category with no products → removed
- [ ] Delete category with products → should show error

### Orders
- [ ] Status tabs filter correctly (try "Payment Uploaded")
- [ ] Click eye icon → order detail opens
- [ ] Payment proof image visible (if customer uploaded one)
- [ ] "Verify Payment" → status changes to Confirmed; confirmation email sent to customer
- [ ] "Reject" → status stays at Payment Uploaded (for re-upload)
- [ ] Status dropdown → change to "In Production" → saved

### Quotes
- [ ] Quote list loads with status badges
- [ ] Filter by "PENDING" → only pending quotes shown
- [ ] Click detail → customer info + project details visible
- [ ] Set quoted price + response → click "Save Response"
- [ ] Open Flutter My Quotes → quote shows price + response

### Contacts
- [ ] Contact list loads
- [ ] Click to expand a message → full message visible → automatically marked as read
- [ ] Toggle "Unread only" → filter works
- [ ] Send a contact form in Flutter → new message appears here

### Users
- [ ] User list loads with order counts
- [ ] Change a user role from CUSTOMER to ADMIN → confirm prompt
- [ ] Search "test" → filters results

---

## Troubleshooting

| Issue | Fix |
|---|---|
| "Access denied" on login | User's role in database is not ADMIN; run the SQL UPDATE command |
| Token paste → "Authentication failed" | idToken expired (1 hour TTL); get a fresh token |
| Blank dashboard / 401 errors | Auth token in localStorage expired; sign out and sign in again |
| Images not uploading | Check Cloudinary credentials in backend `.env` |
| Can't delete category | Products still reference that category slug; reassign or delete products first |
| API 404 errors | Check `VITE_API_BASE_URL` in `.env`; ensure backend is running |
| CORS errors | Add `http://localhost:5173` to `ALLOWED_ORIGINS` in backend `.env` |
| `npm run build` fails | Run `npm install` first; check TypeScript errors with `npx tsc --noEmit` |
