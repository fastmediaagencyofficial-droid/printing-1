---
id: PHR-001
title: Fast Printing Constitution v1.0.0
stage: constitution
date: 2026-03-27
surface: all
model: claude-sonnet-4-6
feature: N/A
branch: main
user: Maheen
command: /sp.constitution
labels: [constitution, admin-dashboard, flutter, node, react]
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

User requested creation of the `/sp.constitution` file for the Fast Printing & Packaging
mobile app project, with full context of the Flutter frontend, Node.js backend, and the
addition of an admin dashboard as a new surface.

## Response snapshot

Wrote `.specify/memory/constitution.md` v1.0.0 with 7 core principles:

1. Free-First Infrastructure — all services must have genuine free tiers
2. No Firebase — Ever (NON-NEGOTIABLE) — permanently banned
3. Backend Owns All Auth & Secrets — no client-side token verification
4. Single Codebase, Three Surfaces — Flutter + Node.js API + React Admin
5. State Management Discipline — BLoC-only, no direct API calls from UI
6. API Contract Consistency — standardised response shape, role-gated admin routes
7. Admin Dashboard — React 18 + Vite + TypeScript, TanStack Query, Tailwind CSS

Technology stack tables for all three surfaces documented. Development workflow,
branch strategy, DB change policy, and code quality gates defined. Governance
section with semantic versioning amendment procedure added.

## Outcome

- ✅ Impact: Constitution v1.0.0 ratified; admin dashboard formally added as third surface
- 🧪 Tests: N/A — governance document
- 📁 Files: .specify/memory/constitution.md written (overwrite of template)
- 🔁 Next prompts: /sp.specify for admin dashboard feature, /sp.plan for implementation
- 🧠 Reflection: Admin dashboard chosen as React + Vite + TypeScript to align with
  existing Node/TS backend skills and free-tier Vercel deployment

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Run /sp.specify to define admin dashboard feature spec
