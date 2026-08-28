# Customer App Test Baseline

Status: **PASS**
Wave: **16 — Customer App Commercialization Closeout**
Baseline revision: `960e74c0836b414251a96cf14162ec74571c4f71`

## Full suite

The full local Flutter suite was run with the repository's existing dependency
resolution:

```text
flutter test --no-pub
1216 passed
0 failed
6 skipped
```

The six skipped cases are explicitly opt-in live/remote checks. They are not
silently disabled unit or widget regressions. Wave 16 does not supply remote
credentials and does not touch Development or Production, so those skips are
expected under this task's safety boundary.

## Baseline evolution

The clean starting revision had the previously documented `1213 PASS / 6
skipped` baseline. Work Package 38 added three release-logging contract tests;
the full suite then reached `1216 PASS / 6 skipped`. No assertion was removed,
weakened, or converted to a skip.

## Triage result

| Result | Count | Classification |
|---|---:|---|
| Pass | 1216 | Product, architecture, unit, widget, migration-contract and controlled integration tests |
| Fail | 0 | None |
| Skip | 6 | Explicit live/remote opt-in only |

The first sandboxed invocation could not acquire the external Flutter SDK cache
and produced no test result. Re-running through the approved host Flutter tool
completed normally; this was an execution-environment constraint, not a product
failure.

Final totals are recorded again after Work Packages 61–68 in the Wave 16 final
closeout report.

## Final integration regression

The source WP100 result was `1224 PASS / 0 FAIL / 6 skips`. Integration added
explicit retry/unlock coverage for the guarded signup and replace-cart flows,
then reran the complete suite:

```text
flutter test
1226 passed
0 failed
6 skipped (explicit live/remote opt-in)
```

The source eight additional passing tests cover duplicate signup, replace-cart
serialization, repeated review deletion, blank/stale search, guest-to-customer
state isolation and sanitized 404/503 error mapping. The two integration tests
prove that signup can retry after failure and that replace-cart unlocks after a
failed request while preserving the different-shop conflict state.
