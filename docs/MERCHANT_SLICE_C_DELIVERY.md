# Slice C — Merchant evaluation center delivery

Date: 2026-10-15. Baseline: `cc2d4f7e09884ce39d14ffd565e89440f9d673c6`.
Task branch: `agent/merchant-reviews-slice-c`.
Authority: canonical §6.1. Main merge belongs only to Integration Agent.

## Outcome

**Local implementation and acceptance PASS.** Merchants can open a review
summary from the existing dashboard, filter reviews, see details, reply once
to an eligible review from their own shop, and report it with a reason.
Customers use their verified purchase to submit all three service criteria
and any selected product ratings. Existing purchase/review surfaces retain
their layout and gain the required form, history, edit-deadline and withdrawal
behavior. No additional notification system or reward/badge/ads behavior exists.

## Delivered surfaces and contracts

| Area | Result |
| --- | --- |
| Merchant dashboard | Three service means, equal-weight overall mean, distinct-customer sample size, awaiting-reply count and center entry |
| Merchant center | All/unanswered/replied/reported filters, paging, loading/empty/error/retry and account-change clearing |
| Merchant detail | Current purchase origin; a single reply per durable root; private reasoned report; moderation/withdrawal status |
| Customer purchase evaluation | Optional overall; initial submission requires friendliness, communication, cleanliness; selected product stars required, text optional; remaining products reuse service evaluation |
| Customer review/purchase history | Fixed server 24-hour editing, explicit newer-purchase reopening, withdrawal, current shop reply and separate actual three-criterion history |
| QR completion | Routes to existing verified purchase history for C; QR creation/claim does not grant a review right |
| Admin operations | Reasoned hide/restore/under-review/abuse flag/reply hiding and private paginated audit RPCs; no new admin application |
| Compatibility | Additive 0019, private legacy wrappers, default-OFF server/client capability, existing notification architecture unchanged |

The public `reviews` root and its user/product uniqueness remain authoritative.
The original 0009 verified-item FK and verified flag never change. C revisions
carry current provenance when a newer purchase reopens the same public root.
An old-shop reply is not displayed on a later other-shop origin, but still
consumes the root's single reply slot. Hidden/withdrawn/invalid reviews do not
contribute to public product scores. Genuine returns preserve experience;
fraud invalidation removes affected evidence and service scoring falls back to
the customer's previous valid evaluation at that shop.

Private audit text is encrypted with an erasable subject key. Authorized
account deletion removes the public projection and key; numeric/commerce facts
and unreadable audit chronology remain. This is a local technical implementation,
not a declaration that indirect identifiers or backups are legally anonymized.

## Verified evidence

| Check | Result and limit |
| --- | --- |
| Complete Flutter suite | **2,385 PASS, 6 skipped**; skips are existing opt-in live/remote tests, intentionally not enabled |
| Static analyzer | **No issues** with `flutter analyze --no-pub` |
| New visuals | 6 golden images at 320/390 widths, 1.3 text scale at 320; existing Customer golden baselines unchanged |
| Browser | Actual Flutter web rendering of application widgets with explicitly synthetic repository data at 390×844; center, detail, reply/empty validation, back navigation and Customer form checked; no console warning/error observed |
| Native PostgreSQL 17.11 | **17 groups PASS**, real pgcrypto and independent blocked connections; synthetic Auth tables do not stand in for managed Auth proof |
| Managed local Supabase | **28 groups PASS**, real Auth-issued sessions, PostgREST, Storage and PostgreSQL; includes the same 17 DB groups |
| Harness isolation | **5 PASS**, literal-loopback transport, no redirects, strict container/project scope and explicit host bindings |

Reports: [native](data/merchant_c_native_acceptance.json),
[managed](data/merchant_c_managed_acceptance.json).
Both record final 0019 SHA-256:
`65c749a7eb3712f1853fe2ab5c2c5e93a98b39486fa07d72d3a0ccf1536fe667`.
The managed report records service image IDs and loopback bindings as well.

Representative acceptance: quantity three gives one right; three distinct
products give three product rights plus one service evaluation; identical
concurrent submissions yield one result and unchanged deadline; deadline is
checked after lock contention; old RPCs cannot bypass adopted C bounds;
foreign shops/roles/direct table access are denied; latest valid service means
and caches stay consistent across customers; actual logout denies writes;
actual Auth account deletion erases decryptable text without losing purchases.

Reproduction: [acceptance README, C mode](../tool/merchant_acceptance/README.md#slice-c-mode).
The acceptance stack and native server were stopped after passing, with their
scratch data retained. No Docker volumes or unrelated processes were deleted.

## Integration and enablement

1. Integrate this task branch after the integrated A+B baseline. Review the
   shared areas below, run analyzer and relevant/full tests on the combined
   revision, and commit/push main only as Integration Agent.
2. Local verification uses the Development migration track 0001–0011,
   0016–0018 and new 0019. Production taxonomy migrations are a separate track;
   **do not run the repository's entire migration folder against Production**.
3. `REVIEWS_V2_ENABLED=true` registers the shared evaluation repository and
   Merchant dashboard entry in local builds. Server
   `review_protocol_config.enabled` independently defaults false. Both are
   needed for the new submission journey. Merchant's existing local host still
   rejects non-loopback backends. No credentials are included in this delivery.
4. Before any authorized remote cutover, resolve legacy import, privacy/retention
   and moderation operations; verify schema/Auth/pgcrypto fingerprints and both
   client versions. `_review_import_legacy_c(limit)` is privileged, bounded and
   OFF-only; it is not granted to clients or service_role. Proven rows preserve
   original timestamps; unproven provenance stays private, never fabricated.
5. The OFF flag is a forward-write stop, **not a destructive rollback**. Existing
   C roots retain deadlines, withdrawal/audit protections and C scoring. Never
   drop lifecycle/history tables or revert to unbounded legacy edits to disable C.

Shared/conflict-sensitive areas: canonical and slices documents, dependency
injection, Merchant service composition/local entrypoint/dashboard, Customer
purchase/review/QR adapters, review/purchase DTOs, SQL chain inventory and the
existing local acceptance harness. Historical migrations, pubspec/lockfile,
global theme and five-tab routing are unchanged. No new Flutter dependency.

## Remaining gates

- Main integration is pending Integration Agent action. Remote migration/app
  activation needs explicit Product Owner authority and the import/privacy review.
- Physical Customer ↔ Merchant two-device acceptance, camera/platform behavior,
  Firebase/APNs configuration and final product acceptance remain separate.
- Native mobile release builds and remote/live acceptance were not claimed by
  this task. Scope D–J is not started automatically.

Detailed implementation record: [worklog](MERCHANT_SLICE_C_WORKLOG.md).
