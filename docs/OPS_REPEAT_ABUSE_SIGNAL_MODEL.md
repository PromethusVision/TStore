# Repeat Abuse Signal Model

**State:** PROPOSED — NO OPAQUE PUNITIVE SCORE

## Purpose

Identify recurrent substantiated patterns while preserving context, policy version, recency, and false-positive safeguards.

## Signals

Prior substantiated cases, repeated exact violation, cross-shop/account linkage supported by evidence, recurrence after warning/correction, QR/ad/reward invalid activity, repeated prohibited listings, staff-role misuse, retaliation/mass reporting, and account/security compromise. Allegations, rejected cases, raw report counts, merchant size, low rating, or social pressure are not convictions.

## Model

Use an explainable event registry:

- subject and event/case IDs;
- violation class and scope;
- decision confidence/status;
- policy version/effective time;
- recency and remediation;
- appeal/reversal state;
- linkage evidence;
- expiry/decay where owner-approved.

## Decisions

Signals may raise review priority, require stronger evidence, narrow capability, or escalate an enforcement-ladder review. They do not automatically set reputation, permanently ban, or propagate punishment across related accounts.

## False positives

Overturned/reversed cases stop contributing prospectively and remain visible for QA. Account takeover and shared-device/shop contexts require separation. Operator sees contributing events, not a single secret score.

`OPAQUE_ABUSE_SCORE: PROHIBITED`

`REPEAT_OFFENDER_POLICY_FINAL: NO`
