# Data Model: Fast Printing & Packaging — Complete App Flow

**Feature**: 001-complete-app-flow
**Date**: 2026-03-27
**Source**: Existing `schema.prisma` + Article VIII constitution additions

---

## Entity Relationship Overview

```
User ──────────────── CartItem ──── Product ──── Category
  │                                    │
  ├── WishlistItem ── Product          ├── ProductSpec
  │
  ├── Order ─────────── OrderItem ─── Product
  │       └── PaymentProof
  │
  └── Quote

ContactMessage (standalone)
Industry (standalone, linked to products via industries[] array)
Service (standalone)
```

---

## Entities

### User

Represents any person who has authenticated via Google Sign-In.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK, auto-generated |
| googleId | String | Unique, from Google profile |
| email | String | Unique, from Google profile |
| displayName | String | From Google profile |
| photoUrl | String? | Google profile photo URL |
| phone | String? | Customer-provided |
| role | Role enum | Default: CUSTOMER |
| street | String? | Shipping address |
| city | String? | Shipping address |
| province | String? | Shipping address |
| postalCode | String? | Shipping address |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Role enum**: `CUSTOMER` | `ADMIN`

**State transitions**: CUSTOMER → ADMIN (admin-only action via `PUT /admin/users/:id/role`)

---

### Product

A purchasable printing/packaging product in the catalogue.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| name | String | Required |
| slug | String | Unique, URL-safe |
| description | String | Required |
| category | String | Category slug (denormalised FK) |
| startingPrice | Float | Default: 0 |
| priceUnit | String | Default: "custom quote" |
| imageUrl | String? | **NEW** — primary Cloudinary URL (Article VIII) |
| images | String[] | Legacy multi-image array |
| industries | String[] | Industry slugs this product serves |
| isActive | Boolean | Default: true |
| isFeatured | Boolean | Default: false |
| sortOrder | Int | Default: 0 |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations**: has many `ProductSpec`, `CartItem`, `WishlistItem`, `OrderItem`

---

### ProductSpec

An attribute/option for a product (e.g., Paper Weight: 300gsm, 350gsm).

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| productId | String | FK → Product (cascade delete) |
| label | String | e.g., "Paper Weight" |
| options | String[] | e.g., ["300gsm", "350gsm"] |

---

### Category

A grouping for products. Extracted from `Product.category` string to a proper model.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| name | String | Unique |
| slug | String | Unique, URL-safe |
| description | String? | Optional |
| imageUrl | String? | Cloudinary URL (Article VIII) |
| sortOrder | Int | Default: 0 |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**Relations**: has many `Product` (via `Product.category = Category.slug`)

---

### Service

One of the 16 printing/packaging services offered by XFast.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| name | String | Required |
| slug | String | Unique |
| description | String | Full description |
| shortDescription | String | For list view cards |
| imageUrl | String? | **NEW** — Cloudinary URL (Article VIII) |
| features | String[] | Feature bullet points |
| isActive | Boolean | Default: true |
| sortOrder | Int | Default: 0 |
| createdAt | DateTime | Auto |

---

### Industry

One of the 4 industry verticals XFast serves (e.g., Retail, F&B).

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| name | String | Unique |
| slug | String | Unique |
| description | String? | Optional |
| imageUrl | String? | Cloudinary URL (Article VIII) |
| sortOrder | Int | Default: 0 |
| createdAt | DateTime | Auto |

---

### CartItem

A single product line in a customer's cart.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| userId | String | FK → User (cascade delete) |
| productId | String | FK → Product |
| productName | String | Snapshot at add time |
| quantity | Int | Min: 1 |
| unitPrice | Float | Snapshot at add time |
| totalPrice | Float | quantity × unitPrice |
| customSpecs | Json? | Selected spec options |
| note | String? | Customer note |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

---

### WishlistItem

A product saved to a customer's wishlist.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| userId | String | FK → User (cascade delete) |
| productId | String | FK → Product |
| createdAt | DateTime | Auto |

**Unique constraint**: `(userId, productId)` — one entry per product per user

---

### Order

A confirmed purchase by a customer.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| orderId | String | Unique, human-readable (FP-YYYYMMDD-XXXX) |
| userId | String | FK → User |
| userEmail | String | Snapshot |
| userName | String | Snapshot |
| totalAmount | Float | Sum of order items |
| status | OrderStatus | Default: PENDING_PAYMENT |
| paymentMethod | PaymentMethod | JAZZCASH or EASYPAISA |
| paymentProofUrl | String? | Cloudinary URL of uploaded proof |
| paymentVerifiedAt | DateTime? | When admin verified payment |
| shippingStreet | String? | Delivery address |
| shippingCity | String? | Delivery address |
| shippingProvince | String? | Delivery address |
| shippingPostal | String? | Delivery address |
| notes | String? | Customer notes |
| adminNotes | String? | Internal notes (admin only) |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**OrderStatus enum**:
```
PENDING_PAYMENT → PAYMENT_UPLOADED → CONFIRMED → IN_PRODUCTION → SHIPPED → DELIVERED
                                                                         ↘
                                                                       CANCELLED
```

**PaymentMethod enum**: `JAZZCASH` | `EASYPAISA`

---

### OrderItem

An immutable snapshot of one product line within a placed order.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| orderId | String | FK → Order (cascade delete) |
| productId | String? | FK → Product (nullable — product may be deleted) |
| productName | String | **Immutable snapshot** |
| quantity | Int | Snapshot |
| unitPrice | Float | **Immutable snapshot** |
| totalPrice | Float | **Immutable snapshot** |
| customSpecs | Json? | Snapshot of chosen specs |

---

### PaymentProof

An image uploaded by the customer to confirm payment for an order.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| orderId | String | FK → Order |
| userId | String | FK → User |
| method | PaymentMethod | Payment method used |
| amount | Float | Claimed payment amount |
| proofUrl | String | Cloudinary URL |
| status | ProofStatus | Default: PENDING |
| verifiedAt | DateTime? | When admin verified |
| notes | String? | Admin notes on verification |
| createdAt | DateTime | Auto |

**ProofStatus enum**: `PENDING` | `VERIFIED` | `REJECTED`

---

### Quote

A custom project enquiry submitted by a visitor or signed-in customer.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| quoteId | String | Unique, human-readable |
| userId | String? | FK → User (null for guests) |
| name | String | Required |
| email | String | Required |
| phone | String | Required |
| product | String | Product/service description |
| quantity | Int | Required |
| size | String? | Dimensions |
| material | String? | Paper/material type |
| specialRequirements | String? | Custom notes |
| deliveryLocation | String? | Delivery city |
| deadline | String? | Required by date |
| status | QuoteStatus | Default: PENDING |
| adminResponse | String? | Admin reply message |
| estimatedPrice | Float? | Admin price estimate (PKR) |
| createdAt | DateTime | Auto |
| updatedAt | DateTime | Auto |

**QuoteStatus enum**: `PENDING` | `REVIEWED` | `SENT` | `ACCEPTED` | `REJECTED`

---

### ContactMessage

A general enquiry or feedback message from any visitor.

| Field | Type | Rules |
|-------|------|-------|
| id | String (CUID) | PK |
| name | String | Required |
| email | String | Required |
| phone | String | Required |
| service | String? | Related service (optional) |
| message | String | Required |
| isRead | Boolean | Default: false |
| createdAt | DateTime | Auto |

---

## Schema Changes from Existing `schema.prisma`

| Change | Type | Reason |
|--------|------|--------|
| `Product.imageUrl String?` | ADD field | Article VIII — primary admin-managed image |
| `Service.imageUrl String?` | ADD field | Article VIII — service image management |
| `Category` model | NEW model | Extract from `Product.category` string for CRUD + image |
| `Industry` model | NEW model | Extract from `Product.industries[]` for CRUD + image |
| `Product.categoryId` | OPTIONAL | If normalizing category FK (can keep slug approach) |

**Migration command**: `npx prisma db push` (dev) or `npx prisma migrate dev` (prod)

---

## Validation Rules

| Entity | Field | Rule |
|--------|-------|------|
| Product | slug | Lowercase, hyphens only, unique |
| Product | startingPrice | ≥ 0 |
| CartItem | quantity | Integer ≥ 1 |
| Order | totalAmount | > 0 |
| Quote | quantity | Integer ≥ 1 |
| Quote | email | Valid email format |
| ContactMessage | email | Valid email format |
| PaymentProof | proofUrl | Must be a Cloudinary secure_url |
| User | phone | Optional, Pakistani format preferred |
