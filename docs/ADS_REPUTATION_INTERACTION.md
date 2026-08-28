# Advertising and Merchant Reputation Interaction

**State:** PROPOSED GUARDRAIL — NO REPUTATION OR AD RUNTIME

## Separation

Merchant quality/reputation may inform safety and minimum experience standards, but
advertising spend cannot purchase reputation, review eligibility, verification or a
customer recommendation claim.

| Use | Proposed posture |
|---|---|
| Severe verified abuse/suspension | Hard advertising ineligibility |
| Repeated price/stock bait | Suppress/review targets; do not hide through spend |
| Valid listing/shop/policy evidence | Eligibility input |
| Review count/rating | Bounded quality signal, not hard monopoly |
| Verified badge | Separate server-authoritative fact; not automatic ad approval |
| Ad spend/history | Never improves organic reputation/badge |
| Ad reports/hides | Investigation/quality signal with anti-abuse controls |

## Ranking

Quality can set a minimum threshold and break ties among otherwise eligible ads.
It cannot make an irrelevant, distant, unavailable or policy-blocked listing serve.
Bid/spend cannot compensate for safety failure. Organic ranking/reputation remains
independent from campaign spend.

## Reporting

Merchant reporting should separate advertising metrics from organic reviews and
verified purchase reputation. “Quality-limited” explanations use safe reason
classes, not customer identity or exploitable thresholds.

## Lifecycle

Reputation corrections, appeal outcomes and review deletions trigger re-evaluation
with effective history; they do not rewrite earlier ad decisions. A temporary ad
block does not automatically delete the merchant/shop/product.

`PAY_TO_WIN_REPUTATION: PROHIBITED`

`QUALITY_CAN_OVERRIDE_POLICY: NO`

`REPUTATION_AD_ELIGIBILITY_COUPLING: BOUNDED`
