# EsnaftaVar Demo Data Analytics Boundary

**State:** `PROPOSED`

Demo entities and traffic carry a stable `data_origin=DEMO`/equivalent environment
marker at source. They use deterministic fixture identities and never enter real
merchant/customer KPI, advertising billing, reward, reputation or acquisition
reports.

Demo dashboards may validate formulas and UI with an unmistakable banner. Reset/
reseed produces traceable dataset-version changes and does not look like business
growth. Cloning demo data into another environment preserves its demo origin.

If a demo merchant later becomes real, create/verify real identities and start
business measurement at the approved cutover; do not relabel historical fixture
events as real. Production must not be seeded with unmarked demo activity.

`DEMO_TRAFFIC_IN_BUSINESS_METRICS: NO`

