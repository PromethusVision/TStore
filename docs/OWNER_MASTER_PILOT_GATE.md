# Owner Master Pilot Gate

State: `16/16 COMMERCIAL ROOTS FINAL — 8/8 MERCHANT IMPLEMENTATION ROOTS FINAL`

## Two different decision families

### Commercial pilot scope

This answers who, where, why, under what promise and under what stop/expand rule
the Esenler pilot operates.

Blocking roots (16):

`OM-R01`, `OM-R02`, `OM-R03`, `OM-R04`, `OM-R05`, `OM-R09`, `OM-R10`,
`OM-R11`, `OM-R12`, `OM-R13`, `OM-R14`, `OM-R15`, `OM-R16`, `OM-R17`,
`OM-R18`, `OM-R31`

### Minimum Merchant App implementation

This answers the smallest merchant-side authority-bearing surface that can safely
support the chosen commercial pilot.

Blocking roots (8):

`OM-R04`, `OM-R09`, `OM-R10`, `OM-R11`, `OM-R12`, `OM-R13`, `OM-R14`,
`OM-R31`

`OM-R01` and `OM-R02` size the implementation but do not define merchant runtime
authority. `OM-R18` is a launch/professional gate, not a Merchant App module.

## Three operating models

| Model | Shape | Safety | Operator burden | Learning value | Owner state |
|---|---|---|---|---|---|
| A | Full Merchant App before pilot | Broad, but larger attack/test surface | lower later, high build cost now | delayed by feature breadth | NOT SELECTED |
| B | Minimum safe Merchant App slice | authority/listing/QR boundaries explicit | bounded | high; tests real merchant behavior | PRODUCT OWNER FINAL |
| C | Tiny verifier + operator-assisted bootstrap | safe only if QR/authority/history never manual | high and fragile | narrower; operator behavior may distort | NOT SELECTED |

## Capabilities that cannot be deferred if used

- Authenticated merchant membership and exact shop authority.
- Self-service price, availability and freshness truth for live listings.
- Exact-shop QR confirmation with replay/duplicate protection.
- Server-authoritative verified purchase history/evidence.
- Fail-closed regulated scope.
- Named support/escalation and Production release/pause authority.

## Capabilities safe to defer

- Advanced dashboard and deep analytics.
- Custom staff hierarchy and multi-branch automation.
- Ads and Reward management.
- Public reputation dashboard and composite/meta badges.
- Sophisticated self-service canonical catalog management.

## Operator-assisted boundary

May be assisted: initial shop/profile data capture, first candidate intake,
training, document routing and low-risk corrections with evidence.

Must not be arbitrary/manual: identity or shop-authority grants, QR verification,
replay overrides, verified purchase creation, secret handling, regulated-policy
approval, history deletion or Production release.

## Pilot gate state

- Commercial pilot roots answered: `16/16`
- Merchant implementation roots answered: `8/8`
- Customer UI owner decisions answered: `8/8`
- Physical/exact-artifact acceptance: `NOT EXECUTED`
- Professional release surface: `PRODUCT DIRECTION FINAL — LAWYER/KVKK REVIEW OPEN`
- Other professional dependencies: `OM-R05`, `OM-R10`, `OM-R12`, `OM-R14`–`OM-R18` remain open as routed
- Owner finalization: `PARTIAL — EXACTLY 24/31 ROOTS`
- Runtime/physical/Production implementation: `NOT AUTHORIZED / NOT EXECUTED`

`COMMERCIAL_PILOT_OWNER_DECISION_GATE: CLOSED`

`MERCHANT_PILOT_OWNER_DECISION_GATE: CLOSED`

`COMMERCIAL_LAUNCH_GATE: OPEN — PROFESSIONAL, RUNTIME, PHYSICAL AND PRODUCTION EVIDENCE`
