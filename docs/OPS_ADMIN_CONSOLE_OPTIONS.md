# Admin Console Options

**State:** OPTIONS — NO UI/FRAMEWORK DECISION

| Option | Strengths | Weaknesses | Proposed role |
|---|---|---|---|
| Flutter Web | shared skills/design, one client stack | admin-specific density/security/session needs; bundle surface | viable if isolated app/config |
| Internal web app | purpose-built tables/queues/accessibility | separate stack/maintenance | strong candidate |
| Supabase Dashboard/manual ops | immediate inspection | broad DB access, arbitrary edits, weak workflow/audit | emergency/read-only diagnostic only |
| Custom lightweight admin | narrow features, exact server contract | still requires secure development/hosting | preferred shape after owner decisions |
| External admin/ticket tool | mature queues/forms | data/vendor/permission coupling | communication adjunct, not policy authority |

## Non-negotiables

Separate operator authentication/profile, strong authorization per request, environment isolation, no service-role/client secret exposure, field-level minimization, re-auth for high risk, audit of view/action/export, safe session timeout, accessibility, version/conflict handling, impact preview, reason/evidence, and kill-switch separation.

## Recommendation

Choose architecture only after owner closes capability/role/action scope. A small internal web or isolated Flutter Web console can both work; server APIs/RLS/RPC remain authoritative. Do not expose admin routes inside the customer/merchant app or rely on hidden UI.

## Pilot

Start with queues, case detail, safe search, evidence reference, decision reason, audit timeline, and a tiny approved action set. Avoid dashboard sprawl and generic CRUD.

`ADMIN_CONSOLE_SELECTED: NO`

`SUPABASE_DASHBOARD_ROUTINE_ADMIN: NO`
