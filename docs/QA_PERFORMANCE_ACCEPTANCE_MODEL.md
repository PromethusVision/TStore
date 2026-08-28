# Performance Acceptance Model

State: PROPOSED — OWNER REVIEW REQUIRED

Performance acceptance begins with reproducible baselines; arbitrary universal thresholds are avoided.

## Signals

- startup and first meaningful content;
- search/nearby/product/list scroll and interaction latency;
- RPC/network latency split from client rendering;
- frame jank, memory, CPU, battery, data transfer, and cache behavior;
- low/mid representative devices, realistic datasets, warm/cold state, and network matrix.

Record percentiles, sample size, device/build/environment, variance, and regression from an approved baseline. Debug and emulator timing cannot certify release performance. Correctness, privacy, and accessibility cannot be traded away for a faster metric.

Recommendation: initially block statistically meaningful regressions and severe user-visible stalls; set numeric budgets only after repeated measurements.

OWNER_DECISION_REQUIRED: approve baseline devices/scenarios and regression budget.
