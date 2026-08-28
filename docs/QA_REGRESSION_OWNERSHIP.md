# Regression Ownership

**State:** PROPOSED

Every confirmed defect should receive protection at the cheapest layer that reproduces its root cause, plus higher-layer evidence only when integration risk requires it.

## Flow

1. capture minimal deterministic reproduction and affected versions;
2. classify root cause and missing/failed gate;
3. add a failing regression before or with the fix where practical;
4. verify adjacent race/error/role boundaries;
5. link defect, test and release impact;
6. integration reruns shared/critical suites.

A test may be impractical for native hardware, vendor email, store or Production behavior. In that case preserve a manual matrix step and explain why automation is insufficient. Cosmetic one-off changes do not justify brittle broad E2E tests.

The fixing feature agent owns initial protection; integration owns independent combined verification.
