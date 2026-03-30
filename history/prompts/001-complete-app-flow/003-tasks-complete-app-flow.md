---
id: "003"
title: Tasks Complete App All Surfaces
stage: tasks
date: 2026-03-27
surface: tasks
model: claude-sonnet-4-6
feature: 001-complete-app-flow
branch: 001-complete-app-flow
user: XFast Group
command: /sp.tasks
labels: [tasks, backend, flutter, admin, all-surfaces, 127-tasks, 11-stories]
links:
  spec: specs/001-complete-app-flow/spec.md
  ticket: N/A
  adr: N/A
  pr: N/A
files:
  - specs/001-complete-app-flow/tasks.md
tests:
  - N/A
---

## Prompt

(empty — ran /sp.tasks on current branch 001-complete-app-flow)

## Response snapshot

Generated `tasks.md` with 127 tasks across 14 phases covering all 11 user stories on
3 surfaces (Backend, Flutter, React Admin).

**Phase summary**:
- Phase 1 (Setup): T001–T005 — scaffold all 3 surfaces
- Phase 2 (Foundational): T006–T026 — backend foundation, Flutter DI/network, admin scaffold
- Phase 3 (US1 Auth P1): T027–T036 — Google Sign-In on Flutter + Admin; JWT flow
- Phase 4 (US2 Catalogue P1): T037–T054 — products, services, industries, categories
- Phase 5 (US3 Cart+Orders P1): T055–T068 — cart CRUD + order placement + email
- Phase 6 (US4 Payment P1): T069–T075 — payment methods + proof upload to Cloudinary
- Phase 7 (US5 Wishlist P2): T076–T080 — wishlist add/remove/move-to-cart
- Phase 8 (US6 Quotes P2): T081–T086 — quote request + my quotes
- Phase 9 (US7 Contact P3): T087–T090 — contact form + email auto-reply
- Phase 10 (US8 Admin Content P1): T091–T103 — admin CRUD + ImageUpload component
- Phase 11 (US9 Admin Orders P1): T104–T108 — order list + payment verification
- Phase 12 (US10 Admin Quotes P2): T109–T112 — quote + contact inbox management
- Phase 13 (US11 Dashboard P3): T113–T116 — metrics + user management
- Phase 14 (Polish): T117–T127 — shimmer, JWT refresh, logging, release builds

**MVP scope**: US1 + US2 + US3 (T001–T068) — sign in, browse, cart, place order.

## Outcome

- ✅ Impact: 127 actionable tasks; each with file path; ready for /sp.implement
- 🧪 Tests: Not requested — no test tasks generated
- 📁 Files: specs/001-complete-app-flow/tasks.md
- 🔁 Next prompts: /sp.implement
- 🧠 Reflection: Large task list — recommend implementing MVP tiers first; Admin and Flutter Tier 5+ can be parallelised

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): All checklist format rules followed (checkbox + ID + story + path)
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Split into domain-specific task files if parallel teams needed
