# Customer App Legacy and Dead-code Audit

Status: PASS — broad deletion intentionally avoided

| Area | Confidence | Classification | Decision |
| --- | --- | --- | --- |
| `features/orders` and legacy order views/widgets | HIGH | LEGACY, unreachable | Keep isolated pending schema/data deprecation plan. |
| Postal address prototype views/forms/models | HIGH | DEAD_CANDIDATE | Not shipped; separate cleanup can remove after DI/domain impact review. |
| Address repository/use cases/Cubit registrations | MEDIUM | LIKELY DEAD | Retained because backend/account-cleanup compatibility may still matter. |
| Profile avatar repository methods | HIGH for UI unreachability | DORMANT CAPABILITY | Do not expose; deferred bucket/policy decision required. |
| `DioClient`/interceptor and old HTTP client | HIGH | DEAD_CANDIDATE | Sanitized defensively; removal deferred to dependency cleanup. |
| Old `LocationHelper`/platform exception helpers | HIGH | DEAD_CANDIDATE | Active location uses `CustomerLocationService`; removal deferred. |
| Older Store/brand/coupon UI fragments | MEDIUM | LEGACY/FUTURE | Must not be mistaken for Customer V1 completion. |
| Chat legacy aggregate fallbacks | ACTIVE COMPATIBILITY | ACTIVE | Keep until backend compatibility decision. |
| Legacy HTTPS media resolver | ACTIVE COMPATIBILITY | ACTIVE | Required for safe historical media. |

No active import was removed. Architecture tests already protect the highest-risk legacy order boundary. A later cleanup should be one root-area at a time with dependency removal and full regression, not a bulk delete.

`LEGACY_CODE_AUDIT: PASS`
`BROAD_CLEANUP_PERFORMED: NO`
