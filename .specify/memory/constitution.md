<!--
SYNC IMPACT REPORT
==================
Version change: 1.0.0 → 1.1.0 (MINOR — new principle added)
Modified principles: None renamed
Added sections:
  - Article VIII: Admin Image Management (new non-negotiable principle)
  - New API endpoints table for image upload routes in Article VIII
Removed sections: None
Templates updated:
  - .specify/templates/plan-template.md ✅ — Constitution Check gate applies to image upload routes
  - .specify/templates/spec-template.md ✅ — FR/entity sections cover imageUrl fields naturally
  - .specify/templates/tasks-template.md ✅ — Phase structure accommodates image upload tasks
Deferred TODOs:
  - None — all placeholders resolved
-->

# Fast Printing & Packaging — Constitution

## Core Principles

### I. Free-First Infrastructure (NON-NEGOTIABLE)

Every external service used in this project MUST have a genuine, long-term free tier.
Paid services are prohibited unless explicitly amended with cost justification.

- PostgreSQL: Neon / Supabase / Railway (free 512 MB)
- File storage: Cloudinary (free 25 GB)
- Email: Gmail SMTP via Nodemailer App Password (free)
- Backend hosting: Railway / Render / Fly.io (free tier)
- Admin dashboard hosting: Vercel / Netlify (free tier)
- No AWS, GCP, or Azure services — none have a genuinely free long-term tier.

### II. No Firebase — Ever (NON-NEGOTIABLE)

Firebase is permanently excluded from this project. No exceptions. No amendments allowed
on this principle without a full architectural review and majority team sign-off.

Banned specifically:
- Firebase Auth (replaced by Google OAuth 2.0 → own JWT)
- Firebase Firestore (replaced by PostgreSQL + Prisma)
- Firebase Storage (replaced by Cloudinary)
- Firebase Cloud Messaging (replaced by in-app order status)
- `google-services.json` MUST NOT exist in the Flutter project

Rationale: Firebase creates vendor lock-in, costs money at scale, and obscures data
ownership. Our backend owns all auth tokens, sessions, and user data.

### III. Backend Owns All Auth & Secrets

The backend is the single authority for authentication and sensitive data.
Flutter and the admin dashboard are consumers — never producers — of auth state.

- Google idToken MUST be verified by the backend using `google-auth-library`, never client-side.
- JWTs are signed by the backend with a minimum 64-character secret, expire in 30 days.
- Payment account numbers (JazzCash, EasyPaisa) MUST only be served from the backend
  via `GET /api/v1/payment/methods` — never hardcoded in Flutter or admin code.
- `JWT_SECRET`, `EMAIL_PASS`, `CLOUDINARY_API_SECRET` MUST never appear in any
  Flutter file, admin source file, or Git history.
- Flutter stores JWT in `flutter_secure_storage` only — never `SharedPreferences`.

### IV. Single Codebase, Three Surfaces — Clean Separation

The project consists of three distinct surfaces sharing one backend:

| Surface | Technology | Hosting |
|---------|-----------|---------|
| Mobile App | Flutter ≥ 3.24 | Android (Google Play) |
| Backend API | Node.js 20 + TypeScript + Express | Railway / Render |
| Admin Dashboard | React 18 + Vite + TypeScript | Vercel / Netlify |

Each surface MUST communicate with the backend exclusively via `/api/v1` REST endpoints.
The admin dashboard uses role-gated endpoints (`Role.ADMIN`). The mobile app uses
customer endpoints. There is NO direct database access from Flutter or the admin UI.

Backend architecture: MVC + Service layer.
- Single `src/controllers/index.ts` — all controller functions grouped by domain.
- `src/routes/` — one file per domain, mounted at `/api/v1`.
- `src/middleware/` — auth, error, rate-limit.

### V. State Management Discipline (Flutter)

All Flutter UI state MUST flow through BLoC / Cubit. Direct API calls from `build()`,
`initState()`, or widget constructors are forbidden.

- Every BLoC MUST emit a `Loading` state before any async work begins.
- Every BLoC MUST emit an `Error` state with a human-readable message on failure.
- Optimistic UI is NOT used — always await server confirmation.
- `CartBloc` is registered as `LazySingleton` via `get_it` — one global instance.
- `AuthBloc` is a `Factory` — new instance per request.
- `ApiConstants` is the single source of truth for all endpoint URLs.
  No endpoint path may be hardcoded in any screen or BLoC file.

### VI. API Contract Consistency

All API responses MUST use the standardised shape from `src/utils/response.ts`:

```json
{ "success": true,  "data": {...},   "message": "..." }
{ "success": false, "error": "...",  "code": 400 }
```

- All routes prefixed `/api/v1`.
- Protected routes require `Authorization: Bearer <jwt>` header.
- Rate limiting MUST be applied to auth endpoints via `express-rate-limit`.
- Winston structured logging (coloured in dev, JSON in production) is mandatory.
- Admin-only routes MUST check `req.user.role === 'ADMIN'` via auth middleware.

### VII. Admin Dashboard — Role-Gated Web Panel

The admin dashboard is a separate React + Vite + TypeScript SPA deployed independently.
It authenticates via the same Google OAuth → JWT flow as the mobile app, but only users
with `Role.ADMIN` in the database may access it.

Admin capabilities MUST include:
- Order management: view all orders, update `OrderStatus`, add `adminNotes`
- Payment verification: view payment proof images, mark `ProofStatus` as VERIFIED / REJECTED
- Product & service management: CRUD for products, specs, services, categories, and industries
- Quote management: view all quotes, set `QuoteStatus`, add `adminResponse`, set `estimatedPrice`
- Contact message management: view all messages, mark as read
- User management: view users, promote to ADMIN role
- Dashboard metrics: order counts by status, revenue summary, recent activity

Admin dashboard tech constraints:
- MUST use React 18 + Vite + TypeScript.
- State: React Query (TanStack Query) for server state; Zustand for UI state.
- UI: Tailwind CSS — consistent with brand colours (`#C91A20` primary).
- Auth token stored in `localStorage` (admin is trusted browser environment).
- No backend changes required — admin endpoints added to existing Express routes,
  gated by `requireAdmin` middleware.

### VIII. Admin Image Management — Cloudinary-Backed, Backend-Mediated (NON-NEGOTIABLE)

All entity images (products, services, categories, industries) are managed exclusively
through the admin dashboard and stored in Cloudinary via the backend. Flutter renders
images directly from Cloudinary CDN URLs returned by the API.

**Upload pipeline** (MUST be followed without exception):

```
Admin Panel (React) → POST multipart/form-data or base64
  → Backend (requireAdmin) → Cloudinary SDK upload
    → Cloudinary returns secure_url
      → Backend stores secure_url in DB → returns URL to admin
        → Flutter fetches entity → renders CachedNetworkImage(url)
```

**Backend rules:**
- Image upload endpoints MUST be gated by `requireAdmin` middleware — unauthenticated
  or non-admin requests MUST be rejected with HTTP 403.
- The backend MUST upload to Cloudinary using the SDK; direct Cloudinary API calls
  from the admin panel or Flutter are forbidden.
- Cloudinary folder structure MUST be enforced per entity:

  | Entity | Cloudinary Folder |
  |--------|------------------|
  | Products | `/products` |
  | Services | `/services` |
  | Categories | `/categories` |
  | Industries | `/industries` |

- The backend MUST store only the Cloudinary `secure_url` in the database column
  (`imageUrl` on each entity). Raw upload tokens, public IDs, or credentials MUST
  NOT be stored or returned to clients.
- Accepted input formats: `multipart/form-data` file field OR base64-encoded string.
  The backend normalises both before passing to the Cloudinary SDK.

**Database rules:**
- Every entity that supports images MUST have an `imageUrl String?` column in
  `schema.prisma`. This applies to: `Product`, `Service`, `Category`, `Industry`.
- Schema changes adding `imageUrl` fields are a PATCH migration; no formal amendment
  to this constitution is required.

**Admin dashboard rules:**
- The admin panel MUST use a single reusable `<ImageUpload />` React component for
  all entity image fields. This component MUST:
  - Show a local preview before the form is submitted.
  - Accept only image MIME types (`image/jpeg`, `image/png`, `image/webp`).
  - Display upload progress and clear error states.
- No image binary data may be persisted in admin panel state after a successful upload;
  only the returned `imageUrl` string is retained.

**Flutter rules:**
- ALL entity images in the Flutter app MUST be rendered using `CachedNetworkImage`.
  Direct `Image.network()` calls for entity images are forbidden.
- Every `CachedNetworkImage` MUST provide:
  - A `placeholder` (shimmer or skeleton widget) while loading.
  - An `errorWidget` fallback for failed/missing images.
- `imageUrl` fields returned by the API MAY be `null`; Flutter MUST handle null
  gracefully (show placeholder asset, never crash).
- No images are stored locally in the app. All entity images are served from the
  Cloudinary CDN on demand.

**Image upload API endpoints** (admin-only, all require `Authorization: Bearer <jwt>`
with `Role.ADMIN`):

```
POST  /api/v1/admin/products/:id/image      Upload/replace product image
POST  /api/v1/admin/services/:id/image      Upload/replace service image
POST  /api/v1/admin/categories/:id/image    Upload/replace category image
POST  /api/v1/admin/industries/:id/image    Upload/replace industry image
```

All four endpoints accept `multipart/form-data` with a single `image` field and
return `{ success: true, data: { imageUrl: "https://res.cloudinary.com/..." } }`.

---

## Technology Stack

### Backend

| Layer | Technology | Version |
|-------|-----------|---------|
| Runtime | Node.js | ≥ 20 LTS |
| Language | TypeScript | ≥ 5.5 |
| Framework | Express.js | ≥ 4.19 |
| Database | PostgreSQL | 16 |
| ORM | Prisma | ≥ 5.16 |
| Auth verification | google-auth-library | ≥ 9 |
| Sessions | jsonwebtoken | ≥ 9 |
| Email | Nodemailer | ≥ 6.9 |
| File upload | Cloudinary SDK | ≥ 2.4 |
| Multipart parsing | multer | ≥ 1.4 |
| Security | helmet, cors, express-rate-limit | Latest |
| Logging | Winston | ≥ 3.13 |
| Process manager | PM2 (prod) | Latest |

### Flutter Mobile

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter | ≥ 3.24 |
| Language | Dart | ≥ 3.5 |
| State | flutter_bloc | ≥ 8.1 |
| Navigation | go_router | ≥ 14 |
| HTTP | Dio | ≥ 5.4 |
| Auth | google_sign_in | ≥ 6.2 |
| Token storage | flutter_secure_storage | ≥ 9.2 |
| Images | cached_network_image | ≥ 3.4 |
| DI | get_it + injectable | ≥ 8.0 |
| Links | url_launcher | ≥ 6.3 |

### Admin Dashboard

| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | React | 18 |
| Build tool | Vite | ≥ 5 |
| Language | TypeScript | ≥ 5 |
| Server state | TanStack Query | ≥ 5 |
| UI state | Zustand | ≥ 4 |
| Styling | Tailwind CSS | ≥ 3 |
| HTTP | Axios | ≥ 1.7 |
| Auth | Google Sign-In (same flow) | — |
| Forms | React Hook Form + Zod | Latest |

---

## Development Workflow

### Branch Strategy

- `main` — production-ready code only
- `feature/<name>` — all new features
- `fix/<name>` — bug fixes
- Direct pushes to `main` are forbidden; all changes via PR

### Environment Configuration

All three surfaces read from `.env` files that are `.gitignored`.
`.env.example` MUST be kept up to date with every new variable.
No environment variable may have a default value that exposes a secret.

Required backend variables:
`PORT`, `NODE_ENV`, `DATABASE_URL`, `GOOGLE_CLIENT_ID`, `JWT_SECRET`, `JWT_EXPIRE`,
`EMAIL_USER`, `EMAIL_PASS`, `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`,
`CLOUDINARY_API_SECRET`, `JAZZCASH_NUMBER`, `EASYPAISA_NUMBER`, `PAYMENT_ACCOUNT_NAME`

Required admin variables:
`VITE_API_BASE_URL`, `VITE_GOOGLE_CLIENT_ID`

### Database Changes

- Schema changes MUST be made in `schema.prisma` only.
- Apply with `npx prisma db push` (dev) or migration files (prod).
- Seed script (`npm run db:seed`) MUST remain runnable after any schema change.
- Breaking schema changes require a formal amendment to this constitution.

### Code Quality Gates

Before any PR merges:
- TypeScript strict mode — zero `any` types without comment justification
- No hardcoded secrets, payment numbers, or API URLs in any source file
- Winston logging present for all new controller functions
- Admin routes include `requireAdmin` middleware check
- Image upload routes use `multer` middleware and pass through Cloudinary SDK only

---

## Governance

This constitution supersedes all other technical guidance documents, README files,
and verbal agreements. Any decision that conflicts with an article herein requires
a formal amendment.

**Amendment procedure:**
1. Identify the article to change and the reason.
2. Increment the version following semantic versioning:
   - MAJOR: principle removal, redefinition, or technology replacement.
   - MINOR: new principle, new section, or material expansion.
   - PATCH: clarifications, wording, typo fixes.
3. Update `Last Amended` date to today (ISO format).
4. Propagate changes to `.specify/templates/` as needed.
5. Commit with message: `docs: amend constitution to vX.Y.Z (<summary>)`

All PRs and code reviews MUST verify compliance with the principles in this document.
Complexity that violates a principle MUST be justified in a `Complexity Tracking` table
in the relevant `plan.md` before implementation begins.

**Version**: 1.1.0 | **Ratified**: 2025-01-01 | **Last Amended**: 2026-03-27
