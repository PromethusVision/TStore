# Multi-App CI Model

State: FUTURE PROPOSAL — OWNER REVIEW REQUIRED

Customer App and future Merchant App require independent pipelines plus shared contract gates.

## Model

- path-aware app jobs, each with its own lockfile/platform/signing/artifact identity;
- shared package and backend-contract changes trigger both apps;
- migration/API changes run a supported-version compatibility matrix;
- release approvals and store credentials remain app/platform specific;
- one app may release independently only while backend remains compatible;
- cross-app QR, merchant/shop, catalog/listing, and review flows have integration evidence.

No Merchant App runtime currently exists in this repo baseline, so documentation from its foundation branch is not CI proof.

OWNER_DECISION_REQUIRED: choose repository layout and shared-package ownership before implementation.
