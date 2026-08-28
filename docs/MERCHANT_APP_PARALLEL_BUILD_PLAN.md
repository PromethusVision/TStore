# Merchant App Parallel Build Plan

Status: **PROPOSED — FUTURE MULTI-AGENT PLAN**
Wave: 17 / WP96

## Streams after root decisions

| Role | Primary ownership | Avoid shared-file collision |
|---|---|---|
| Agent 1 | Merchant app shell, auth/context, shop/onboarding, QR client | No backend schema ownership |
| Agent 2 | Merchant backend identity/shop/RLS/RPC and policy tests | No client global navigation changes |
| Agent 3 | Catalog/listing/candidate contracts and Merchant catalog UI | Coordinate shared DTO/package changes |
| Integration | Contract/version integration, Customer App regression, release gates | Sole origin/main integration |

Analytics/reviews/notifications start after identity/catalog/QR contracts stabilize and may form later isolated tasks.

## Shared-risk files/concepts

API contract package, environment bootstrap, auth/session, router, design tokens, database migrations and canonical catalog models require ownership reservation and sequential integration.

## Gates

- Each task branch has exact base, changed-file boundary, tests/analyzer/security scan and TASK_RESULT.
- No agent applies Production migration/config/write without explicit phase authorization.
- Integration resolves semantic conflicts; no force push/history rewrite.
