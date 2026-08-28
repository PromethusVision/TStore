# Backend Product Owner Decision Inventory

**State:** RAW DECISIONS — NONE SELECTED

| ID | Question | Systems/effect | Recommendation | Priority | Policy/legal |
|---|---|---|---|---:|---|
| BD-01 | Must Merchant V1 introduce organization + membership immediately? | merchant Auth migration and UX | one-shop organization/membership bridge only when Merchant App starts | P0 | NO |
| BD-02 | Does V1 support multiple staff and shop scopes? | capabilities invitations revocation | owner + verifier minimum; defer broad staff management if pilot permits | P0 | NO |
| BD-03 | Are merchant/shop transfers supported in pilot? | identity audit ownership | defer except manual case-based correction | P1 | YES |
| BD-04 | Which product domains require variants in V1? | catalog listing cart purchase | only correctness-critical selected domains; nullable elsewhere | P0 | NO |
| BD-05 | Are variable-measure products enabled in V1? | unit price cart QR snapshot | defer until quantity/unit confirmation contract is approved | P1 | POLICY |
| BD-06 | How are unknown/stale price and availability shown? | discovery comparison ads | explicit unknown/stale; do not claim in-stock | P0 | POLICY |
| BD-07 | Does merge choose survivor or new successor identity? | catalog/history/all consumers | survivor only for semantically identical product | P0 | NO |
| BD-08 | How are split ambiguity and review collisions displayed? | purchase review analytics | retain predecessor/preserve reviews pending explicit resolution | P0 | POLICY |
| BD-09 | Can sibling branches confirm the same QR? | merchant operations/security | NO in V1; exact issued shop only | P0 | NO |
| BD-10 | What is QR cancel/reissue behavior after cart change? | customer QR UX | explicit cancel/reissue and reconfirmation | P1 | NO |
| BD-11 | What survives customer account deletion? | Auth purchase review chat audit reward | purpose-specific delete/pseudonymize with evidence retained minimally | P0 | YES |
| BD-12 | How do review delete/restore and author display work? | reviews/privacy/trust | preserve evidence; transparent deletion lifecycle; minimize author identity | P1 | YES |
| BD-13 | What suspension actions and critical ops require second review? | merchant/ops/security/customer visibility | immediate reversible containment; second review for permanent/high-risk acts | P0 | YES |
| BD-14 | Is Reward Engine part of merchant/customer pilot? | economic ledger/support | DEFER until purchase-amount/funding/redemption decisions | P0 | YES |
| BD-15 | Are ads billing/verified-purchase attribution in V1? | ads/analytics/merchant | reporting-only candidates; no CPA/billing by default | P0 | YES |
| BD-16 | Is merchant reputation shop-level or organization-level and public in V1? | rating/reputation/cold start | shop-level factual badges later; keep rating independent | P0 | POLICY |
| BD-17 | May precise/coarse location be retained for analytics? | nearby/privacy/merchant metrics | ephemeral precise input; coarse aggregate only after review | P1 | YES |
| BD-18 | What are chat/notification/audit retention periods? | privacy/support/security | purpose-specific tiered periods; no single global period | P1 | YES |
| BD-19 | Are merchant listing uploads/review images/avatars active in V1? | Storage/media/privacy | listing media only if Merchant V1 needs it; defer review/avatar | P1 | YES |
| BD-20 | What public review author/coarse shop-location detail is shown? | anon/customer privacy | minimized author and approved shop precision | P2 | YES |
| BD-21 | Are demo entities retired when real merchants onboard? | catalog/demo/customer dependencies | no blind conversion/delete; case-by-case soft retirement | P1 | NO |
| BD-22 | May product candidates auto-promote to canonical? | catalog integrity/merchant UX | NO for V1; governed review queue | P0 | POLICY |
| BD-23 | Is search query history/personalization retained? | search/privacy/analytics | no raw long-term history in V1 | P1 | YES |
| BD-24 | Which merchant dashboard metrics launch? | merchant trust/analytics | action health + verified purchase counts; soft intent clearly separate | P1 | POLICY |
| BD-25 | Do push notifications and new Realtime channels launch in V1? | customer/merchant ops | keep current in-app; add only operation-critical merchant channel | P2 | YES |

Implementation details such as exact index type, lock primitive, function name,
batch size or outbox transport are deliberately excluded from Product Owner work.

