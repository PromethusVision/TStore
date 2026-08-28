# Compliance Stress Failure Registry

**State:** SYNTHETIC RISK DEDUP — NO RUNTIME OR LEGAL TEST EXECUTED

The 3,500 scenario rows define expected controls. The registry below consolidates the conditions
that would constitute a design or release failure. It intentionally mirrors CQ-01–CQ-32 so every
failure has a professional route.

| Failure | CQ | Severity | Failure condition | Root control |
|---|---|---|---|---|
| CF-01 | CQ-01 | P0 | Released role/capability has no reviewed statutory-position assumption | freeze role facts; counsel review |
| CF-02 | CQ-02 | P0 | Controller/processor/vendor role is unknown | purpose/vendor role register |
| CF-03 | CQ-03 | P0 | Data is collected without activity-specific notice/ground | point-of-collection notice gate |
| CF-04 | CQ-04 | P0 | Precise location is retained without necessity | transient exact location; coarse output |
| CF-05 | CQ-05 | P1 | Raw search/event data is retained “for future use” | essential aggregate allowlist |
| CF-06 | CQ-06 | P1 | Security logs contain secrets or unrestricted identifiers | redaction, access and class retention |
| CF-07 | CQ-07 | P1 | Private chat/evidence is generally visible to operators | participant/case-scoped access |
| CF-08 | CQ-08 | P0 | QR/review history is silently edited or overclaimed | immutable evidence + visible correction |
| CF-09 | CQ-09 | P0 | Account deletion is hard-delete theatre or indefinite retention | class-specific orchestrated disposition |
| CF-10 | CQ-10 | P0 | Rights request cannot be authenticated/fulfilled/audited | safe intake and timed case workflow |
| CF-11 | CQ-11 | P0 | Operator/staff can browse unrelated PII/evidence | least privilege + audit trail |
| CF-12 | CQ-12 | P0 | Price, availability or QR is presented as platform guarantee/receipt | merchant source/time + bounded explanation |
| CF-13 | CQ-13 | P0 | Pilot lacks reachable support or reviewed customer/merchant terms | release dependency gate |
| CF-14 | CQ-14 | P1 | Commercial message is sent as if transactional | message taxonomy, consent/refusal review |
| CF-15 | CQ-15 | P0 | Paid placement is not immediately and persistently recognizable | `Sponsorlu` + explanation |
| CF-16 | CQ-16 | P0 | Behavioral/sensitive/child profiling launches without review | contextual-only pilot; block profile paths |
| CF-17 | CQ-17 | P0 | Restricted product or unsupported claim is advertised | ad eligibility no looser than product policy |
| CF-18 | CQ-18 | P0 | Negative reviews are suppressed or merchant gets veto | sentiment-neutral method + appeal |
| CF-19 | CQ-19 | P1 | Ordinary merchant badge has no evidence baseline | identity/shop-existence check |
| CF-20 | CQ-20 | P0 | Regulated capability activates without current evidence | capability-scoped fail-closed review |
| CF-21 | CQ-21 | P0 | Suspension is unreasoned, overbroad or unappealable | proportionate effect + reason + appeal |
| CF-22 | CQ-22 | P0 | Alcohol/tobacco/nicotine enters pilot ad/reward flow | pilot exclusion and item-level block |
| CF-23 | CQ-23 | P0 | Medicine/device/supplement/infant/optics rule is inferred from taxonomy | domain review before capability |
| CF-24 | CQ-24 | P0 | Veterinary or plant-protection product is treated as ordinary pet/garden stock | item and merchant authorization review |
| CF-25 | CQ-25 | P1 | Chemical/PPE/automotive risk claims lack conformity evidence | product-type evidence profile |
| CF-26 | CQ-26 | P0 | Weapon or pyrotechnic inventory is enabled by broad category membership | exclude pilot; specialist/counsel gate |
| CF-27 | CQ-27 | P1 | Jewellery authorization/authenticity claim lacks evidence | scoped merchant/product proof |
| CF-28 | CQ-28 | P0 | Reward creates economic/cross-merchant value before payment review | economic reward off; legal perimeter gate |
| CF-29 | CQ-29 | P0 | Reward launches without funding, accounting and tax treatment | accountant/tax gate |
| CF-30 | CQ-30 | P1 | Ads or rewards buy review/reputation outcomes | evidence lanes remain independent |
| CF-31 | CQ-31 | P1 | Policy/catalog history loses applicable rules or lineage | version + predecessor/successor history |
| CF-32 | CQ-32 | P2 | One-person pilot has no compensating audit/access review | scoped role + immutable log + sampling |

## Counts and root-fix opportunities

- Unique failure classes: **32** — P0 **22**, P1 **9**, P2 **1**, P3 **0**.
- Strongest multi-class fixes: capability inventory; purpose/data registry; item/capability policy
  engine; evidence/version model; claim provenance; case/reason/appeal workflow; least-privilege
  operator access; exact-release declaration reconciliation.
- A scenario with `CONTROL_EXPECTATION_DEFINED` is a design coverage result, not proof that a
  runtime control, professional conclusion or Production gate passed.
