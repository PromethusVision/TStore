# Release Changelog Model

**State:** PROPOSED

## Internal changelog entry

For each version/build record date, commit range, user-visible changes, backend/migration requirements, security/privacy changes, fixed defects, deferred flags, compatibility, rollout/rollback notes and evidence links.

## Categories

`Added`, `Changed`, `Fixed`, `Security`, `Data/Migration`, `Operational`, `Deprecated`, `Removed` and `Known limitations`. Generated Git subjects are inputs, not final changelog copy.

## Rules

- Describe behavior, not credentials, internal abuse signals or sensitive incident detail.
- Separate implemented changes from owner-review proposals.
- Link migration and artifact IDs rather than pasting SQL/config.
- Corrections append a note; published history is not silently rewritten.
- Customer App and Merchant App entries identify cross-app/backend dependency.

## Relationship

The changelog is engineering/operations history. Store-facing release notes are shorter, customer-safe and localized. Neither substitutes for the release checklist or approval record.

`OWNER_DECISION_REQUIRED: CHANGELOG_LOCATION_AND_OWNER`
