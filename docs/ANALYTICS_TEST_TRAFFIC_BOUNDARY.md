# EsnaftaVar Test Traffic Analytics Boundary

**State:** `REQUIRED`

Automated, QA, synthetic monitor and manual smoke traffic is marked at the trusted
producer/account/config boundary—not inferred later from a user-agent string.
Test principals, shops, campaigns, QR purchases and fixtures use allowlisted test
identities and are excluded from business, ad billing, reward and reputation.

Observability retains test traffic in a separate view because it is valuable for
release/synthetic health. A test that intentionally exercises a failure must not
page Production unless the tested isolation itself fails.

Unmarked Production test traffic is a data-quality incident. Remediation appends
an invalidation/classification record and restates projections; raw evidence is
not destructively edited.

`TEST_TRAFFIC_BUSINESS_EXCLUSION: REQUIRED`
