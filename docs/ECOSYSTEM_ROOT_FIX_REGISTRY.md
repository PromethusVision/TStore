# Ecosystem Root-Fix Registry

**State:** RECOMMENDED — ROOT OPTIONS NOT OWNER SELECTED

| Root fix | Covered failures | Contract effect | Pilot effect | Remaining manual work |
|---|---|---|---|---|
| ECO-RF01 Server authorization boundary | F001 F009 F021 | membership/capability/RLS, no UI authority | enables safe verifier path | capability acceptance |
| ECO-RF02 Canonical identity triad | F003 F011 F023 | Product/Variant/Listing and media ownership | prevents catalog/review corruption | ROOT-04/05 decision |
| ECO-RF03 Authoritative evidence firewall | F004 F006 F007 F008 | QR-only purchase; Ads/analytics/reward separated | trustworthy review loop | concurrency/physical QR |
| ECO-RF04 Historical correction ledger | F005 F024 | correction/lineage rather than rewrite | safe future catalog fixes | ROOT-06 decision |
| ECO-RF05 Exact release evidence | F010 F022 | artifact/environment/manual truth classes | honest go/no-go | ROOT-01 and devices |
| ECO-RF06 Pilot merchant seam | F012 F013 F021 | one-shop controlled path, future org seam | removes full-app blocker | ROOT-07/12 |
| ECO-RF07 State provenance | F014 F015 | owner-final/proposed/runtime states stay distinct | avoids accidental activation | ROOT-03/08 |
| ECO-RF08 Lean governed operations | F009 F016 | named operator, case, audit, reversible action | minimum safe operations | ROOT-17 |
| ECO-RF09 Purpose-limited analytics | F006 F017 F020 F024 | authoritative/domain/audit/telemetry separation | minimum visibility | ROOT-18/privacy review |
| ECO-RF10 Post-pilot economic systems | F018 F019 | Ads/Reward/Reputation inactive by default | shortens critical path | ROOT-13–16 later |
| ECO-RF11 Honest availability/metric language | F020 | stale→unknown; intent≠sale | prevents customer/merchant deception | ROOT-10 |
| ECO-RF12 Rights-aware media promotion | F023 | listing media never silently canonical | protects rights/provenance | ROOT-05 |

The twelve rules account for all 24 findings. They reduce repeated implementation
choices, but no root owner option is selected by this registry.

`ROOT_FIX_COVERAGE: 24/24`
