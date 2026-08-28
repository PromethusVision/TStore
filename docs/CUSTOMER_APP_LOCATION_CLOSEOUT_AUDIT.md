# Customer App Location Closeout Audit

Status: PASS WITH OWNER POLICY DECISION

## State matrix

| State | Customer behavior | Result |
| --- | --- | --- |
| Valid primary saved location | Used without requesting device permission; source is disclosed | PASS |
| Permission not determined | Explanation precedes the Android/iOS dialog | PASS |
| Permission granted | Current position is requested with a bounded timeout | PASS |
| Permission denied | Shops stay visible; safe guidance is shown | PASS |
| Permission denied forever | App settings action is offered | PASS |
| Device location service disabled | Location settings action is offered | PASS |
| Return from settings | Permission/service state is refreshed | PASS |
| Timeout/unavailable/platform exception | Safe Turkish result; no crash or technical detail | PASS |
| Invalid coordinate | Rejected before distance calculation | PASS |
| Slow/late result | Disposed view and superseded-request guards prevent stale state | PASS |

Nearby initially loads public shops without asking for location. Location access is explicit, shops remain usable without permission, and exact coordinates are not logged or displayed as account data. Distance sorting preserves stable source order when location is unavailable and does not invent a minimum distance.

The Geolocator service and Nearby Cubit have focused tests for permission transitions, service state, timeout, settings, invalid coordinates, request coalescing, stale response suppression, and close lifecycle. Prior signed-device acceptance covers a real Android permission dialog and acquisition; Wave 16 does not replay physical GPS.

## Open policy decision

Current runtime allows guest Nearby/current-device sorting, while saved locations are authenticated. Wave 16 wording suggests login-gating personalization only if canonical evidence establishes that rule. No conclusive owner-final rule was found. Do not change the shipped guest discovery contract without owner confirmation.

`LOCATION_CLOSEOUT_AUDIT: PASS`  
`FAKE_GPS_USED: NO`  
`OWNER_DECISION_REQUIRED: NEARBY_GUEST_POLICY`
