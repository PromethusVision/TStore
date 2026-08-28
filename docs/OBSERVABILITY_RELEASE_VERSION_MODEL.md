# EsnaftaVar Observability Release Version Model

**State:** `PROPOSED`

Every app/backend health signal should carry, where applicable:

- application/service identity;
- semantic app version plus immutable build number/commit identifier;
- platform/OS and distribution channel;
- environment;
- schema/migration/API version when relevant;
- feature/config/model version only when it changes behavior.

Release values are bounded deploy metadata, not user input. Development builds do
not share Production release series. Crash symbols and source maps must match the
exact artifact and be uploaded through a secret-safe release process.

Dashboards compare current versus prior release with traffic minimums. Rollback is
a new deployment state, not deletion of failure evidence. A backend error with an
unknown client release is retained in an explicit unknown bucket rather than
guessed.

`RELEASE_DIMENSION_REQUIRED: YES`
