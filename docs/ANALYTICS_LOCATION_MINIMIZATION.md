# EsnaftaVar Analytics Location Minimization

**State:** `PROPOSED — NO PRECISE LOCATION RETENTION`

Nearby discovery may transiently use customer location, but analytics does not
automatically inherit that purpose.

Recommended hierarchy:

1. record permission/capability result without coordinates;
2. for feature quality, prefer distance/result-count bands;
3. if geography is essential, use an approved coarse area/cell with minimum
   population and short retention;
4. for directions, record destination shop and source context, not origin;
5. never build movement trails, home/work inference or merchant-visible visitor
   maps from customer location.

Do not store precise lat/lon, timestamped route, exact address or raw map-provider
payload in general events. Guest/authenticated identity is not joined with coarse
location by default. Small-area metrics are suppressed when cohorts are too small.

Precision, coarse-cell size, retention and consent/legal basis remain owner/policy
decisions. A directions request is intent only.

`PRECISE_LOCATION_RETENTION: NO`

