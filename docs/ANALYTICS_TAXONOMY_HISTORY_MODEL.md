# EsnaftaVar Analytics Taxonomy History Model

**State:** `PROPOSED`

Every category-dimensioned metric chooses one projection:

- `EVENT_TIME_TAXONOMY`: node/version effective when the event occurred;
- `CURRENT_TAXONOMY_ROLLUP`: versioned successor/ancestor mapping at report time;
- `SOURCE_AS_RECORDED`: legacy/proposal locator for reconciliation only.

Rename keeps stable identity. Move keeps identity if concept is unchanged while
event-time parent remains queryable. Merge rolls predecessor facts once to the
successor. Split requires deterministic evidence; otherwise facts remain on the
predecessor or explicit unresolved bucket. Retirement preserves history.

Reports state projection and mapping version and expose unresolved volume. Search
synonyms, legacy redirects and taxonomy identity are separate. Proposed L2 nodes
remain labelled proposals and cannot silently become canonical analytics groups.

`TAXONOMY_HISTORY_PROJECTION_SELECTED_GLOBALLY: NO`

