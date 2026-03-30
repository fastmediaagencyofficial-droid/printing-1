# API Contracts: Fast Printing & Packaging — Complete App Flow

**Base URL**: `/api/v1`
**Auth**: Protected routes require `Authorization: Bearer <jwt>`
**Admin**: Admin routes additionally require `Role.ADMIN` on the authenticated user
**Response shape** (all endpoints):
```json
{ "success": true,  "data": { ... },  "message": "..." }
{ "success": false, "error": "...",   "code": 400 }
```

---

## AUTH

### POST /auth/google-login
Verify Google idToken and return XFast JWT. Rate-limited.

**Request**:
```json
{ "idToken": "string" }
```

**Response 200**:
```json
{
  "success": true,
  "data": {
    "token": "eyJ...",
    "user": {
      "id": "cuid",
      "email": "user@gmail.com",
      "displayName": "Ali Khan",
      "photoUrl": "https://...",
      "role": "CUSTOMER"
    }
  },
  "message": "Login successful"
}
```

**Errors**: 400 (missing idToken), 401 (invalid idToken)

---

### GET /auth/me [Protected]
Return the authenticated user's profile.

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": "cuid",
    "email": "user@gmail.com",
    "displayName": "Ali Khan",
    "photoUrl": "https://...",
    "phone": "0300-1234567",
    "role": "CUSTOMER",
    "street": "101A J1 Block",
    "city": "Lahore",
    "province": "Punjab",
    "postalCode": "54000"
  }
}
```

---

### PUT /auth/profile [Protected]
Update the authenticated user's profile.

**Request**:
```json
{
  "phone": "string?",
  "street": "string?",
  "city": "string?",
  "province": "string?",
  "postalCode": "string?"
}
```

**Response 200**: Updated user object.

---

## PRODUCTS

### GET /products
List all active products. Supports filters and pagination.

**Query params**: `?category=<slug>&search=<text>&featured=true&page=1&limit=20`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "cuid",
        "name": "Business Cards",
        "slug": "business-cards",
        "description": "...",
        "category": "cards",
        "startingPrice": 500,
        "priceUnit": "per 100",
        "imageUrl": "https://res.cloudinary.com/...",
        "images": [],
        "isFeatured": true,
        "sortOrder": 1
      }
    ],
    "total": 23,
    "page": 1,
    "limit": 20
  }
}
```

---

### GET /products/categories
List all product categories.

**Response 200**:
```json
{
  "success": true,
  "data": {
    "categories": [
      { "id": "cuid", "name": "Business Cards", "slug": "cards", "imageUrl": "https://..." }
    ]
  }
}
```

---

### GET /products/:id
Get a single product by ID (includes specs).

**Response 200**: Full product object with `specs[]`.

---

## SERVICES

### GET /services
List all active services.

**Response 200**:
```json
{
  "success": true,
  "data": {
    "services": [
      {
        "id": "cuid",
        "name": "Offset Printing",
        "slug": "offset-printing",
        "shortDescription": "...",
        "imageUrl": "https://res.cloudinary.com/...",
        "sortOrder": 1
      }
    ]
  }
}
```

---

### GET /services/:slug
Get a single service by slug (includes full description and features).

**Response 200**: Full service object.

---

## CATEGORIES

### GET /categories
List all categories (public).

**Response 200**: `{ "categories": [ { id, name, slug, description, imageUrl, sortOrder } ] }`

---

## INDUSTRIES

### GET /industries
List all industries (public).

**Response 200**:
```json
{
  "success": true,
  "data": {
    "industries": [
      { "id": "cuid", "name": "Retail", "slug": "retail", "description": "...", "imageUrl": "https://..." }
    ]
  }
}
```

---

## CART

### GET /cart [Protected]
Get the authenticated user's cart with line items and total.

**Response 200**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "cuid",
        "productId": "cuid",
        "productName": "Business Cards",
        "quantity": 2,
        "unitPrice": 500,
        "totalPrice": 1000,
        "customSpecs": { "paperWeight": "300gsm" }
      }
    ],
    "total": 1000,
    "itemCount": 2
  }
}
```

---

### POST /cart/add [Protected]
Add a product to the cart.

**Request**:
```json
{
  "productId": "cuid",
  "quantity": 1,
  "customSpecs": { "paperWeight": "300gsm" },
  "note": "string?"
}
```

**Response 200**: Updated cart.

---

### PUT /cart/item/:id [Protected]
Update quantity of a cart item.

**Request**: `{ "quantity": 3 }`

**Response 200**: Updated cart item.

---

### DELETE /cart/item/:id [Protected]
Remove a cart item.

**Response 200**: `{ "message": "Item removed" }`

---

### DELETE /cart/clear [Protected]
Clear all items from the cart.

**Response 200**: `{ "message": "Cart cleared" }`

---

## WISHLIST

### GET /wishlist [Protected]
Get the authenticated user's wishlist (includes product details).

**Response 200**: `{ "items": [ { id, product: { id, name, imageUrl, startingPrice } } ] }`

---

### POST /wishlist/add [Protected]
Add a product to the wishlist.

**Request**: `{ "productId": "cuid" }`

**Response 200**: `{ "message": "Added to wishlist" }`

---

### DELETE /wishlist/:productId [Protected]
Remove a product from the wishlist.

**Response 200**: `{ "message": "Removed from wishlist" }`

---

### POST /wishlist/move-to-cart/:productId [Protected]
Move a wishlist item to the cart and remove it from the wishlist.

**Request**: `{ "quantity": 1, "customSpecs": {} }`

**Response 200**: Updated cart.

---

## ORDERS

### GET /orders [Protected]
List the authenticated user's orders (paginated, newest first).

**Query params**: `?page=1&limit=10`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "cuid",
        "orderId": "FP-20240601-1234",
        "status": "PENDING_PAYMENT",
        "totalAmount": 2500,
        "paymentMethod": "JAZZCASH",
        "createdAt": "2024-06-01T10:00:00Z",
        "itemCount": 3
      }
    ],
    "total": 5
  }
}
```

---

### POST /orders [Protected]
Place a new order from the current cart. Clears cart. Sends confirmation email.

**Request**:
```json
{
  "paymentMethod": "JAZZCASH",
  "shippingStreet": "string?",
  "shippingCity": "string?",
  "shippingProvince": "string?",
  "shippingPostal": "string?",
  "notes": "string?"
}
```

**Response 201**:
```json
{
  "success": true,
  "data": {
    "order": {
      "id": "cuid",
      "orderId": "FP-20240601-1234",
      "status": "PENDING_PAYMENT",
      "totalAmount": 2500,
      "items": [ ... ]
    }
  },
  "message": "Order placed successfully. Confirmation email sent."
}
```

**Errors**: 400 (empty cart), 400 (invalid paymentMethod)

---

### GET /orders/:id [Protected]
Get a single order by ID (includes items, payment details, and payment methods).

**Response 200**: Full order object with items and payment account numbers.

---

### POST /orders/:id/payment-proof [Protected]
Upload payment proof screenshot. Accepts `multipart/form-data` with `image` field.

**Request**: `multipart/form-data` with field `image` (JPEG/PNG/WEBP, max 5 MB)

**Response 200**:
```json
{
  "success": true,
  "data": {
    "proofUrl": "https://res.cloudinary.com/...",
    "status": "PAYMENT_UPLOADED"
  },
  "message": "Payment proof uploaded successfully"
}
```

**Errors**: 400 (no image), 400 (wrong MIME type), 413 (file too large)

---

### PUT /orders/:id/cancel [Protected]
Cancel an order. Only allowed when status is `PENDING_PAYMENT`.

**Response 200**: Updated order with status `CANCELLED`.

**Errors**: 400 (order not in cancellable status)

---

## PAYMENT

### GET /payment/methods
Return JazzCash and EasyPaisa account details (sourced from backend env only).

**Response 200**:
```json
{
  "success": true,
  "data": {
    "methods": [
      {
        "method": "JAZZCASH",
        "accountNumber": "0325-2467463",
        "accountName": "XFast Group"
      },
      {
        "method": "EASYPAISA",
        "accountNumber": "0321-0846667",
        "accountName": "XFast Group"
      }
    ]
  }
}
```

---

## QUOTES

### POST /quotes/request
Submit a custom quote request. Sends notification email to XFast team. Public endpoint.

**Request**:
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "product": "string",
  "quantity": 100,
  "size": "string?",
  "material": "string?",
  "specialRequirements": "string?",
  "deliveryLocation": "string?",
  "deadline": "string?"
}
```

**Response 201**: Created quote object with `quoteId`.

---

### GET /quotes/my [Protected]
Get all quotes submitted by the authenticated user.

**Response 200**: `{ "quotes": [ { quoteId, product, status, adminResponse, estimatedPrice, createdAt } ] }`

---

## CONTACT

### POST /contact
Submit a contact message. Sends auto-reply to sender and notification to team.

**Request**:
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "service": "string?",
  "message": "string"
}
```

**Response 201**: `{ "message": "Message sent. We'll get back to you soon." }`

---

## ADMIN — Content Management

> All admin endpoints require `Authorization: Bearer <jwt>` with `Role.ADMIN`

### GET /admin/orders
List all orders (all customers). Supports filters.

**Query params**: `?status=PENDING_PAYMENT&page=1&limit=20&search=<orderId>`

**Response 200**: Paginated order list with customer name, status, total, date.

---

### GET /admin/orders/:id
Get full order detail including payment proof image URL and admin notes.

---

### PUT /admin/orders/:id
Update order status and/or admin notes.

**Request**: `{ "status": "CONFIRMED", "adminNotes": "string?" }`

---

### PUT /admin/orders/:id/verify-payment
Verify or reject a payment proof.

**Request**: `{ "action": "VERIFY" | "REJECT", "notes": "string?" }`

**Response 200**: Updated order with new payment status.

---

### GET /admin/products
List all products (including inactive ones).

---

### POST /admin/products
Create a new product.

**Request**: Full product fields (name, slug, description, category, startingPrice, etc.)

---

### PUT /admin/products/:id
Update a product.

---

### DELETE /admin/products/:id
Delete a product. Order history retains snapshot; cart items with this product are removed.

---

### POST /admin/products/:id/image [Multipart]
Upload or replace the product's primary image.

**Request**: `multipart/form-data` with `image` field (JPEG/PNG/WEBP, max 5 MB)

**Response 200**: `{ "imageUrl": "https://res.cloudinary.com/fastprinting/products/..." }`

---

### GET /admin/services
List all services (including inactive).

---

### POST /admin/services
Create a service.

---

### PUT /admin/services/:id
Update a service.

---

### POST /admin/services/:id/image [Multipart]
Upload or replace the service image.

**Response 200**: `{ "imageUrl": "https://res.cloudinary.com/fastprinting/services/..." }`

---

### GET /admin/categories
List all categories.

---

### POST /admin/categories
Create a category.

---

### PUT /admin/categories/:id
Update a category.

---

### DELETE /admin/categories/:id
Delete a category (only if no products reference it).

---

### POST /admin/categories/:id/image [Multipart]
Upload or replace the category image.

**Response 200**: `{ "imageUrl": "https://res.cloudinary.com/fastprinting/categories/..." }`

---

### GET /admin/industries
List all industries.

---

### POST /admin/industries
Create an industry.

---

### PUT /admin/industries/:id
Update an industry.

---

### POST /admin/industries/:id/image [Multipart]
Upload or replace the industry image.

**Response 200**: `{ "imageUrl": "https://res.cloudinary.com/fastprinting/industries/..." }`

---

### GET /admin/quotes
List all quotes (all users).

**Query params**: `?status=PENDING&page=1&limit=20`

---

### PUT /admin/quotes/:id
Update quote status, admin response, and estimated price.

**Request**: `{ "status": "REVIEWED", "adminResponse": "string?", "estimatedPrice": 1500 }`

---

### GET /admin/contacts
List all contact messages.

**Query params**: `?isRead=false&page=1&limit=20`

---

### PUT /admin/contacts/:id/read
Mark a contact message as read.

---

### GET /admin/users
List all users.

**Query params**: `?page=1&limit=20&search=<email>`

---

### PUT /admin/users/:id/role
Promote or demote a user's role.

**Request**: `{ "role": "ADMIN" | "CUSTOMER" }`

---

### GET /admin/dashboard
Get dashboard metrics.

**Response 200**:
```json
{
  "success": true,
  "data": {
    "orders": {
      "total": 120,
      "byStatus": {
        "PENDING_PAYMENT": 5,
        "PAYMENT_UPLOADED": 3,
        "CONFIRMED": 10,
        "IN_PRODUCTION": 8,
        "SHIPPED": 4,
        "DELIVERED": 88,
        "CANCELLED": 2
      }
    },
    "revenue": {
      "totalVerified": 450000
    },
    "recentOrders": [ ... ],
    "unreadContacts": 3,
    "pendingQuotes": 7
  }
}
```
