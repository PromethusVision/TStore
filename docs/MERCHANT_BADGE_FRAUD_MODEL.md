# Merchant Badge Fraud and Abuse Model

**State:** THREAT/CONTROL FOUNDATION — NO DETECTION IMPLEMENTATION

## Threats

- QR collusion, fake confirmation, replay attempts and staff confirming non-purchases;
- merchant employees or household members using customer accounts;
- multi-account/customer farms, coordinated extreme scores and purchase splitting;
- repeated-customer over-weighting, badge-threshold timing and appeal harassment;
- ad/reward spend used as pressure or hidden reputation input.

## Layered controls

1. Server-authoritative QR single-use, correct-shop and role checks.
2. Per-purchase submission identity plus customer+shop effective-contribution cap.
3. Unique-customer, freshness and minimum-sample gates.
4. Explainable anomaly signals; signals trigger review/hold, not automatic guilt.
5. Versioned badge evaluation and append-only correction/audit trail.
6. Appeals and false-positive safeguards; fraud heuristics are not exposed in exploitable detail.

## Effect on reputation

- `SUSPECTED` evidence can be held from new derived benefits while review proceeds.
- Substantiated invalid evidence is excluded by correction events; original history remains auditable.
- Unrelated valid negative feedback cannot be erased with the suspicious cluster.
- Merchant/shop suspension affects public badge eligibility according to scope; organization-wide spread
  requires evidence, not assumption.
- Advertising and rewards have no positive offset against fraud findings.

## Operator boundary

Operators may decide evidence status under a case/evidence model; they cannot type a replacement rating,
raise a score or manually award a badge.

`QR_COLLUSION_CAN_EARN_BADGE: NO`
`FRAUD_SIGNAL_EQUALS_GUILT: NO`

