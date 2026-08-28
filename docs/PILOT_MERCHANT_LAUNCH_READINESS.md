# EsnaftaVar Esenler Pilot — Merchant Launch Readiness

**State:** `OPERATIONAL CHECKLIST — NOT EXECUTED`

## Per-shop gate

| Gate | PASS evidence | STOP evidence |
|---|---|---|
| Identity and exact-shop authority | Authenticated operator and approved shop binding | Ambiguous/shared account or wrong shop |
| Geographic scope | Shop lies in the selected cell and customer promise | Outside/uncertain area |
| Policy allowlist | Sector/products permitted and evidence complete | Unknown/restricted activity |
| Shop profile | Correct public name, location, hours/contact visibility | Materially false/missing facts |
| Catalog usefulness | Agreed minimum useful current listings | Logo-only, duplicate or misleading catalog |
| Listing truth | Price/availability/timestamp sampled and attested | Repeated stale/false claims |
| Merchant operation | Supported device and update path proven | Cannot maintain or authenticate |
| QR/verifier | Training and exact-artifact two-party acceptance, if active | Replay/wrong-shop/duplicate ambiguity |
| Support | Merchant knows channel, hours, incident path | No reachable path for critical issue |
| Exit/pause | Merchant understands pause and data correction process | Irreversible or misleading commitment |

## Portfolio gate

Individual PASS does not imply launch. The selected cell also needs domain density,
support capacity, catalog queue health, monitoring and release evidence. Shops with
`READY` state may remain held until portfolio readiness is achieved.

## Daily launch roster

Record shop ID, cell, ready-state timestamp, catalog count/freshness, verifier
status, supported release, open exceptions and operator owner. Do not place private
evidence in the public roster.

`MERCHANT_LAUNCH_READINESS_EXECUTED: NO`
