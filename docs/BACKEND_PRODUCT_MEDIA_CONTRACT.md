# Backend Product Media Contract

**State:** PROPOSED OWNERSHIP SPLIT

Canonical product media communicates shared product identity and is written only
through trusted catalog/operations governance. Listing media communicates a shop's
local offer and is future merchant-owned under exact listing/shop capability.

## Rules

- canonical and listing media have distinct path namespaces and owner subjects;
- merchant cannot overwrite global canonical media;
- media row/pointer includes stable object reference, version, role/order, source,
  moderation/lifecycle and alt/accessibility metadata where applicable;
- product/listing retirement stops new presentation but keeps historical purchase
  snapshots independent of live URLs;
- broken/null media falls back safely and never hides functional actions;
- duplicate/hash scanning is a quality tool, not ownership proof;
- ads use eligible listing/canonical media but cannot rewrite either source.

Current URL/array fields remain compatibility surfaces. A normalized media entity,
merchant uploads and review images are `OWNER_DECISION_REQUIRED`.
