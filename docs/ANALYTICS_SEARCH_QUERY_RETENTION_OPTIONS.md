# EsnaftaVar Raw Search Query Retention Options

**State:** `OWNER/PRIVACY DECISION REQUIRED`

Raw queries can contain names, addresses, medical intent and other personal data.
They are not retained by default.

| Option | Data | Benefit | Risk |
|---|---|---|---|
| A — No raw retention | Controlled vocabulary/category IDs and quality classes only | Safest; enough for baseline quality | Unknown-query research limited |
| B — On-device normalization | Raw query never leaves device; send governed IDs/flags | Better classification with low central risk | Client consistency/versioning |
| C — Short restricted sample | Sampled raw unmatched queries, redacted, access-controlled and rapidly expired | Vocabulary/collision research | Sensitive leakage, consent/legal burden |
| D — General raw history | Long-lived account/session-linked queries | Maximum analysis | Disproportionate; not recommended |

Recommended pilot option is A, optionally B. C requires owner plus privacy/legal
approval, automated sensitive-pattern rejection, minimum sample thresholds,
restricted reviewer workflow and deletion validation. D is not recommended.

No option is selected here.

`RAW_SEARCH_QUERY_OPTION_SELECTED: NO`
