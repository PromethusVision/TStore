# QA Contrarian Review

**State:** REVIEW COMPLETE — RECOMMENDATIONS REMAIN PROPOSED

## Challenges and conclusions

- **Are we over-testing the pilot?** The full architecture is larger than V1. Only critical Customer, backend invariant, signed artifact and physical gates belong to the pilot MUST set; ads/rewards/full Merchant/advanced QA defer.
- **Does CI bring enough value now?** Yes, a small deterministic PR/main gate. Broad nightly, shards and release automation do not yet justify cost.
- **Are physical tests more valuable than more mocks?** Yes for two-device QR, real GPS/camera, callbacks, lifecycle/network and exact signed install. Another mock cannot close these gaps.
- **Are goldens maintenance-heavy?** Yes before the final UI kit. Defer broad goldens; later adopt a small stable set.
- **Too many devices?** A focused risk-ranked Android set is appropriate; a broad lab is not.
- **Is iOS required for first pilot?** Not necessarily. Android-only is recommended if owner accepts reach limits.
- **Can controlled manual release be safer initially?** Yes for signing/store/Production with evidence and explicit authority; deterministic checks should still be automated.
- **Nightly suites?** Unnecessary until runtime/PR volume or suite duration shows value.
- **Enterprise theatre?** Two-person review for every action, exhaustive dashboards, full mutation testing and complex branch trains are excessive. Retain strict controls only for secrets, Production, signing, destructive migrations and integrity.
- **Are we designing for a larger company?** The architecture is future-ready, but V1 documents now explicitly separate MUST/SHOULD/DEFER.

Changed emphasis: prioritize physical and exact-artifact evidence over advanced test metrics, use minimal hybrid CI, Android-only pilot as the recommendation, and keep Merchant App/future domains from blocking Customer pilot.
