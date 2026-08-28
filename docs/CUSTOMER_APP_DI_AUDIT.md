# Customer App Dependency Injection Audit

Status: PASS WITH ISOLATED LEGACY REGISTRATIONS

## Registration policy observed

- Supabase service, repositories, local storage adapters, and use cases: lazy singleton.
- Cubits: factory, including Auth; application shell owns the instances it requests.
- Location service: lazy singleton with no customer data cache beyond platform service behavior.
- No Development/Production-specific repository graph exists; the already initialized validated `SupabaseService.instance` is injected.

No duplicate registration or singleton Cubit was found. Active repositories resolve from interfaces, and route-local Cubits receive fresh instances.

## Non-customer/legacy registrations

- Address repository/use cases/`AddressesCubit` are registered although the postal-address views are unreachable.
- Shop create/update and verifier QR dependencies coexist in the shared codebase but do not constitute a completed Merchant App.
- Legacy `orders` is correctly absent from service locator wiring.

Removing the postal/merchant-capability registrations would be a cleanup/refactor with shared composition-root conflict risk and no current functional benefit. They remain classified `LEGACY/UNCLEAR`; no broad DI rewrite was made.

`DI_AUDIT: PASS`
`DUPLICATE_REGISTRATION: NO`
`LEGACY_ORDER_WIRING: NO`
