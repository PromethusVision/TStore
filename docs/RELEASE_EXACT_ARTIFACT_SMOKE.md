# Exact Artifact Smoke

State: PROPOSED — OWNER REVIEW REQUIRED

The binary submitted to a store must be the binary accepted. A rebuild, re-sign, configuration substitution, or post-test packaging step creates a new candidate.

## Smoke scope

- verify hash, signature/certificate identity, package/bundle ID, version/build, and environment;
- install from the distribution path on representative devices;
- launch, auth/session, callback, location permission, home/search/product, cart, review eligibility, QR physical path, and logout;
- inspect crash/log/health signals without sensitive payloads;
- confirm no debug banner, test endpoint, demo-only write, or hidden credential.

Record device/OS, tester, time, account class, result, evidence link, and cleanup. Production smoke is minimal and non-destructive; negative/adversarial coverage belongs outside Production.

OWNER_DECISION_REQUIRED: approve exact-artifact smoke owners and representative devices.
