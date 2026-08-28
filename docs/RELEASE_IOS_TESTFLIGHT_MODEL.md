# iOS TestFlight Model

State: PROPOSED — OWNER REVIEW REQUIRED

TestFlight is the proposed beta distribution path after a real Apple-signed archive exists. Windows static validation is not a substitute for macOS archive, signing, upload, and device acceptance.

## Stages

- internal testers validate identity, install, launch, auth/deep links, permissions, and core smoke;
- external testers are optional and require App Review/beta information;
- the exact accepted build advances to App Store release review;
- feedback and crash evidence are tied to build number and device/OS.

Tester invitations must not expose Production secrets or depend on reusable shared credentials. Production-like backend use follows the environment and live-test policies.

OWNER_DECISION_REQUIRED: decide internal/external tester groups, Apple team roles, and whether V1 needs external beta.
