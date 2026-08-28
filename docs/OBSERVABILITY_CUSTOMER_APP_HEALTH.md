# EsnaftaVar Customer App Health

**State:** `PROPOSED SIGNAL INVENTORY`

| Journey | Signals | Segment by |
|---|---|---|
| Startup | start success/failure, time-to-first-usable-view, fatal crash | release/platform/environment |
| Auth | attempt outcome, bounded reason, latency, session refresh failure | release/method/environment |
| Discovery/search | request success, zero/error distinction, latency, stale response suppression | endpoint/index/release |
| Product/shop/storage | details/RPC/image fetch success and latency | media type/endpoint/release |
| Cart V2/favorites | authoritative mutation success/latency/conflict | operation/release |
| Chat/notifications | subscription/RPC/delivery lifecycle errors | transport/release; no content |
| QR/customer side | issue/render/expiry outcome | release; no raw QR |

Crash-free starts/sessions, if used, require a defined session and reporting tool.
Alerts prioritize startup/auth and critical RPC failures. Search “no result” is a
product-quality fact, not a technical error unless the request failed.

Payloads contain no customer contact, private messages, raw query, token, precise
location or full URL. Release/environment attribution is mandatory.

`CUSTOMER_HEALTH_RUNTIME: NOT_IMPLEMENTED`
