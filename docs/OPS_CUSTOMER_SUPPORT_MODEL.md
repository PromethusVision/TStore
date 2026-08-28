# Customer Support Model

**State:** PROPOSED FOR OWNER REVIEW

## Supported case families

| Family | Examples | Safe support boundary |
|---|---|---|
| AUTH | signup/confirmation/recovery/session confusion | Verify ownership through secure flow; never request password/OTP/link |
| LOCATION | permission, saved location, incorrect nearby context | Explain/settings guidance; no hidden precise-location access |
| CART | stale listing, replace-cart conflict, unavailable item | Diagnose current state; do not fabricate price/stock |
| REVIEW_ELIGIBILITY | verified-purchase requirement, duplicate review | Explain server decision; cannot grant eligibility manually |
| QR | creation, expiry, wrong shop, completion state | Correlate transaction safely; fraud/correction escalation |
| SHOP_DATA | incorrect hours/location/contact | Create evidence-backed correction/report |
| PRODUCT_DATA | wrong product/category/media/details | Route catalog/listing review; no support-owned canonical edit |
| ABUSE_REPORT | unsafe listing/review/merchant/contact | Protect reporter, triage severity, moderation/policy route |
| PRIVACY/ACCOUNT | access, correction, deletion/export request | Authenticate and route governed request; no arbitrary deletion |

## Flow

Intake → identity/risk check → case/category → minimized evidence → resolution guidance or specialized escalation → customer-safe reason → follow-up/appeal → close with audit.

## Boundaries

Support may view only assigned purpose-built summaries. It cannot alter verified purchase history, reviews/ratings, merchant reputation, product identity, policy, account role, or audit events. Refund/payment promises are outside current O2O scope. A system defect becomes an incident/engineering issue rather than repeated manual data repair.

Urgent account takeover, privacy exposure, QR abuse, unsafe product, or vulnerable-user concerns escalate immediately. Routine disagreement does not justify moderation.

`SUPPORT_MANUAL_TRUTH_OVERRIDE: NO`

`PASSWORD_REQUEST_ALLOWED: NO`
