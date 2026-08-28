# EsnaftaVar Esenler Pilot — QR Operating Model

**State:** `PROPOSED OPERATIONS CONTRACT — NO LIVE QR ACTION`

## Purpose

QR confirmation supplies bounded evidence that an authenticated merchant/shop
confirmed an in-person purchase. It does not process payment, prove amount/revenue,
or guarantee product quality.

## Roles and authority

| Role | May do | Must not do |
|---|---|---|
| Customer | Present/scan the supported QR step and view result | Create purchase evidence alone |
| Exact-shop verifier | Confirm for the bound shop and supported listing/product | Confirm another shop or reuse a token |
| Server-authoritative path | Validate token, actor, shop, expiry and idempotency; create one fact | Trust client success or notification delivery |
| Operator | Triage exceptions from audit evidence | Manually fabricate/delete authoritative history |

## Normal operating sequence

1. supported exact artifact and environment are confirmed;
2. customer and merchant identities/session states are valid;
3. QR is issued with short bounded lifetime and no sensitive display payload;
4. verifier scans/accepts at the physical shop;
5. server atomically validates exact shop, token, product/listing and replay state;
6. exactly one verified-purchase fact is returned/reconciled;
7. customer and merchant see outcome without payment/revenue language;
8. failures use reason classes and support path; raw QR/token is not logged.

## Pilot training card

Merchant can explain: “Bu işlem ödemeyi almıyor; alışverişin EsnaftaVar içinde
doğrulandığını kaydediyor.” Train normal, expired, wrong-shop, offline/timeout,
already-confirmed and device/session-recovery cases. Observe a successful and a
safe failed attempt before marking the shop ready.

## Reconciliation

Daily/launch-window checks compare issued, attempted, rejected, confirmed and
duplicate/replay outcomes. A timeout followed by server success is reconciled by
authoritative ID; it is not retried as a new purchase. Notifications are delivery
signals, never the ledger.

## QR launch options

| Option | Benefit | Risk |
|---|---|---|
| Day-one QR for all ready shops | Tests full value loop early | Training and incident load can mask discovery learning |
| Staged QR after discovery acceptance | Isolates discovery/catalog value first | Delays verified-purchase/review evidence |
| Small QR cohort inside launch cell | Bounded operational learning | Mixed customer expectations require clear labeling |

No option is selected. If QR is enabled, atomicity/replay/exact-shop/physical two-
device gates are mandatory regardless of cohort size.

## Pause conditions

Any duplicate durable purchase, wrong-shop acceptance, client-only success without
reconciliation, raw token exposure, unresolved authorization defect, or inability
to distinguish timeout from committed success pauses QR immediately.

`QR_VERIFIED_PURCHASE_EQUALS_PAYMENT: NO`

`QR_OPERATING_OPTION_SELECTED: NO`
