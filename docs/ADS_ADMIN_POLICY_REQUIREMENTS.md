# Advertising Admin and Policy Review Requirements

**State:** REQUIREMENTS ONLY — NO ADMIN PANEL OR PRIVILEGE CHANGE

## Review queues

- merchant/shop advertising eligibility and evidence;
- product/listing/claim/creative policy;
- campaign revision and geo/context target;
- customer reports and misleading price/stock;
- invalid traffic, billing hold/credit and merchant disputes;
- account/campaign takeover or severe abuse;
- policy change, recall and emergency suppression;
- appeal/correction and reinstatement.

## Human/system responsibility

| Decision | Automation candidate | Human/policy gate |
|---|---|---|
| Deterministic inactive/deleted/out-of-stock block | Yes | Override only via source correction |
| Budget/schedule/frequency check | Yes | Commercial dispute policy |
| Exact known prohibited item | Yes after approved rules | Policy owner maintains rule |
| Ambiguous regulated claim/product | No final auto-approval | Qualified review/legal matrix |
| Severe fraud/suspension | Detection/temporary containment | Evidence review and appeal |
| Customer report | Triage/dedup | Material enforcement review |
| New policy/recall | Automated suppression | Accountable policy owner |

## Required capabilities

- least-privilege roles separating policy, fraud, finance/credit and support;
- immutable reason-coded audit trail and evidence references;
- search by stable IDs/revisions, not only mutable names;
- bulk emergency stop with exact scope/preview and rollback authority;
- no client/merchant direct approval;
- dual control for high-impact policy/financial actions where appropriate;
- evidence privacy/redaction and retention;
- appeal/correction state without deleting history;
- metrics for backlog/SLA/consistency, not reviewer productivity alone.

## Explicit non-requirements

This document does not design screens, create admin roles, approve any product,
define legal conclusions or authorize Production/Development changes.

`ADS_ADMIN_REQUIREMENTS: READY_FOR_OWNER_REVIEW`

`MERCHANT_SELF_APPROVAL: NO`

`ADMIN_PANEL_IMPLEMENTED: NO`
