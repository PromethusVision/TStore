# Reputation Correction Boundary

**State:** PROPOSED — NO REPUTATION MUTATION

Reputation is a derived projection from owner-approved, server-authoritative inputs. It is not an operator-editable number.

## Allowed operational actions

- correct/supersede the underlying verified-purchase, review-content, merchant identity, or fraud decision through its governed workflow;
- mark a projection stale and request deterministic rebuild;
- hold display/update during an active integrity incident;
- explain input classes and freshness safely;
- audit/reconcile before and after derived values.

## Prohibited actions

- set merchant score up/down;
- add reviews, purchases, badges, or positive events;
- delete criticism due merchant pressure;
- reward ad/subscription spend with trust;
- punish an appeal or support complaint;
- import an opaque operator “trust score”;
- hide calculation changes by rewriting history.

## Correction flow

Case → resolve affected input/event and ruleset → impact preview → governed source correction → deterministic recompute → reconcile historical/current projection → merchant/customer communication if material → appeal/audit.

If an input cannot be confidently assigned after catalog split/merge or QR dispute, mark the dependent projection unresolved/held rather than guessing.

## Operator display

Show contributing event classes, ruleset version, freshness, holds, and safe reason—not customer identities, private text, fraud thresholds, or raw device/location data.

`DIRECT_REPUTATION_EDIT: PROHIBITED`

`REPUTATION_RULES_FINALIZED: NO`
