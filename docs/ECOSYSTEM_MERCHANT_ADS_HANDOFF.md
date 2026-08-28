# Merchant Capability to Advertising Handoff

**State:** POST-PILOT PROPOSAL — ADS NOT APPROVED

## Preconditions

Advertising must wait until merchant identity, listing ownership, policy eligibility,
organic ranking and operational dispute handling are stable. A merchant being able
to edit a listing is not sufficient authority to spend, bill or advertise it.

## Required handoff

| Merchant/canonical fact | Ads use | Prohibition |
|---|---|---|
| organization/shop membership | campaign authorization | staff capability is explicit |
| exact active listing | eligible ad object | no synthetic product identity |
| policy classification | eligibility gate | unknown/regulated fails closed |
| organic result | clearly separated baseline | paid placement cannot rewrite organic rank |
| campaign/surface ID | delivery/audit | no invisible sponsorship |
| conservative attribution | reporting | not verified purchase/reward/reputation evidence |

## First safe experiment

If separately approved after pilot, the lowest-complexity experiment is exact-listing,
Search-only, visibly sponsored, contextual/coarse-location, shadow-measured before
billing. Auction, CPA promises, cross-surface behavioral targeting and policy-sensitive
categories remain deferred.

`MERCHANT_ADS_HANDOFF: POST_PILOT_ONLY`
