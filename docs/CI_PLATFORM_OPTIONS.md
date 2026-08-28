# CI Platform Options

State: PROPOSED — OWNER REVIEW REQUIRED

| Option | Strength | Limitation |
|---|---|---|
| Local/manual only | No hosted setup cost | Inconsistent gates, weak audit, machine dependence |
| GitHub Actions | Native PR/status/artifact integration | Hosted minutes, secret and workflow security work |
| Hybrid | Fast deterministic CI plus manual/live/physical gates | Requires clear evidence handoff |

Recommendation: future hybrid model—GitHub Actions for unprivileged deterministic analyze/test/static/build contracts, with explicitly authorized local/manual paths for signing, Development live tests, physical devices, and Production release.

No CI provider is configured here. Initial workflows should be minimal, pinned, least-privilege, and measured before adding nightly matrices.

OWNER_DECISION_REQUIRED: select CI provider/budget and whether private runner maintenance is justified.
