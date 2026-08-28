# EsnaftaVar KVKK Architecture

**State:** PRIVACY-BY-DESIGN FOUNDATION — NOT A FINAL COMPLIANCE OPINION

## Operating model

1. **Inventory first:** every field maps to subject, purpose, processing operation,
   legal-ground candidate, recipient, transfer, access, retention and deletion.
2. **Purpose separation:** essential operation, security, product analytics, ads,
   personalization and support are not bundled into one “service improvement” aim.
3. **Activity-layered notice:** present the required controller/purpose/recipient/
   method-ground/rights information when data is obtained, with a readable overview
   and reachable detail.
4. **Consent only where appropriate:** notice is always required; consent is separate,
   specific, informed and freely given where it is the chosen lawful ground. Refusal
   of optional analytics/ads must not block essential discovery.
5. **Minimum and default-off:** optional profiling, raw-query retention, continuous
   location, merchant visitor maps and third-party ad identifiers are off for pilot.
6. **Lifecycle enforcement:** collection, use, disclosure, access, correction,
   restriction, deletion/anonymization and backup/vendor effects are testable.
7. **Evidence and accountability:** policy version, actor, reason and proof are kept
   without storing the sensitive payload in general logs.

## Legal-ground decision record

Wave 24 does not assign final grounds. Before implementation, each processing row
must record one current-law ground and why it is necessary. “User accepted the terms,”
“legitimate interest” or “security” cannot be used as blanket labels. Special-category
data uses the current Article 6 conditions and additional safeguards.

## Rights architecture

The public route must support confirmation/access, purpose/recipient information,
correction, deletion/destruction, objection to adverse solely automated analysis and
other applicable Article 11 requests. It must:

- authenticate ownership without password, OTP or recovery-link disclosure;
- register request time, scope and systems;
- answer as soon as possible and no later than the statutory maximum;
- explain approved retention/restriction instead of falsely claiming total erasure;
- notify relevant recipients where required;
- reconcile Auth, DB, Storage, search, analytics, backups and processors;
- keep only a minimum request/completion audit.

## Retention and disposal

No global period is selected. Use data-class plus lifecycle schedules with current
legal review. When purpose and all lawful grounds end, data is deleted, destroyed or
truly anonymized using a documented method. A hidden row, soft delete or reversible
hash is not automatically disposal/anonymization. Legal holds are exact, approved,
time-reviewed and never a “keep all” switch.

## Security and breach

Controls are risk-proportionate: least privilege, strong operator authentication,
field allowlists/redaction, secure secrets, environment isolation, dependency/vendor
review, access/export audit, backup recovery, incident containment and data-flow
inventory. A suspected personal-data breach enters an immediate triage route; the
72-hour Board-notification interpretation is an outer operational gate, not a reason
to wait.

## International transfer

For every foreign recipient/access/storage/support route record country, data,
purpose, role, onward transfer, safeguards and data-subject consequences. Use only a
current Article 9 mechanism selected by privacy/legal review. Standard-contract form,
signatures and notification requirements are not modified by convenience.

## VERBİS and policies

Whether registration or an exception applies depends on current entity facts,
employee/financial thresholds, main activity and data categories. `VERBIS_STATUS`
therefore remains `PROFESSIONAL_REVIEW_REQUIRED`; no exemption is assumed. The same
review determines whether a formal processing inventory and retention/destruction
policy are required and in what form.

## Mandatory privacy gates

| Gate | Pilot requirement | Owner |
|---|---|---|
| Controller and contact identity | exact legal entity/contact approved | lawyer/privacy |
| Activity notice | matches released data flow | privacy specialist |
| Optional choices | refusal works without service coercion | product + privacy |
| Rights route | reachable, authenticated, tracked | operations + privacy |
| Processor/transfer map | contracts and current mechanisms reviewed | privacy specialist |
| Retention schedule | class-specific and implementable | lawyer/privacy + architecture |
| Breach playbook | roles, clock, evidence and communication | privacy/security |
| Store declarations | app/SDK reality reconciled | release + privacy |

`KVKK_LEGAL_GROUNDS_FINALIZED: NO`

