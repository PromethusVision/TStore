# Backend Nearby Query Model

**State:** PROPOSED — NO GEO RUNTIME

Nearby discovery accepts a purpose-limited customer-provided point or approved
coarse/default area and returns active, policy-visible shops/listings within a
bounded radius/viewport.

## Distance and ordering

- calculate with a declared geographic method/unit;
- validate coordinate range and reject malformed/non-finite input;
- prefilter a bounded area before precise distance when supported;
- order by distance then stable shop ID, or an explicitly versioned relevance
  model that keeps distance explainable;
- cursor binds query origin precision, radius, filters and order version;
- inactive shops/listings and missing coordinates fail safe;
- cap radius/page size and prevent unrestricted world scraping.

## Privacy

Exact customer coordinates are request inputs, not retained profile/history by
default. Logs/events use no coordinate or an approved coarse cell. Saved locations
remain customer-private and are never exposed to merchants. Shop coordinates are
public only at the approved precision.

The demo `NEIGHBORHOOD_CENTER` coordinates support functional distance behavior
but are not exact addresses. Precision, maximum radius and personalized retention
are `OWNER_DECISION_REQUIRED` with privacy review.
