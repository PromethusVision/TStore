# Release Master Checklist

State: PROPOSED — OWNER REVIEW REQUIRED

## Candidate identity

- [ ] commit, version/build, environment, configuration, signing identity, and artifact hashes recorded
- [ ] release notes/changelog match shipped scope
- [ ] no untracked or unrelated source enters the build

## Quality and safety

- [ ] static, fast, PR, full regression, RC, contract, security, privacy, and secret gates pass
- [ ] clean install, upgrade, lifecycle, network, device, accessibility, and Turkish localization evidence passes
- [ ] Auth, deep link, location, cart/review, and physical two-device QR gates pass
- [ ] migration dry-run/precheck/postcheck, invariants, compatibility, and containment are reviewed
- [ ] monitoring, alerts, support, incident, rollback/hotfix, and store metadata are ready

## Multi-app

Customer App gates are current. Future Merchant App has independent artifact/signing/acceptance gates plus shared backend compatibility; its proposal documentation is not runtime evidence.

Open manual, signing, Production, policy, UI-kit, or taxonomy gates remain NO-GO. Checklist completion must reference evidence, not a bare checkbox.

OWNER_DECISION_REQUIRED: assign checklist evidence owners and final approval authority.
