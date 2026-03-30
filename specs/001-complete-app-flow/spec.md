# Feature Specification: Fast Printing & Packaging — Complete App Flow

**Feature Branch**: `001-complete-app-flow`
**Created**: 2026-03-27
**Status**: Draft
**Input**: User description: "now specify the complete flow of the app"

---

## Overview

Fast Printing & Packaging is a mobile commerce and order management platform for XFast Group,
Pakistan's fastest custom printing and packaging company based in Lahore. The system serves
two distinct user types: **customers** who browse, order, and pay via a mobile app, and
**admins** who manage content, verify payments, and fulfil orders via a web dashboard.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Customer Signs In with Google (Priority: P1)

A new or returning customer opens the app for the first time (or after being signed out).
They tap "Sign in with Google", choose their Google account, and are immediately taken to
the home screen. No password is required.

**Why this priority**: Authentication is the gateway to all personalised features — cart,
wishlist, orders, and payment. Without it, the app cannot serve individual customers.

**Independent Test**: Open the app on a fresh install, tap Sign in with Google, complete
the Google account selection, and verify the home screen loads with the user's name shown.

**Acceptance Scenarios**:

1. **Given** a new customer has never used the app, **When** they tap "Sign in with Google"
   and select a Google account, **Then** their account is created and they land on the home
   screen within 5 seconds.
2. **Given** a returning customer with an existing account, **When** they sign in again,
   **Then** their previous profile, wishlist, and order history are still accessible.
3. **Given** a customer cancels the Google account selection, **When** they are returned to
   the sign-in screen, **Then** no account is created and no error is shown.
4. **Given** a customer's Google sign-in succeeds, **When** they close and reopen the app
   within 30 days, **Then** they remain signed in without needing to re-authenticate.

---

### User Story 2 — Customer Browses Products and Services (Priority: P1)

A signed-in customer explores the catalogue. They can browse products (e.g., business cards,
stickers, banners) filtered by category or searched by keyword. They can also browse the 16
printing and packaging services and view service details.

**Why this priority**: Product/service discovery is the core commercial activity. Customers
must find what they need before they can order.

**Independent Test**: Navigate to the Products screen, filter by a category, tap a product
card, and confirm the product detail screen shows name, image, description, price, and an
"Add to Cart" button.

**Acceptance Scenarios**:

1. **Given** a customer is on the home screen, **When** they open the Products section,
   **Then** a full product catalogue is displayed with images, names, and prices.
2. **Given** a customer selects a category filter, **When** the filter is applied,
   **Then** only products belonging to that category are displayed.
3. **Given** a customer types a keyword in the search bar, **When** the search runs,
   **Then** products matching the name or description appear within 2 seconds.
4. **Given** a customer taps a product, **When** the product detail screen opens,
   **Then** the full product image, description, specifications, and price are visible.
5. **Given** a customer opens the Services section, **When** they browse the list,
   **Then** all 16 services are displayed with icons, titles, and short descriptions.
6. **Given** a customer taps a service, **When** the service detail screen opens,
   **Then** the full service description and a "Request Quote" call-to-action are visible.

---

### User Story 3 — Customer Manages Cart and Places an Order (Priority: P1)

A customer adds products to their cart, adjusts quantities, and proceeds to checkout. They
review their order, confirm delivery details, and place the order. The system records the
order and sends a confirmation email to the customer.

**Why this priority**: Order placement is the primary revenue-generating action in the app.

**Independent Test**: Add two products to cart, update one quantity, remove the other,
then place the order and verify a confirmation email is received and the order appears in
order history.

**Acceptance Scenarios**:

1. **Given** a customer is viewing a product detail, **When** they tap "Add to Cart",
   **Then** the product is added to their cart and the cart item count updates.
2. **Given** a customer views their cart, **When** they change an item quantity,
   **Then** the cart total recalculates immediately.
3. **Given** a customer views their cart, **When** they remove an item,
   **Then** the item disappears and the total updates.
4. **Given** a customer reviews their cart, **When** they tap "Place Order",
   **Then** the order is created, the cart is cleared, and a confirmation email is sent
   to the customer's email address.
5. **Given** an order is placed, **When** the customer opens Order History,
   **Then** the new order appears with status "Pending" and a unique order ID.

---

### User Story 4 — Customer Submits Payment Proof (Priority: P1)

After placing an order, the customer pays via JazzCash or EasyPaisa using the account
numbers displayed in the app. They then upload a screenshot of the payment confirmation
to their order. The admin reviews and verifies the proof before fulfilling the order.

**Why this priority**: This is the payment flow for the business. Without payment proof
submission, the business cannot confirm and process orders.

**Independent Test**: Place an order, navigate to its detail screen, view the payment
account numbers, tap "Upload Payment Proof", select an image from the gallery, submit,
and verify the order status updates to "Payment Submitted".

**Acceptance Scenarios**:

1. **Given** a customer has a placed order, **When** they open the order detail,
   **Then** JazzCash and EasyPaisa account numbers with account holder name are displayed.
2. **Given** a customer taps "Upload Payment Proof", **When** they select an image from
   their gallery and confirm, **Then** the image is uploaded and the order shows
   "Payment Submitted" status.
3. **Given** a customer has already uploaded proof, **When** they view the order,
   **Then** the uploaded proof image is visible and a re-upload option is available.
4. **Given** an admin verifies the payment, **When** the admin marks it as verified,
   **Then** the order status updates to "Processing" in the customer's order history.
5. **Given** an admin rejects the proof, **When** the admin marks it as rejected,
   **Then** the order status shows "Payment Rejected" and the customer can re-upload.

---

### User Story 5 — Customer Manages Wishlist (Priority: P2)

A customer saves products they are interested in to a wishlist for later. They can move
items from the wishlist to the cart, or remove them from the wishlist.

**Why this priority**: Wishlist increases conversion rates by letting customers save
products during browsing sessions and return later to buy.

**Independent Test**: Add a product to the wishlist from the product detail screen, open
the wishlist, tap "Move to Cart", and verify the item appears in the cart and is removed
from the wishlist.

**Acceptance Scenarios**:

1. **Given** a customer is viewing a product, **When** they tap the wishlist icon,
   **Then** the product is added to their wishlist and the icon shows as filled.
2. **Given** a product is already in the wishlist, **When** the customer taps the
   wishlist icon again, **Then** the product is removed.
3. **Given** a customer opens their wishlist, **When** they tap "Move to Cart" on an item,
   **Then** the item is added to the cart and removed from the wishlist.
4. **Given** a customer has wishlist items, **When** they sign out and sign back in,
   **Then** their wishlist is preserved.

---

### User Story 6 — Customer Requests a Custom Quote (Priority: P2)

A customer has a custom printing or packaging need that is not covered by standard products.
They submit a quote request with details about their requirement. The team receives the
request by email and follows up with the customer.

**Why this priority**: Custom quotes drive higher-value business for the company and serve
clients with unique requirements.

**Independent Test**: Fill out the quote request form with project details and submit,
then verify the quote appears in "My Quotes" with status "Pending" and the team receives
an email notification.

**Acceptance Scenarios**:

1. **Given** a customer submits a quote request, **When** the form is completed and sent,
   **Then** the request is saved and a notification email is sent to the XFast team.
2. **Given** a quote is submitted, **When** the customer opens "My Quotes",
   **Then** the quote is listed with status "Pending" and submission date.
3. **Given** an admin responds to the quote with a price estimate, **When** the customer
   views their quote, **Then** the estimated price and admin response are visible.

---

### User Story 7 — Customer Contacts Support (Priority: P3)

A customer has a question, feedback, or complaint. They submit a contact message through
the app. They receive an automatic reply email confirming their message was received, and
the team receives a notification to follow up.

**Why this priority**: Support contact is a standard utility feature. Important for
customer trust but does not block core purchasing flows.

**Independent Test**: Submit a contact form message, verify an auto-reply email arrives
at the customer's address, and confirm the message is visible in the admin dashboard.

**Acceptance Scenarios**:

1. **Given** a customer submits a contact form, **When** the form is sent,
   **Then** an automatic reply email is sent to the customer's address within 1 minute.
2. **Given** a contact message is submitted, **When** an admin opens the contact inbox,
   **Then** the message is visible with the sender's name, email, and message content.

---

### User Story 8 — Admin Manages the Content Catalogue (Priority: P1)

An admin signs into the web dashboard and manages the product and service catalogue.
They can create, edit, and delete products, services, categories, and industries. They
can upload or replace images for any entity, and the updated images appear immediately
in the mobile app.

**Why this priority**: Without content management, the catalogue cannot be updated and
the business cannot add new offerings or correct existing ones.

**Independent Test**: Sign in as admin, navigate to Products, create a new product with
an uploaded image, open the mobile app, and verify the new product appears in the catalogue
with the correct image.

**Acceptance Scenarios**:

1. **Given** an admin is on the Products page, **When** they create a new product with
   a name, category, price, description, and image, **Then** the product immediately
   appears in the mobile app's product catalogue.
2. **Given** an admin edits an existing product's price, **When** the change is saved,
   **Then** the updated price appears in the mobile app within the next data refresh.
3. **Given** an admin uploads an image for a product, **When** the upload completes,
   **Then** the product image shows the new image in the mobile app.
4. **Given** an admin deletes a product, **When** the deletion is confirmed,
   **Then** the product no longer appears in the mobile app's catalogue.
5. **Given** an admin creates a new service with a slug, title, description and image,
   **When** the service is saved, **Then** it appears in the mobile app's services list.
6. **Given** an admin manages categories and industries (create/edit/delete with images),
   **When** changes are saved, **Then** they are reflected in the mobile app.

---

### User Story 9 — Admin Verifies Payments and Manages Orders (Priority: P1)

An admin reviews incoming orders, views payment proof images uploaded by customers, and
marks payment as verified or rejected. They update order status as the order progresses
through fulfilment and can add internal notes.

**Why this priority**: Order and payment management is the operational core of the
business. Without it, orders cannot be fulfilled.

**Independent Test**: As admin, open a pending order with payment proof, view the proof
image, mark it as verified, add an admin note, update status to "Processing", and
confirm the change is reflected in the customer's order history.

**Acceptance Scenarios**:

1. **Given** an admin opens the Orders page, **When** they view the list,
   **Then** all orders are shown with customer name, status, date, and total.
2. **Given** a customer has uploaded payment proof, **When** an admin opens the order,
   **Then** the proof image is visible and Verify / Reject buttons are shown.
3. **Given** an admin clicks Verify, **When** the action is confirmed,
   **Then** the order's payment status changes to "Verified" and the customer sees
   "Processing" status in the mobile app.
4. **Given** an admin adds an internal note to an order, **When** the note is saved,
   **Then** it appears on the order detail page (visible to admins only).
5. **Given** an admin updates order status (e.g., to "Shipped" or "Delivered"),
   **When** the change is saved, **Then** the customer's order history reflects the
   new status immediately.

---

### User Story 10 — Admin Manages Quotes and Contact Messages (Priority: P2)

An admin views submitted quote requests and contact messages. For quotes, they can set
a status, add a response, and provide an estimated price. For contact messages, they
can mark messages as read.

**Why this priority**: Keeps the admin inbox actionable and ensures customer enquiries
are tracked and responded to.

**Independent Test**: As admin, open a pending quote, set status to "Reviewed", enter
an estimated price and a response message, save, and verify the customer sees the updated
quote details in the mobile app.

**Acceptance Scenarios**:

1. **Given** an admin opens the Quotes page, **When** they view a quote,
   **Then** the customer's name, project details, and submission date are visible.
2. **Given** an admin sets a quote's estimated price and adds a response,
   **When** the update is saved, **Then** the customer can see the price and response
   in their "My Quotes" screen.
3. **Given** a contact message has been read, **When** the admin marks it as read,
   **Then** it moves to the "Read" filter and the unread count decreases.

---

### User Story 11 — Admin Views Dashboard Metrics (Priority: P3)

An admin opens the dashboard home screen and sees a summary of business activity:
total orders by status, recent orders, revenue summary, and recent contact/quote activity.

**Why this priority**: Metrics give the business owner a quick operational overview
but do not block any core workflow.

**Independent Test**: Sign in as admin and verify the dashboard shows order counts for
each status (Pending, Processing, Shipped, Delivered), total revenue, and a list of
the 5 most recent orders.

**Acceptance Scenarios**:

1. **Given** an admin signs in, **When** the dashboard loads,
   **Then** they see total order counts grouped by status.
2. **Given** orders exist in the system, **When** the admin views the revenue summary,
   **Then** the total value of all verified-payment orders is displayed.
3. **Given** new orders or messages arrived today, **When** the admin views recent
   activity, **Then** they appear in the activity feed in chronological order.

---

### Edge Cases

- Customer places an order but loses internet before confirmation — order must not be
  duplicated on retry; the app shows a clear "Order already placed" message.
- Customer uploads a non-image file as payment proof — the system rejects the file
  with a clear format error message before uploading.
- Admin deletes a product that exists in a customer's active cart — the cart item
  remains until the customer next views the cart, at which point a "no longer available"
  message is shown and the item is automatically removed.
- Admin deletes a product that appears in a placed order — the order record retains
  the product name and price as a snapshot; deletion does not alter historical orders.
- Customer's session expires mid-action — the app redirects to sign-in, preserving
  their last cart state upon re-authentication.
- Admin uploads an image larger than the storage limit — the system rejects the upload
  with a clear file-size error before any data is sent.
- Customer cancels their own order — cancellation is allowed only while status is
  "Pending". Once payment is verified, cancellation requires admin action.
- Two admins update the same order simultaneously — last-write-wins; no data corruption.

---

## Requirements *(mandatory)*

### Functional Requirements

**Authentication**
- **FR-001**: System MUST allow customers to sign in using their Google account with no
  password required.
- **FR-002**: System MUST keep customers signed in for 30 days without re-authentication.
- **FR-003**: System MUST allow admins to sign in using the same Google flow but restrict
  dashboard access to users with the Admin role only.
- **FR-004**: System MUST allow an existing admin to promote another user to Admin role.

**Product & Service Catalogue**
- **FR-005**: System MUST display all products with name, image, price, category,
  description, and specifications.
- **FR-006**: System MUST allow customers to filter products by category.
- **FR-007**: System MUST allow customers to search products by name or description.
- **FR-008**: System MUST display all 16 services with title, image, description, and slug.
- **FR-009**: System MUST display all industries and all categories.
- **FR-010**: Admins MUST be able to create, edit, and delete products, services,
  categories, and industries.
- **FR-011**: Admins MUST be able to upload or replace images for products, services,
  categories, and industries. Uploaded images MUST appear in the mobile app immediately.

**Cart**
- **FR-012**: System MUST allow signed-in customers to add products to their cart.
- **FR-013**: System MUST allow customers to update item quantities in their cart.
- **FR-014**: System MUST allow customers to remove individual items or clear the entire cart.
- **FR-015**: System MUST display the cart total, recalculated whenever quantities change.
- **FR-016**: Cart contents MUST persist across app sessions for the same signed-in user.

**Wishlist**
- **FR-017**: System MUST allow signed-in customers to add and remove products from a
  personal wishlist.
- **FR-018**: System MUST allow customers to move a wishlist item directly to the cart.
- **FR-019**: Wishlist MUST persist across app sessions for the same signed-in user.

**Orders**
- **FR-020**: System MUST allow a customer to place an order from their cart, which clears
  the cart and sends a confirmation email to the customer.
- **FR-021**: Every order MUST be assigned a unique order ID and a default status of "Pending".
- **FR-022**: System MUST allow customers to view their full order history with status,
  date, items, and total.
- **FR-023**: System MUST allow customers to cancel an order while it has "Pending" status.
- **FR-024**: Admins MUST be able to view all orders, update order status, and add
  internal notes visible only to admins.

**Payment**
- **FR-025**: System MUST display JazzCash and EasyPaisa account numbers and the account
  holder name on the order detail screen for customers.
- **FR-026**: System MUST allow customers to upload a payment proof screenshot against
  a specific order.
- **FR-027**: Admins MUST be able to view the payment proof image and mark it as
  Verified or Rejected.
- **FR-028**: Payment account numbers MUST be sourced from the backend only and never
  hardcoded in the app.

**Quotes**
- **FR-029**: System MUST allow any visitor (signed-in or not) to submit a quote request.
  Signed-in customers' quotes are linked to their account.
- **FR-030**: System MUST send a quote request notification email to the XFast team.
- **FR-031**: Signed-in customers MUST be able to view their submitted quotes and any
  admin response or estimated price.
- **FR-032**: Admins MUST be able to view all quotes, set a status, add a response, and
  set an estimated price.

**Contact**
- **FR-033**: System MUST allow any user to submit a contact message with name, email,
  and message body.
- **FR-034**: System MUST send an automatic reply email to the sender upon submission.
- **FR-035**: System MUST send the contact message content to the XFast team email.
- **FR-036**: Admins MUST be able to view all contact messages and mark them as read.

**Admin Dashboard**
- **FR-037**: Admin dashboard MUST display a metrics overview: order counts by status,
  revenue summary, and a recent-activity feed.
- **FR-038**: Admins MUST be able to view and manage all users and promote users to
  Admin role.

---

### Key Entities

- **User**: A person who has signed in. Has a role (Customer or Admin), name, email,
  profile photo URL, and phone number. Links to cart, wishlist, orders, and quotes.

- **Product**: A purchasable item. Has name, description, price, category, image, specs,
  featured flag, and availability status. Belongs to a Category.

- **Category**: A grouping for products (e.g., Business Cards, Banners). Has name,
  image, and description.

- **Service**: A printing/packaging service offered by XFast. Has title, slug,
  description, image, and display order. There are 16 services.

- **Industry**: A vertical market served by XFast (e.g., Retail, F&B). Has name,
  description, and image. There are 4 industries.

- **Cart**: A customer's current shopping basket. Contains cart items (product +
  quantity). One cart per customer.

- **CartItem**: A single line in a cart. References a product and a quantity.

- **Wishlist**: A saved list of products for a customer. One wishlist per customer.

- **Order**: A confirmed purchase. Has a unique ID, status, list of ordered items
  (snapshot of product names and prices), total, delivery details, timestamps, and
  admin notes. Linked to one customer.

- **OrderItem**: A line item within an order. Captures product name, quantity, and
  unit price at time of order (immutable snapshot).

- **PaymentProof**: An image uploaded by the customer to confirm payment. Linked to an
  order. Has a URL, upload timestamp, and verification status (Pending / Verified /
  Rejected).

- **Quote**: A custom project enquiry. Has project description, contact details,
  status (Pending / Reviewed / Responded / Closed), admin response, and estimated price.
  Optionally linked to a signed-in user.

- **ContactMessage**: A general enquiry from a visitor. Has name, email, message, and
  read status.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new customer can sign in with Google and reach the home screen in under
  10 seconds on a standard mobile connection.
- **SC-002**: A customer can find a product by category or search and view its detail
  in under 30 seconds from opening the app.
- **SC-003**: A customer can add products to cart, review the cart, and place an order
  in under 3 minutes from first product view.
- **SC-004**: A customer can upload a payment proof screenshot within 2 minutes of
  placing an order.
- **SC-005**: An admin can verify or reject a payment and update an order status in
  under 1 minute from opening the order detail.
- **SC-006**: An admin can upload a new product image and have it visible in the mobile
  app within 30 seconds of the upload completing.
- **SC-007**: 100% of placed orders trigger a confirmation email to the customer
  within 1 minute.
- **SC-008**: 100% of contact form submissions trigger an automatic reply email to
  the sender within 1 minute.
- **SC-009**: The mobile app remains usable (browsing and order history) on a 3G
  connection with page loads under 5 seconds.
- **SC-010**: The system supports at least 500 concurrent users without order
  processing errors.

---

## Assumptions

- All customer authentication is via Google accounts. Email/password login is out of scope.
- The app targets Android initially; iOS is out of scope for the first release.
- Delivery is coordinated offline (WhatsApp/phone); no in-app delivery tracking is required.
- Currency is Pakistani Rupees (PKR); no multi-currency support is needed.
- Payment is exclusively via JazzCash and EasyPaisa manual bank transfers; no integrated
  payment gateway is in scope.
- Product specifications (e.g., paper weight, size options) are stored as structured text
  per product; a full product configurator is out of scope.
- The admin dashboard is a web-only interface; no mobile admin app is required.
- Email notifications are one-way; no two-way email threading is required.
- All infrastructure services are free-tier (Cloudinary, Neon/Supabase, Railway/Render,
  Vercel/Netlify) per the project constitution.
