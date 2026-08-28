# EsnaftaVar Search Analytics Model

**State:** `PROPOSED — PRIVACY/OWNER DECISION REQUIRED`

## Candidate sequence

`search_submitted` records a search intent; `search_results_presented` records a
bounded result-count band and resolver/index version; `search_result_opened`
records the stable selected entity/rank bucket. `search_no_results_observed` may
be a server-derived result of zero. `search_abandoned` is emitted only if a future
measurable timeout/session definition is approved; absence of a click alone is
not automatically abandonment.

Category resolution records stable taxonomy target, term type (canonical, alias,
synonym, typo/fuzzy), ambiguity state and rule version. It never promotes a search
term to taxonomy identity, product fact or policy eligibility.

## Privacy default

Do not retain raw query text by default. Prefer a normalized controlled vocabulary
ID, coarse query class, irreversible high-threshold aggregate or result-quality
label. Rare/unmatched text may contain names, addresses, health intent or other
personal data and requires a separate owner/privacy/legal decision, short
retention and restricted access if ever enabled.

Search events do not include precise location, customer email/phone, merchant
private data or full result lists. Guest search remains pseudonymous and is not
retroactively linked to an account by default.

Metrics separate query volume, zero-result rate, resolved category quality and
result-open rate. They do not claim satisfaction or purchase causality.

`RAW_QUERY_RETENTION_DEFAULT: NO`

