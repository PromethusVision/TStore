# Merchant App Test Strategy

Status: **PROPOSED — IMPLEMENTATION PLAN**
Wave: 17 / WP81

## Pyramid

| Layer | Focus |
|---|---|
| Unit/domain | State transitions, validation, units, error mapping, metric semantics |
| Cubit/controller | Loading/empty/error/conflict/idempotent interaction and shop switch |
| Repository/contract | DTO compatibility, auth scope, retry/reconcile and privacy projection |
| Widget | Forms, permissions, accessibility, deep links, double-submit |
| Backend integration | RLS/RPC, concurrency, cascade/audit, policy fail-closed |
| App integration | Onboarding, listing, QR, reviews, notifications, switch/re-auth |
| Physical | Camera, two-device QR, permissions, weak network, background/restart |

## Mandatory environments

Controlled local/test for destructive/adversarial suites; Development for authorized live integration; Production only explicit release acceptance with isolated fixtures and owner authorization. No tests silently fallback environments.

## Gates

Contract tests for both Customer and Merchant clients, analyzer/lint, secret scan, release build, schema/migration verification when applicable, physical Android/iOS scope, and exact cleanup evidence for live fixtures.
