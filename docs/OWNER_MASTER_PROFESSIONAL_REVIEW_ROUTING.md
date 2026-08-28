# Owner Master Professional Review Routing

State: `22 OWNER ROOTS FINAL — PROFESSIONAL ROUTING PRESERVED`

## Applied owner decision with open professional review

Product Owner approval fixes product direction but does not replace professional
work. Open dependencies on final roots are: `OM-R05` (KVKK), `OM-R10`
(lawyer/regulatory), `OM-R12` and `OM-R14` (lawyer), `OM-R15` and `OM-R17`
(KVKK), `OM-R16` (accountant/tax and terms review where applicable), and
`OM-R18` (lawyer/KVKK).

## Decision lanes

### OWNER_CAN_DECIDE_NOW — 20 ORIGINAL / 2 OPEN

`OM-R01`, `OM-R02`, `OM-R03`, `OM-R04`, `OM-R06`, `OM-R07`, `OM-R09`,
`OM-R11`, `OM-R12`, `OM-R13`, `OM-R14`, `OM-R16`, `OM-R17`, `OM-R19`,
`OM-R20`, `OM-R21`, `OM-R22`, `OM-R23`, `OM-R24`, `OM-R31`

These are product scope/direction choices. Professional review may still validate
later copy or implementation, but it need not choose the product direction.

Eighteen roots in this lane are final. Only `OM-R06` and `OM-R07` remain open.

### OWNER_CAN_DECIDE_PROVISIONALLY — 6 ORIGINAL / 3 OPEN

- `OM-R05`: FINAL=A; KVKK still validates purposes, notice and retention.
- `OM-R08`: choose governed intake; regulatory review gates sensitive domains.
- `OM-R10`: FINAL=A; ordinary-only scope is selected and specialists gate expansion.
- `OM-R15`: FINAL=A; minimum metrics are selected and KVKK validates the exact data map.
- `OM-R25`: choose collection hypothesis; KVKK review precedes data collection.
- `OM-R26`: choose evidence identity hypothesis; KVKK review precedes publication.

### OWNER_SHOULD_WAIT_FOR_LAWYER / KVKK — 0 OWNER ANSWERS / 1 OPEN PROFESSIONAL GATE

- `OM-R18=A`: the desired minimum launch surface is Product Owner FINAL. Lawyer
  and KVKK must still approve the terms, privacy/deletion handling and factual
  platform-role wording before commercial launch.

### DEFERRED_POST_PILOT — 4

`OM-R27`, `OM-R28`, `OM-R29`, `OM-R30`

These remain visible in the master queue but should not consume the first pilot
review session unless the owner intentionally changes scope.

## Professional queues

### LAWYER

Roots: `OM-R10`, `OM-R12`, `OM-R14`, `OM-R18`, `OM-R27`, `OM-R28`,
`OM-R29`, `OM-R30`.

Needs: factual platform-role wording, customer/merchant terms, advertising and
electronic-message claims, moderation/appeal reasons, QR non-payment disclosure,
regulated-scope boundaries and public badge wording.

Does not resolve: business goal, cohort size, UI palette, app scope or whether a
deferred commercial feature is strategically desired.

### KVKK / PRIVACY SPECIALIST

Roots: `OM-R05`, `OM-R15`, `OM-R17`, `OM-R18`, `OM-R25`, `OM-R26`,
`OM-R27`, `OM-R28`, `OM-R29`.

Needs: purpose/minimization, location handling, analytics identity/retention,
research consent, structured-evaluation data, public projection, deletion and
vendor disclosures.

Does not resolve: the Product Owner's desired customer journey or pilot outcome.

### ACCOUNTANT / TAX ADVISER

Roots: `OM-R16`, `OM-R30`.

Needs: any paid merchant offer, discount/reward funding, value transfer,
liability, expiry and accounting/tax treatment before a financial promise.

Does not reopen: the owner-selected bounded no-charge pilot direction. It reviews
accounting/tax treatment and any later financial promise.

### DOMAIN REGULATORY SPECIALIST

Roots: `OM-R08`, `OM-R10`.

Needs: expansion beyond ordinary merchant/product allowlist, regulated evidence,
domain-specific listing/advertising restrictions.

Does not reopen: the owner-selected ordinary-only fail-closed pilot scope. It
gates any regulated or unknown-sector expansion.

### TECHNICAL ARCHITECT

Root: `OM-R28`.

Needs: representative-data calibration, Bayesian/confidence mechanics,
idempotent correction and explainable composite dependency evaluation.

Does not resolve: whether public badges are strategically desirable or when they
should launch.

## Fail-closed rule

Where professional advice is not yet available, the default is not a hidden owner
selection. Sensitive capability remains disabled or ordinary-only while the owner
queue continues on independent decisions.

`PROFESSIONAL_QUESTIONS_PRESENTED_AS_OWNER_CHOICES: 0`

`PROFESSIONAL_REQUIREMENTS_WAIVED_BY_OWNER_SELECTION: 0`

`PROFESSIONAL_REVIEW_ROUTING: PASS`
