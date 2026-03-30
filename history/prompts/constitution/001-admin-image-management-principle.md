---
id: "001"
title: Admin Image Management Principle
stage: constitution
date: 2026-03-27
surface: constitution
model: claude-sonnet-4-6
feature: admin-image-management
branch: main
user: XFast Group
command: /sp.constitution
labels: [constitution, admin, image-upload, cloudinary, flutter]
links:
  spec: N/A
  ticket: N/A
  adr: N/A
  pr: N/A
files:
  - .specify/memory/constitution.md
tests:
  - N/A
---

## Prompt

Update the existing constitution at .specify/memory/constitution.md to add a new
principle/article for Admin Image Management. The feature: admins upload images via
the admin panel (React dashboard) → stored in Cloudinary → served via backend API →
displayed in Flutter UI for products, services, categories, and industries.

Key rules encoded:
1. All image uploads go through backend (never direct Cloudinary upload from frontend)
2. Backend stores Cloudinary URLs in DB (imageUrl on Product, Service, Category, Industry)
3. Flutter displays images using cached_network_image with Cloudinary URLs
4. Image upload endpoints are admin-only (requireAdmin middleware)
5. Supported entities: Products, Services, Categories, Industries
6. Image format: base64 or multipart form-data → backend → Cloudinary → secure_url
7. Cloudinary folder structure: /products, /services, /categories, /industries
8. Admin panel uses reusable ImageUpload component (React) with preview before submit
9. Flutter uses CachedNetworkImage with placeholder/shimmer for all entity images
10. No images stored locally — always served from Cloudinary CDN

Version bump: 1.0.0 → 1.1.0 (MINOR). Last Amended: 2026-03-27.

## Response snapshot

Added Article VIII: Admin Image Management to the constitution. The article encodes:
- A mandatory upload pipeline: Admin Panel → Backend → Cloudinary SDK → DB → Flutter
- Backend rules: requireAdmin gate, SDK-only uploads, folder structure, secure_url storage
- Database rules: imageUrl String? column on Product, Service, Category, Industry
- Admin dashboard rules: reusable <ImageUpload /> component with preview + validation
- Flutter rules: CachedNetworkImage mandatory, null-safe, no local image storage
- Four new admin image endpoints documented under /api/v1/admin/:entity/:id/image
- multer added to backend technology stack table

Constitution bumped to v1.1.0. Sync Impact Report prepended as HTML comment.

## Outcome

- ✅ Impact: Constitution v1.1.0 ratified with Article VIII governing all image management
- 🧪 Tests: No tests — constitution update only
- 📁 Files: .specify/memory/constitution.md updated
- 🔁 Next prompts: /sp.specify admin-image-upload, /sp.plan admin-image-upload
- 🧠 Reflection: Article VIII is comprehensive and non-negotiable; covers all three surfaces

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Add image deletion endpoint to Article VIII if needed
