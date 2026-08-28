# App Background / Resume Matrix

**State:** PROPOSED

| Active operation | Background event | Resume expectation |
|---|---|---|
| Auth signup/login | request pending | one completion; disposed UI not navigated |
| Confirmation/recovery | link/listener active | event processed once; correct account context |
| Home/search | read pending | stale result cannot overwrite current query/session |
| Location | permission/settings | recheck service/permission once |
| Cart mutation | request pending | authoritative cart refresh; no duplicate mutation |
| QR display | expiry timer | trusted expiry/status refresh |
| QR scanner | camera active | camera lifecycle restored safely or explicit restart |
| Review form | unsent input | documented draft behavior; no duplicate submit |
| Chat/notifications | Realtime active | old channels disposed; one scoped reconnect |
| User switch/logout | cleanup pending | old account state never flashes or mutates |

Also test inactive → paused/detached where available, process recreation, OS memory kill, rapid background/foreground cycles and route disposed before async completion.

## Evidence boundary

Widget lifecycle tests prove Flutter subscription/callback behavior. Physical devices prove native permission, camera and process behavior. Neither replaces the other.

`LIFECYCLE_RELEASE_GATE: TARGETED_PHYSICAL_RECHECK`
