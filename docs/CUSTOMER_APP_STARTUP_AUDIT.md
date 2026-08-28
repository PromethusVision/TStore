# Customer App Startup Audit

Status: PASS WITH EXTERNAL CONFIGURATION REQUIREMENT

## Verified sequence

1. Platform bindings initialize.
2. The selected entrypoint builds a namespaced, validated Supabase configuration.
3. `SupabaseService.initialize` completes before dependency injection.
4. `setupServiceLocator` completes before `runApp`.
5. `TStore` composes global Auth/recovery/session listeners and the launch gate.
6. Launch status displays a branded loading surface, then onboarding or Home.

## Failure behavior

- Missing, placeholder, malformed, cross-environment, or server-only configuration throws a value-free `SupabaseConfigurationException` before remote initialization.
- There is no Development-to-Production or Production-to-Development fallback.
- Local onboarding preference read failure does not block public product discovery.
- An authenticated customer is not blocked if local onboarding persistence fails.
- Startup Auth callbacks can be consumed after navigator readiness.

The bootstrap does not currently present a bespoke Flutter error screen for invalid compile-time backend configuration because failure occurs before `runApp`. This is deliberate fail-closed release behavior and is preferable to silently reaching the wrong backend. Release tooling must supply and validate the client-safe contract before distribution.

## Release/debug checks

- Debug banner is disabled.
- Runtime does not load a committed `.env` asset.
- No debug-only backend fallback was found.
- Global state is initialized only after Supabase and DI.
- Root application tests cover loading, onboarding, Home, Auth callback, and session transitions.

`STARTUP_AUDIT: PASS`
`HIDDEN_BACKEND_FALLBACK: NO`
`STARTUP_REMOTE_WRITE: NO`
