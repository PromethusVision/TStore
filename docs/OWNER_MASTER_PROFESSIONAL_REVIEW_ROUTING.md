# Owner Master Professional Review Routing

State: `ROUTING ONLY — NO PROFESSIONAL OR OWNER FINALIZATION`

## Decision lanes

### OWNER_CAN_DECIDE_NOW — 20

`OM-R01`, `OM-R02`, `OM-R03`, `OM-R04`, `OM-R06`, `OM-R07`, `OM-R09`,
`OM-R11`, `OM-R12`, `OM-R13`, `OM-R14`, `OM-R16`, `OM-R17`, `OM-R19`,
`OM-R20`, `OM-R21`, `OM-R22`, `OM-R23`, `OM-R24`, `OM-R31`

These are product scope/direction choices. Professional review may still validate
later copy or implementation, but it need not choose the product direction.

### OWNER_CAN_DECIDE_PROVISIONALLY — 6

- `OM-R05`: choose minimized customer access direction; KVKK validates purposes.
- `OM-R08`: choose governed intake; regulatory review gates sensitive domains.
- `OM-R10`: choose ordinary-only fail-closed scope; specialists gate expansion.
- `OM-R15`: choose question-led minimum metrics; KVKK validates exact data map.
- `OM-R25`: choose collection hypothesis; KVKK review precedes data collection.
- `OM-R26`: choose evidence identity hypothesis; KVKK review precedes publication.

### OWNER_SHOULD_WAIT_FOR_LAWYER / KVKK — 1

- `OM-R18`: owner should not approve final terms, privacy/deletion handling or
  platform-role wording without lawyer and KVKK input. The owner can state desired
  customer experience, but not finalize professional content.

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

Does not resolve: whether the pilot should test a no-charge participation offer.

### DOMAIN REGULATORY SPECIALIST

Roots: `OM-R08`, `OM-R10`.

Needs: expansion beyond ordinary merchant/product allowlist, regulated evidence,
domain-specific listing/advertising restrictions.

Does not resolve: ordinary-only fail-closed pilot scope.

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

`PROFESSIONAL_REVIEW_ROUTING: PASS`

