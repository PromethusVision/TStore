# EsnaftaVar Privacy Data Map

**State:** PROPOSED DATA INVENTORY — KVKK/LEGAL REVIEW REQUIRED
**Scope:** Customer App, future Merchant App, backend, Operations, ads/rewards and
analytics foundations. No collection is authorized merely because it appears here.

## Data subjects and identifiers

| Subject | Candidate identifiers | High-risk linkage | Default minimization |
|---|---|---|---|
| Customer | opaque user ID, e-mail for Auth, optional profile fields | exact location + purchase/search/review history | feature-specific projections; no universal customer profile |
| Merchant principal | opaque user ID, merchant/shop IDs, business contact | identity/evidence documents, regulated status | verified facts/status; raw documents restricted |
| Merchant staff | user/shop/role/scope IDs | actions across shops, contact and security history | server-derived membership and least privilege |
| Operator | operator profile/capability/case assignment | privileged queries and decisions | audit all sensitive access/action |
| Reporter/appellant | protected account/case reference | disclosure to reported party | pseudonymous case reference by default |
| Non-user/content subject | names/images/messages in UGC | unable to exercise in-app controls | reporting/removal/privacy route required |

## Processing inventory

| Domain | Minimum candidate data | Purpose boundary | Excluded by default | Privacy class | Open retention/recipient questions |
|---|---|---|---|---|---|
| Auth | opaque user ID, e-mail, confirmation/session state, safe security events | create/authenticate/recover account | password, OTP, token, recovery link in logs/support | identity/security | Auth provider role, security-log period, overseas transfer |
| Customer profile | name/display fields actually used, account status | personalize visible account and support | broad demographics, ID number | identity | optional fields, correction/deletion consequence |
| Merchant identity | merchant/shop ID, declared business data, scoped verification state | authorize merchant capabilities | full document copies in ordinary views | identity/regulatory | evidence set, issuer verification, expiry, retention |
| Staff roles | user/shop/role/capability, invitation status | authorize exact shop action | client-asserted role, cross-shop access | security | invitation evidence, offboarding logs |
| Precise location | transient lat/lon and requested radius | execute a single nearby/distance request | movement trail, merchant visitor map | precise location | lawful basis, server transit, diagnostics |
| Saved location/address | label and user-chosen coordinates/address | private saved-location/address feature | analytics reuse, merchant access | precise location/contact | deletion, address versus discovery separation |
| Coarse geography | approved district/cell/band | aggregate feature quality/local relevance | small-cohort re-identification | personal/aggregate candidate | cell size, threshold, raw deletion |
| Search | query in current request; resolved category/product IDs | deliver search and improve controlled vocabulary | general long-lived raw query history | behavior; may reveal sensitive intent | pilot defaults to no raw retention |
| Discovery/product views | surface, stable entity IDs, result/outcome class | product health and bounded contextual ranking | contact, exact location, arbitrary metadata | product analytics | optionality, consent/legal ground, raw period |
| Wishlist/cart | customer ID, product/listing/shop, quantity/state | customer-requested private utility | merchant marketing export | account/private commerce intent | account deletion, inactivity period |
| QR session | opaque session/transaction, customer/shop actors, timestamps/status | prevent replay and create verification evidence | raw QR secret in analytics/logs | security/commercial evidence | expiry, failed-attempt period, staff visibility |
| Verified purchase | transaction ID, shop/customer pseudonymous link, item/price snapshot, evidence status | eligibility, dispute, review integrity | payment/receipt/revenue claim | trust/commercial evidence | legal basis, pseudonymization, correction, long-term period |
| Reviews/ratings | review ID, author/evidence reference, product/shop, content/status | publish authenticated experience and rating | health/sensitive purchase exposure in badges | public UGC + evidence | account deletion, moderation history, merchant response |
| Chat | participants, conversation/shop context, text/attachment reference, timestamps | private customer-merchant communication | analytics meaning, general operator search | private content | retention, participant export/deletion, legal hold |
| Notifications | recipient, purpose/template, delivery/open state, preference | transactional/product communication | message body in logs; marketing without consent | communication | transactional/marketing split, IYS, provider role |
| Support/cases | case/subject/reference, issue class, minimum evidence, decision/history | resolve support/moderation/privacy request | passwords, OTPs, unrelated activity | support/private | access by case, appeal window, attachments |
| Security logs | actor/session/request pseudonymous IDs, allowlisted outcome/risk signals | protect accounts/platform | body/content/token/precise location | security | restricted period, breach use, no marketing reuse |
| Audit trail | operator/action/reason/before-after/case/policy version | accountability/reversal | unnecessary document/body copies | privileged audit | tamper resistance, access, retention |
| Ads eligibility | campaign/listing/shop/product/policy/budget state | decide if paid placement may serve | customer profile when contextual inputs suffice | commercial operational | ad policy version, rejection evidence |
| Ad relevance | current surface/query/category and bounded location context | contextual/local relevance | third-party ID, broker list, cross-app retargeting | optional/ad | legal ground, explanation, deletion/control |
| Ad measurement | campaign/creative/placement event, anti-fraud result | invoice/reporting/quality if ads launch | customer-level merchant export | ad measurement | aggregate thresholds, retention, invalid traffic |
| Rewards | authoritative event, program/funder/rule snapshot, immutable ledger if launched | calculate/reconcile approved benefit | balance overwrite; sensitive purchase public badge | economic/trust | tax/legal ground, expiry, account deletion |
| Reputation | eligible evidence and versioned calculation | show approved merchant trust signal | opaque punitive/customer social score | derived trust | explanation, correction, no paid influence |
| Catalog provenance | product/variant/listing IDs, source/assertion/evidence/version | identity and claim traceability | unrelated submitter PII | commercial evidence | durable lineage versus submitter minimization |
| Media/storage | owner/reference/type/scan/status | render approved profile/listing/chat/evidence media | embedded metadata, orphan forever | content | exact owner, access, orphan cleanup, deletion |
| Crash/diagnostics | app/build/device class, sanitized stack/outcome, correlation ID | stability/security | e-mail, token, body, exact coordinate | operational telemetry | provider/transfer, sample, period |
| Demo/test | synthetic IDs and explicit environment/test marker | QA/demo | real customer/merchant PII | synthetic | deterministic cleanup and metric exclusion |

## Special-category and inference guard

EsnaftaVar should not solicit health, biometric, criminal-conviction, belief or
similar special-category data for ordinary discovery. Search text, a medical-product
view, support evidence or regulated-merchant document can nevertheless reveal or
contain sensitive information. Such fields are rejected/redacted where not needed;
if genuinely necessary they receive an explicit purpose, ground, access class and
specialist review under the current Article 6 framework.

## Controller-role open items

Final role mapping is required for Supabase/Auth/hosting, crash/analytics vendors,
e-mail/push providers, maps/geocoding, future ad tooling, support tooling and store
platforms. A processor label in a contract does not replace facts about who decides
purpose and means.

`DATA_MAP_COMPLETE_FOR_FOUNDATION: YES`
