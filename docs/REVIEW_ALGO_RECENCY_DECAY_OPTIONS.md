# Recency and Decay Options

**State:** OPTIONS — PILOT RECOMMENDATION ONLY

| Option | Behavior | Benefit | Risk |
|---|---|---|---|
| lifetime | all eligible contributions equal forever | simplest, stable | old performance can dominate indefinitely |
| fixed rolling window | only responses in disclosed window count | explainable freshness | boundary jumps; low-volume shops lose history |
| exponential decay | continuously lower old weights | smooth adaptation | opaque parameter; hard customer explanation |
| dual view | lifetime context plus recent decision window | transparent history and current signal | more UI/ops complexity |
| event reset/segment | ownership transfer or major change starts a new segment | reflects material change | reset gaming and adjudication risk |

## Recommendation

For the pilot, collect timestamps and policy versions but **do not apply aggressive decay or public
badges**. If scoring is introduced, test a disclosed rolling/freshness gate with lifetime context.
Consider exponential decay only after enough longitudinal data demonstrates value.

## Badge aging

- Old good history cannot preserve a badge forever without fresh eligible evidence.
- Low transaction volume should lead to `AT_RISK/insufficient freshness`, not an accusation.
- Ownership transfer, closure and fraud holds are separate state transitions, not decay tricks.
- Window changes require a new algorithm version and impact simulation.

`PILOT_DECAY: NONE`
`TIMESTAMP_COLLECTION: REQUIRED`
