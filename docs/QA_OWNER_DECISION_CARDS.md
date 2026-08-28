# QA Owner Decision Cards

**State:** OWNER REVIEW FORM — NOTHING SELECTED

## R01 — Pilot platform

**QUESTION:** First pilot Android-only or dual-platform?
**RECOMMENDED:** A — Android-only bounded pilot.
**WHY:** Closes commercial learning sooner while iOS signing/TestFlight/device gates remain real.
**OPTION A:** Android-only. **OPTION B:** Android+iOS.
**CUSTOMER EFFECT:** iPhone reach deferred under A. **MERCHANT EFFECT:** controlled process unchanged. **RELEASE EFFECT:** one store first. **COST:** A lower.
**OWNER CHOICE:** [ ] A  [ ] B

## R02 — Physical device scope

**QUESTION:** Focused representative set or broad lab?
**RECOMMENDED:** A — focused risk-ranked set.
**WHY:** Captures camera/GPS/lifecycle/OEM risk without unbounded fleet cost.
**OPTION A:** Focused set. **OPTION B:** Broad lab.
**CUSTOMER EFFECT:** rare-device tail under A. **MERCHANT EFFECT:** QR devices still covered. **RELEASE EFFECT:** repeatable gate. **COST:** A moderate.
**OWNER CHOICE:** [ ] A  [ ] B

## R03 — CI investment

**QUESTION:** Minimal hybrid, manual-only or broad CI?
**RECOMMENDED:** A — minimal hybrid.
**WHY:** Automates deterministic gates while preserving human release authority.
**OPTION A:** Minimal hybrid. **OPTION B:** Manual-only. **OPTION C:** Broad CI.
**CUSTOMER EFFECT:** fewer regressions. **MERCHANT EFFECT:** future onboarding path. **RELEASE EFFECT:** auditable gates. **COST:** A moderate.
**OWNER CHOICE:** [ ] A  [ ] B  [ ] C

## R04 — Test environment

**QUESTION:** Local/disposable + Development or dedicated remote TEST now?
**RECOMMENDED:** A — local plus gated Development initially.
**WHY:** Avoids environment operations before scale proves need.
**OPTION A:** Local + Development. **OPTION B:** Add TEST project.
**CUSTOMER EFFECT:** no Production mutation. **MERCHANT EFFECT:** TEST may be revisited. **RELEASE EFFECT:** serialized live gates. **COST:** A lower.
**OWNER CHOICE:** [ ] A  [ ] B

## R05 — Production authority

**QUESTION:** Separate named authorities or owner-combined with compensating review?
**RECOMMENDED:** B for lean pilot, evolve to A.
**WHY:** Fits staffing but keeps immutable evidence and second review for high risk.
**OPTION A:** Separate authorities. **OPTION B:** Owner-combined + review.
**CUSTOMER EFFECT:** safer changes. **MERCHANT EFFECT:** safer data. **RELEASE EFFECT:** never unattended. **COST:** B lower.
**OWNER CHOICE:** [ ] A  [ ] B

## R06 — Pilot operating scope

**QUESTION:** Core pilot or all proposed features?
**RECOMMENDED:** A — core Customer plus controlled merchant operation.
**WHY:** Future Merchant/ads/rewards should not dilute core reliability.
**OPTION A:** Core. **OPTION B:** All proposed.
**CUSTOMER EFFECT:** clearer reliable scope. **MERCHANT EFFECT:** some manual bridge. **RELEASE EFFECT:** smaller gate set. **COST:** A lower.
**OWNER CHOICE:** [ ] A  [ ] B

## R07 — Advanced QA

**QUESTION:** Defer broad goldens/mutation/fuzz or adopt now?
**RECOMMENDED:** A — defer broad adoption.
**WHY:** Physical and contract gaps have higher pilot value.
**OPTION A:** Focused/defer. **OPTION B:** Broad adoption.
**CUSTOMER EFFECT:** negligible near-term difference. **MERCHANT EFFECT:** none now. **RELEASE EFFECT:** faster stabilization. **COST:** A lower.
**OWNER CHOICE:** [ ] A  [ ] B

## R08 — Observability

**QUESTION:** Minimum critical signals or comprehensive platform?
**RECOMMENDED:** A — minimum critical signals with privacy review.
**WHY:** Supports staged release without enterprise cost.
**OPTION A:** Minimum. **OPTION B:** Comprehensive.
**CUSTOMER EFFECT:** critical failures detected. **MERCHANT EFFECT:** future signals added later. **RELEASE EFFECT:** monitoring gate. **COST:** A moderate/low.
**OWNER CHOICE:** [ ] A  [ ] B

## R09 — Rollout/update

**QUESTION:** Staged/advisory or immediate/broad forced update?
**RECOMMENDED:** A — staged; force only verified safety need.
**WHY:** Reduces blast radius and customer lockout.
**OPTION A:** Staged/advisory. **OPTION B:** Immediate/forced.
**CUSTOMER EFFECT:** fewer lockouts. **MERCHANT EFFECT:** mixed-client compatibility. **RELEASE EFFECT:** pause evidence. **COST:** A moderate.
**OWNER CHOICE:** [ ] A  [ ] B

## R10 — Legal/support dependencies

**QUESTION:** Qualified approval and staffed routes before pilot, or placeholders?
**RECOMMENDED:** A — approved and staffed.
**WHY:** Accuracy, recourse and store readiness are release dependencies.
**OPTION A:** Complete before pilot. **OPTION B:** Placeholder.
**CUSTOMER EFFECT:** trusted recourse. **MERCHANT EFFECT:** appeal/support if included. **RELEASE EFFECT:** explicit gate. **COST:** external review variable.
**OWNER CHOICE:** [ ] A  [ ] B

## R11 — Future Merchant App

**QUESTION:** Defer runtime until scope/contracts, or build full app in parallel?
**RECOMMENDED:** A — defer runtime, retain future QA plan.
**WHY:** Current Merchant foundation is not implementation evidence.
**OPTION A:** Defer. **OPTION B:** Parallel full build.
**CUSTOMER EFFECT:** core focus. **MERCHANT EFFECT:** controlled bridge. **RELEASE EFFECT:** independent later release. **COST:** A lower now.
**OWNER CHOICE:** [ ] A  [ ] B

## R12 — Risk/freeze/go-no-go

**QUESTION:** Explicit authority/evidence/expiry or informal consensus?
**RECOMMENDED:** A — explicit model.
**WHY:** Prevents silent exceptions and false manual PASS.
**OPTION A:** Explicit. **OPTION B:** Informal.
**CUSTOMER EFFECT:** safer pilot. **MERCHANT EFFECT:** predictable decisions. **RELEASE EFFECT:** clear NO-GO. **COST:** low.
**OWNER CHOICE:** [ ] A  [ ] B
