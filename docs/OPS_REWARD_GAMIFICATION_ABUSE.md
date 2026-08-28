# Reward and Gamification Abuse Operations

**State:** PROPOSED PLACEHOLDER — REWARD SOURCE BRANCH NOT AVAILABLE

The referenced `origin/agent1/w18-reward-gamification-reputation-foundation` branch was not present at preflight. No reward selection, progress, reset, coupon value, expiry, funding, or enforcement rule is inferred here.

## Preserved canonical constraints

- progress can derive only from server-authoritative verified physical purchases under future owner-final rules;
- an ad view/click cannot create reward entitlement;
- operators cannot manually grant progress, coupon, reputation, or verified purchase;
- reward state is independent from review and merchant reputation;
- unknown behavior fails closed for payout/claim while legitimate history is preserved.

## Potential abuse cases

QR/customer/merchant collusion, repeat-shop cycling, multi-account/device farm, replayed progress event, staff self-confirmation, coupon duplication/transfer, race-condition double claim, merchant-funded manipulation, account takeover, and operator favoritism.

## Operations pattern

Hold disputed claim/derived benefit → link verified-purchase/QR/account evidence → distinguish technical duplicate from abuse → apply owner-approved reason/scope → preserve ledger/history → communicate/appeal → reconcile. Permanent restriction or balance removal requires high confidence and a separately approved policy.

## Deferred dependencies

Owner-final reward object/lifecycle, immutable event identity, funding/liability, expiry, eligible merchant selection, household/device policy, fraud thresholds, correction/reversal, privacy, and customer communication.

`REWARD_SOURCE_BRANCH_FOUND: NO`

`REWARD_ABUSE_RUNTIME_IMPLEMENTED: NO`
