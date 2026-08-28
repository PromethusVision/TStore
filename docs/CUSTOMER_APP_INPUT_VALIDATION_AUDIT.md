# Customer App Input Validation Audit

Status: PASS FOR ACTIVE V1 FORMS

## Active inputs

- Auth: trims email, validates email shape, password rules/confirmation, full name, legal consent, and duplicate submit.
- Recovery: validates identity-bound callback and new-password confirmation before canonical update/fresh-login proof.
- Profile: trims/validates editable identity/phone fields and disables repeated save.
- Saved locations: trims name/address text, requires valid captured coordinates, and locks save/default/delete while busy.
- Search: trims query, suppresses empty/too-short suggestion requests, debounces typing, cancels stale work, and caps results.
- Reviews: rating range and text requirements/limits are enforced before canonical RPC; duplicate submit is blocked.
- Chat: trimmed non-empty content, 1,000-character maximum, editable draft on failure, and send lock.
- Cart quantity: integer server model and minimum one in customer control; unavailable items cannot generate QR.

The unreachable postal-address prototype is not counted as an active commercial form. Unicode/Turkish text is supported by Dart strings/database payloads; future taxonomy synonym folding requires a dedicated search contract.

Server validation, database constraints, and RLS remain mandatory; client validation is usability, not authorization.

`INPUT_VALIDATION_AUDIT: PASS`
`DUPLICATE_SUBMIT_CRITICAL_GAP: NO`
