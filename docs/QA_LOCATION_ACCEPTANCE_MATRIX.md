# Location Acceptance Matrix

**State:** PROPOSED — REAL GPS RECHECK OPEN

| State | Expected Customer behavior | Automated evidence | Physical evidence |
|---|---|---|---|
| Permission not requested | explain purpose at point of use | widget/navigation | OS prompt timing |
| Granted precise | nearby sorted by trusted coordinate | service/Cubit | real GPS and accuracy |
| Granted approximate | usable coarse result, no false precision | mapped state | Android/iOS behavior |
| Denied once | safe fallback and retry path | widget | native dialog |
| Denied forever/restricted | settings guidance, no prompt loop | lifecycle widget | settings round trip |
| Service disabled | clear enable guidance and fallback | Cubit/widget | device setting |
| Unavailable/timeout | retain prior/saved location or error | unit/Cubit | indoor/weak GPS |
| Fake/mock signal | do not silently treat as verified merchant/customer position | policy-dependent | device/developer mode |
| Saved location | explicit label and scoped account state | repository/widget | account switch |
| Background/resume | refresh only when relevant; no duplicate navigation | lifecycle tests | physical resume |

## Privacy

Exact coordinates never enter generic logs, screenshots or analytics. Tests use synthetic coordinates and assert that logout/user switch clears scoped saved/current state. Nearby guest policy remains an owner decision and is not changed here.

`LOCATION_LOCAL_CONTRACT: EXISTING_PARTIAL`

`LOCATION_PHYSICAL_CURRENT_CANDIDATE: OPEN`
