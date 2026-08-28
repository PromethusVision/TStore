# Backend Demo and Real Data Boundary

**State:** PROPOSED HARD SEPARATION

Demo identity is an explicit data dimension and provenance, never inferred only
from name, null owner, featured status or neighborhood. Real and demo rows may
coexist for customer discovery only when clearly labelled and policy-approved.

## Rules

- deterministic demo IDs/markers cannot collide with or overwrite real rows;
- dashboards, merchant acquisition, ads, rewards, reputation and verified-purchase
  metrics exclude demo by default;
- a real merchant cannot claim an ownerless demo shop through client mutation;
- converting demo to real requires a new governed identity/ownership workflow, not
  marker removal;
- demo products/listings with real customer dependencies cannot be blindly deleted;
- demo fixtures do not grant Auth, review, QR, rating or merchant capability;
- Production, Development, test and local fixtures are separate environments in
  addition to demo/real classification.

Public UI labelling and whether demo entities remain after real onboarding are
`OWNER_DECISION_REQUIRED`. Historical events preserve their demo/test flag.

