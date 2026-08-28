# Commercial Electronic Messages and Notifications

**State:** CLASSIFICATION FRAMEWORK — LAWYER REVIEW REQUIRED

Push, e-mail, SMS and calls are classified by actual content/purpose, not by the
channel name or an internal “notification” flag.

| Class | Candidate example | Default treatment |
|---|---|---|
| Essential account/security | confirmation, recovery requested by user, security alert | send only to perform/protect requested service; no promotional copy |
| Transactional product | merchant response to current conversation, QR status, support-case update | purpose-bound and preference-aware where appropriate |
| Product engagement | wishlist reminder, nearby shop reminder, reactivation | commercial/marketing review; off until approved consent/ret route |
| Sponsored/merchant marketing | campaign, discount, merchant promotion | commercial electronic message; consent/IYS/sender/ret rules review |
| Operational merchant | verification evidence request, security or policy notice | necessary account/business communication; avoid unrelated promotion |

## Required controls

- immutable purpose/template classification and sender identity;
- lawful recipient source; no purchased/borrowed contact lists;
- IYS and prior-consent analysis for covered commercial messages;
- easy, free refusal where applicable and timely suppression;
- security/transactional messages remain free of bundled advertising;
- preference, consent/ret, template version and delivery evidence;
- frequency controls and no dark-pattern opt-in;
- provider/controller/processor/transfer review;
- message bodies excluded from general logs.

Merchant ability to contact a customer inside chat does not grant off-platform SMS,
e-mail or phone marketing permission. Account closure/consent withdrawal must
propagate to scheduled campaigns and provider queues.

`COMMERCIAL_MESSAGE_POLICY_FINALIZED: NO`
