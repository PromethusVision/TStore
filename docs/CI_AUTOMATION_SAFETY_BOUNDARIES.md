# CI Automation Safety Boundaries

**State:** PROPOSED — OWNER REVIEW REQUIRED

| Class | Definition | Examples |
|---|---|---|
| FULLY_AUTOMATED_SAFE | Deterministic, isolated, reversible/no external mutation | format/diff/analyze, unit/widget/contract tests, local ephemeral DB replay, unsigned compile |
| AUTOMATED_WITH_HUMAN_GATE | Tool executes after exact input/environment approval | protected signing, Development live suite, store upload to internal track |
| PHYSICAL_HUMAN_REQUIRED | Native hardware or human observation is the evidence | two-device QR, real GPS/camera, OS callbacks, accessibility/visual review |
| PRODUCTION_HUMAN_REQUIRED | Changes or materially exercises Production | migration, store Production rollout, rollback, kill switch, minimal Production smoke |
| OWNER_DECISION_REQUIRED | Product/cost/risk choice precedes engineering | first platform, device support, rollout policy, accepted risk |

## Guardrails

Classification follows the highest-risk effect in a chain. A safe automated test does not make its Production deployment safe. Human approval is bound to immutable inputs and is not a reusable blanket token. Physical evidence cannot be synthesized from mocks, and owner choices cannot be silently converted into engineering defaults.

OWNER_DECISION_REQUIRED: approve this classification and protected-job approver model.
