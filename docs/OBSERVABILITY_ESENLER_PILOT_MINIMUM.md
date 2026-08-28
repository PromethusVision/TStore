# EsnaftaVar Esenler Pilot Monitoring Minimum

**State:** `RECOMMENDED MINIMUM — LOW-COST/FREE-FIRST`

Before pilot traffic:

1. confirm Development/demo/test/Production separation and release identity;
2. capture privacy-safe fatal/nonfatal customer and merchant app errors;
3. monitor startup/auth, critical RPC, search, storage media and Realtime errors;
4. create QR issue/validation/purchase/replay/server-error reconciliation;
5. use Supabase service logs for API/Postgres/Auth/Storage/Realtime diagnosis;
6. create daily data-quality checks for duplicates, quarantine, freshness and
   environment contamination;
7. define P0/P1 contact/runbook and manual health review cadence;
8. keep business KPI and health dashboards separate.

Start with existing provider logs plus one privacy-reviewed crash/error tool and a
small governed metric set. Do not buy a broad analytics stack before pilot
questions, volume and privacy decisions justify it. Test alerts in non-Production
and document gaps caused by free/plan retention limits.

`PILOT_MONITORING_IMPLEMENTED: NO`

