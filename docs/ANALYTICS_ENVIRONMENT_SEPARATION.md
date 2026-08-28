# EsnaftaVar Analytics Environment Separation

**State:** `REQUIRED FAIL-CLOSED BOUNDARY`

Every event, log, metric, trace, aggregate and dashboard is bound to one explicit
environment. Development, automated test, demo/staging and Production use separate
credentials/configuration, ingestion targets or hard filters; missing environment
is rejected rather than defaulting to Production.

Development project ref `tnipyxnvhgelwdpykyez` is never accepted as Production.
Production apps do not fall back to Development config. Cross-environment entity
IDs cannot join, and Release/alert dashboards show the environment prominently.

Synthetic Production smoke events, if ever authorized, carry an allowlisted test
marker and are excluded from business metrics. Secret/service-role credentials are
never client analytics configuration.

Cross-environment ingestion is a security/data-quality stop condition: quarantine,
alert, preserve bounded evidence, fix producer config and restate contaminated
aggregates. Do not silently relabel events after receipt.

`DEV_PROD_ANALYTICS_MIXING: FORBIDDEN`

