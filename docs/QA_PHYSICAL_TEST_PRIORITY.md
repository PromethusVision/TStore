# Physical Test Priority

**State:** EVIDENCE-RANKED PROPOSAL

| Rank | Check | Why physical | Pilot status |
|---:|---|---|---|
| 1 | Customer + merchant two-device QR | real camera, independent sessions, server race/shop binding | MUST |
| 2 | Exact signed Android clean/upgrade install | signature, package, release config, persistence | MUST |
| 3 | Confirmation/recovery email and cold/warm callback | provider/browser/OS/allowlist integration | MUST |
| 4 | Real GPS and permission lifecycle | OS service/permission/hardware behavior | MUST |
| 5 | Background/resume + Wi-Fi/mobile switching | native lifecycle and transport transitions | MUST |
| 6 | Camera denied/denied forever/recovery | OS permission and scanner resource handling | MUST |
| 7 | Low-end/small screen + large text/accessibility | rendering, focus, usability | MUST focused |
| 8 | Notification foreground/background/tap | only if notification pilot scope enabled | CONDITIONAL |
| 9 | iOS archive/TestFlight/device matrix | cannot be proven on Windows | CONDITIONAL on iOS |
| 10 | Broad manufacturer/tablet fleet | diminishing pilot return | DEFER |

Mocks remain valuable for edge-state breadth but cannot replace ranks 1–7. Production smoke is not the place for adversarial physical testing.
