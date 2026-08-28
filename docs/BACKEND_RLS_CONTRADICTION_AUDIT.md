# Backend RLS Contradiction Audit

**Result:** PASS — NO UNRESOLVED POLICY CONTRADICTION

| Boundary | Cross-document assertion | Resolution |
|---|---|---|
| anon discovery | active public catalog/shop/listing only | consistent across anon/customer matrices and query models |
| customer private data | own account only; no cross-user mutation | consistent across RLS, deletion and PII docs |
| merchant authorization | active membership + exact resource capability | direct owner column is a bridge, never the final capability proof |
| verifier | QR inspect/consume only for exact assigned shop | listing/catalog mutation not implied |
| operator | case/capability-scoped server command | admin UI or profile role alone never authorizes |
| server-only evidence | verified purchase, aggregates, reward/reputation facts | direct table grants are denied |
| Realtime | subscription repeats row authorization | publication membership is not a grant |
| Storage | object path/policy and domain ownership both required | public read does not grant write |
| suspended/revoked actors | deny commands/subscriptions; preserve evidence | public/customer read effects remain an owner-policy decision |

## Explicit non-contradictions

- A security-definer function may cross a row boundary only after caller, scope,
  state and search-path validation; this does not turn service role into a client.
- Public product/shop reads coexist with merchant-private draft and operational data.
- Operators may investigate evidence without receiving unrestricted direct-table
  mutation as an assumed default.
- Old clients may retain compatible reads while new Merchant writes use stricter
  capabilities; compatibility never widens RLS.

Remaining owner decisions concern visibility/retention policy, not ambiguous
authorization mechanics.

