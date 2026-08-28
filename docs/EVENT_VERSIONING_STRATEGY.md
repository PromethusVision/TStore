# EsnaftaVar Event Versioning Strategy

**State:** `PROPOSED`

Each event type has an integer `event_version` and an immutable registry entry.

- Additive optional field with unchanged semantics: same version, documented
  default/absence behavior.
- New required field, type/unit change, enum reinterpretation or authority/privacy
  change: new version.
- Display-name, UI or producer refactor with unchanged contract: no version bump.
- Event meaning must never change silently under the same type/version.

A registry records owner, producer, schema fingerprint, examples, authority,
privacy/retention, compatibility, activation/deprecation dates and successor.
Producers and consumers declare supported versions. Rollout is expand → dual-read
or parallel emit where safe → consumer verification → old producer retirement →
retention-aware deprecation. Parallel emission must not double-count metrics.

Historical events retain their original version. Metrics pin accepted event
versions and publish a metric-definition version. Unsupported versions are
quarantined with bounded diagnostics rather than coerced.

Breaking corrections use a new version or explicit correction event; backfill
creates traceable derived facts and never impersonates original occurrence time.

`SILENT_SEMANTIC_CHANGE: FORBIDDEN`

