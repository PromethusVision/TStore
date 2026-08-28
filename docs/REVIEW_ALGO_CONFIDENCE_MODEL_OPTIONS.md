# Confidence and Minimum-Sample Model Options

**State:** OWNER/METHOD REVIEW REQUIRED

## Confidence is not quality

A 4.8 estimate from five effective customers and a 4.7 estimate from two hundred customers may have
similar observed means but different uncertainty. Public language should say `Yeterli veri yok`, not
assign a bad score to the first merchant.

## Minimum-sample options

| Option | Rule | Strength | Weakness |
|---|---|---|---|
| fixed N | one effective-customer threshold | simple | ignores distribution and recency |
| N plus unique-customer share | minimum count and diversity | blocks repeated-customer dominance | needs denominator definition |
| precision-based | uncertainty width/lower-bound condition | statistically responsive | harder to explain |
| hybrid | minimum count + confidence + freshness/integrity | balanced | more versioned rules |

No numeric threshold is chosen. Thresholds require pilot distributions, false-positive tolerance and
merchant-facing comprehension tests.

## Confidence display options

- Show effective verified-response count and date window.
- Use broad states: `insufficient`, `developing`, `established`; never imply certification.
- Keep internal interval/uncertainty for badge decisions; avoid decorative confidence percentages.
- Recompute after evidence corrections using the same immutable rule version.

## Wilson limitation

Wilson/lower-bound methods are defensible for a binomial proportion. Turning 1–5 into positive/not
positive discards ordinal information and embeds a threshold choice. It can support a future binary
metric but is not adopted as the main merchant-star algorithm.

`SMALL_SAMPLE_PROTECTION: REQUIRED`
`MINIMUM_SAMPLE_VALUE: OWNER_DECISION_REQUIRED`

