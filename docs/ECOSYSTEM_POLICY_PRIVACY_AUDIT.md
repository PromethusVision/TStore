# Ecosystem Policy / Trust / Operations / Privacy Audit

**Result:** PASS WITH OWNER/LEGAL GATES

## Policy and Ops

- Product Taxonomy and Merchant Sector are risk signals, not legal authorization.
- Normal low-risk cohorts may use approved self-service; regulated/unknown products,
  merchants, Ads and Rewards fail closed until evidence/allowlist/reviewer exists.
- Ops uses case, evidence, policy version, capability, reversible containment and
  appeal. Admin UI alone grants nothing.
- Permanent P0 actions require stronger review/separation of duties; a small pilot
  may use manual queues rather than enterprise workflow automation.
- Ads spend, merchant scale or complaint volume cannot lower evidence standards.

## Privacy/PII/location

- PUBLIC, ACCOUNT, CUSTOMER_PRIVATE, MERCHANT_PRIVATE, SECURITY, AUDIT, POLICY and
  ANALYTICS classes remain distinct.
- Precise customer location is request-scoped and not retained by default. Public
  shop location uses approved coarse/physical business coordinates.
- Raw Auth credentials/tokens, QR tokens, chat content, support evidence and precise
  location never enter generic analytics.
- Public review identity is minimized; merchant evidence/licence documents remain
  private.
- Retention/deletion is purpose/class specific. Security/audit/verified evidence may
  be pseudonymized/retained only under approved policy and legal review.
- Demo/test/synthetic identities are marked at source and excluded from business,
  Ads, Reward and reputation metrics.

Open decisions: retention periods, public author detail, location analytics,
regulated pilot allowlist, Ops second-review thresholds and appeals/SLA.
