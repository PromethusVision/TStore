# Ecosystem Merchant / Shop / Staff Authorization Audit

**Result:** PASS — TAXONOMY AND UI ARE NOT AUTHORIZATION

## Reconciled authorization chain

```text
AUTH USER
  -> active MEMBERSHIP
  -> MERCHANT ORGANIZATION
  -> exact SHOP/BRANCH scope
  -> small server-defined CAPABILITY
  -> resource lifecycle/policy/revision
```

- Merchant sector describes business identity. It cannot prove shop ownership,
  licence, product policy, staff capability or Ads eligibility.
- Product taxonomy classifies goods and cannot grant merchant capability.
- Profile role/JWT metadata/navigation visibility is not authority.
- Current direct shop-owner fields remain a compatibility bridge until an additive
  membership model is approved and migrated.
- Owner/verifier/catalog-editor presets are safer than dozens of roles. Custom
  enterprise roles and full multi-branch automation are deferred.
- Exact-shop QR verification is narrower than organization membership; sibling
  branches cannot confirm unless a future owner decision and contract explicitly
  permits it.
- Revocation/suspension is checked at each command and subscription; cached UI state
  never extends access.
- Operator/admin access remains a separate case/capability model.

Open roots: organization topology, staff launch scope, transfer, sector assignment
level and policy verification owner.
