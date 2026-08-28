# Operations Owner Root Decisions

State: PROPOSED FOR PRODUCT OWNER REVIEW — NO SELECTIONS

Recommendations below are architectural guidance. They are not Product Owner decisions and do not authorize runtime, Production, database, policy or legal changes.

## RD-01 — Operator authority baseline

**QUESTION:** Which authority model should the operations pilot use?

**OPTIONS:** (A) shared super-admin access; (B) UI-only roles; (C) individual operator identities, six lean role families, server capabilities and typed case-bound commands.

**RECOMMENDED:** C.

**WHY:** It is the smallest option that enforces least privilege, tenant scope, attribution and removal of routine manual database edits.

**TRADEOFF:** More initial authorization and command design than a shared dashboard; materially lower privilege and audit risk.

**SYSTEMS:** Auth, operator identity, permissions, case commands, Supabase-facing server layer.

**PRIORITY:** P0.

## RD-02 — High-risk and emergency action control

**QUESTION:** How should irreversible/high-blast-radius and emergency actions be controlled?

**OPTIONS:** (A) any privileged operator; (B) confirmation only; (C) enumerated actions with reason, evidence, fresh re-auth, exact-target preview, append-only audit, scoped break glass and selective two-person review.

**RECOMMENDED:** C, with dual review limited to permanent suspension, verified-history correction, destructive catalog merge/split, broad kill switches and exceptional bulk actions.

**WHY:** It concentrates friction where mistakes are hardest to reverse.

**TRADEOFF:** Slower exceptional actions and an on-call approval need; routine support remains lean.

**SYSTEMS:** Enforcement, QR, catalog, incidents, bulk actions, audit.

**PRIORITY:** P0.

## RD-03 — Merchant verification and enforcement

**QUESTION:** What merchant verification/recheck and enforcement contract should govern shops?

**OPTIONS:** (A) one permanent verified flag; (B) fixed universal expiry and shop-only suspension; (C) risk-tiered/event-triggered recheck plus a versioned enforcement ladder and dependency plan.

**RECOMMENDED:** C; exact recheck periods and regulated-sector evidence remain policy decisions.

**WHY:** Shop status affects listings, staff, QR and future ads, while regulated evidence may expire.

**TRADEOFF:** More lifecycle states and restoration testing than a boolean flag.

**SYSTEMS:** Merchant onboarding, shops, listings, QR, reviews, ads, staff roles.

**PRIORITY:** P0.

## RD-04 — Verified history and canonical identity

**QUESTION:** How may operators correct verified transactions and canonical product identity?

**OPTIONS:** (A) direct edit/delete; (B) never correct; (C) append superseding events and stable predecessor/successor relationships with independent review for destructive ambiguity.

**RECOMMENDED:** C.

**WHY:** It permits legitimate repair without losing reviews, listings, analytics, aliases or transaction evidence.

**TRADEOFF:** Consumers must resolve an effective state from history rather than reading a silently rewritten row.

**SYSTEMS:** QR, verified purchases, reviews, reputation, catalog, taxonomy, search, analytics.

**PRIORITY:** P0.

## RD-05 — Regulated policy ownership

**QUESTION:** Who decides whether regulated merchants/products may operate?

**OPTIONS:** (A) general moderators; (B) category placement automatically permits sale; (C) named policy authority using versioned evidence rules, with legal review for flagged classes.

**RECOMMENDED:** C and fail closed while authority/evidence is unresolved.

**WHY:** Merchant sector and product taxonomy describe classification, not legal/platform permission.

**TRADEOFF:** Slower onboarding/listing for sensitive classes; lower uncontrolled compliance exposure.

**SYSTEMS:** Merchant verification, policy review, catalog, listings, ads.

**PRIORITY:** P0; legal/policy review required.

## RD-06 — Appeal independence and quality review

**QUESTION:** Which decisions need independent appeal and quality review?

**OPTIONS:** (A) original operator reviews every appeal; (B) every case needs two reviewers; (C) independent review for P0, permanent and conflicted cases, plus risk-weighted quality sampling.

**RECOMMENDED:** C.

**WHY:** It reduces confirmation bias without making all pilot work two-person.

**TRADEOFF:** Requires limited cross-coverage and a remand path when original evidence is incomplete.

**SYSTEMS:** Appeals, enforcement, catalog, QR correction, decision quality.

**PRIORITY:** P0.

## RD-07 — Case and evidence foundation

**QUESTION:** What shared operational record should all review queues use?

**OPTIONS:** (A) free-text tickets; (B) separate incompatible domain records; (C) one lean case lifecycle with typed subjects, evidence/provenance, decisions, links, history and structured internal notes.

**RECOMMENDED:** C while keeping enforcement and entity lifecycles separate from case status.

**WHY:** It gives support, moderation, verification and incidents one traceable spine without a giant admin suite.

**TRADEOFF:** Requires shared identifiers and reason/evidence schemas before UI work.

**SYSTEMS:** All operations queues, audit, search, analytics.

**PRIORITY:** P1.

## RD-08 — Support identity and data requests

**QUESTION:** How should support prove customer/merchant authority and handle data requests?

**OPTIONS:** (A) knowledge questions or password/OTP sharing; (B) caller assertion; (C) session-bound proof/canonical recovery, active merchant membership and risk-based step-up for sensitive data actions.

**RECOMMENDED:** C; passwords, OTPs, recovery links and tokens are never requested.

**WHY:** It resists social engineering and preserves tenant/data-subject boundaries.

**TRADEOFF:** Some callers must complete recovery before support can disclose or change anything.

**SYSTEMS:** Customer support, merchant support, Auth, privacy requests.

**PRIORITY:** P1; data-request details need policy review.

## RD-09 — Ads and future reward abuse

**QUESTION:** When may automated signals change ad metrics, enforcement, rewards or reputation?

**OPTIONS:** (A) opaque risk score automatically changes outcomes; (B) operator directly adjusts totals; (C) deterministic event deduplication where safe, otherwise evidence case and source-event adjudication.

**RECOMMENDED:** C; keep ads/rewards disabled until their product decisions and runtime controls are approved.

**WHY:** Detection confidence and punitive action are different decisions, and derived values must remain reproducible.

**TRADEOFF:** More unknown/held states and manual review for ambiguous abuse.

**SYSTEMS:** Ads, invalid traffic, rewards, QR, reviews, reputation.

**PRIORITY:** P1.

## RD-10 — Decision reasons and policy transitions

**QUESTION:** How should decisions explain policy and respond to policy changes?

**OPTIONS:** (A) unstructured free text and immediate retroactivity; (B) grandfather everything; (C) paired public/internal reason codes pinned to effective policy versions with an explicit transition impact decision.

**RECOMMENDED:** C.

**WHY:** It enables consistency and appeals without leaking anti-abuse methods or silently changing past rationale.

**TRADEOFF:** Requires reason-code governance and impact review for each material policy release.

**SYSTEMS:** Policy, moderation, verification, listings, ads, communications, audit.

**PRIORITY:** P1.

## RD-11 — Privacy incidents and retention

**QUESTION:** What retention and incident-notification model should operational data use?

**OPTIONS:** (A) retain everything indefinitely and notify ad hoc; (B) one universal period; (C) purpose/object/risk-specific retention, legal holds, controlled disposal and documented notification-duty assessment.

**RECOMMENDED:** C, with exact periods and legal thresholds set through policy/legal review.

**WHY:** Evidence and audit need accountability while personal data must be minimized.

**TRADEOFF:** Requires retention metadata, restricted historical access and periodic disposal controls.

**SYSTEMS:** Cases, evidence, audit, logs, exports, privacy/security incidents.

**PRIORITY:** P0; legal/policy review required.

## RD-12 — Pilot operating model

**QUESTION:** What lean staffing, tooling and response-target model should launch first?

**OPTIONS:** (A) Product Owner using direct Supabase/manual edits; (B) buy a full enterprise suite; (C) named lean operators using a lightweight case-bound console, optional ticket intake integration and internal risk-based targets.

**RECOMMENDED:** C after measuring expected queue volume; staffing can begin owner-operated but must retain individual attribution and compensating review.

**WHY:** It avoids both arbitrary Production operations and premature enterprise cost.

**TRADEOFF:** A small internal workflow must be built and some channel conveniences may wait.

**SYSTEMS:** Support tooling, admin console, queues, staffing, response targets.

**PRIORITY:** P1.

## RD-13 — Intake and report taxonomy

**QUESTION:** Which pilot channels and report types should create cases?

**OPTIONS:** (A) all channels with free text; (B) email only; (C) one traceable in-app/web intake plus email fallback and small structured customer/merchant report taxonomies.

**RECOMMENDED:** C; WhatsApp or paid tooling remains an evidence-based later choice.

**WHY:** Structured intake improves routing and identity while preserving context.

**TRADEOFF:** Fewer launch channels and initial form design work.

**SYSTEMS:** Customer support, merchant support, report routing, duplicate detection.

**PRIORITY:** P2.

## RD-14 — Analytics and admin discovery

**QUESTION:** What should operators search and what should dashboards measure?

**OPTIONS:** (A) broad PII search and productivity rankings; (B) volume-only dashboard; (C) purpose-scoped exact entity search plus queue age, severity, reopen, reversal, false-positive and system-health metrics.

**RECOMMENDED:** C with no operator league tables.

**WHY:** It supports decisions and workload planning without vanity metrics, surveillance or excess PII.

**TRADEOFF:** Less convenient exploratory search and more deliberate authorization filters.

**SYSTEMS:** Admin search, dashboards, analytics, privacy, quality.

**PRIORITY:** P2.

## Summary

| Priority | Root decisions |
|---|---:|
| P0 | 7 |
| P1 | 5 |
| P2 | 2 |
| **Total** | **14** |

The Product Owner must record selections separately. Until then, policy-sensitive uncertainty stays fail-closed, deferred capabilities stay disabled and no runtime action is authorized.
