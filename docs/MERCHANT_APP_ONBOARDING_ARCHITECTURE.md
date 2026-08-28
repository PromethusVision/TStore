# Merchant App Onboarding Architecture

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP09

## Proposed flow

```text
AUTH
 -> MEMBERSHIP LOOKUP
 -> MERCHANT IDENTITY
 -> SHOP BASICS
 -> MERCHANT SECTOR
 -> PHYSICAL LOCATION
 -> POLICY/VERIFICATION GATE (when required)
 -> REVIEW & SUBMIT
 -> CATALOG BOOTSTRAP
 -> OPERATIONAL DASHBOARD
```

## Stage contracts

1. **Auth:** email/phone/provider choice is a separate Auth decision; no merchant role from signup metadata.
2. **Membership lookup:** returning staff is routed only to assigned shops; new applicant starts draft.
3. **Merchant identity:** minimum operator identity, consent and support contact; private by default.
4. **Shop basics:** customer-facing name and contact are previewed separately from private data.
5. **Sector:** search-first merchant taxonomy; wider tree remains proposed. Sector does not classify products or grant permission.
6. **Location:** map/GPS suggestion plus manual correction and validation confidence.
7. **Policy gate:** regulated/unknown cases remain unpublished until approved.
8. **Review:** exact public/private fields and requested status shown before submit.
9. **Catalog bootstrap:** search existing product first; custom candidate only when absent.

## Recovery and idempotency

- Draft saves use server-issued onboarding id/revision; repeated submit cannot create duplicate organization/shop.
- User can resume the last completed stage after session refresh.
- Policy rejection is actionable but cannot be bypassed by editing client state.
- “Other” sector creates unresolved classification request; it is not automatically public free text.

## Open decisions

- `ONB-01 P0`: Merchant verification evidence and reviewer ownership.
- `ONB-02 P0`: Which sector/policy states may publish immediately?
- `ONB-03 P1`: Staff self-join vs owner invitation only. Recommendation: signed, expiring owner invitation.
- `ONB-04 P1`: Location validation threshold for activation.

