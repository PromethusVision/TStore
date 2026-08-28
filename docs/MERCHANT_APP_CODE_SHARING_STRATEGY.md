# Merchant App Code Sharing Strategy

Status: **PROPOSED — NO CODE CREATED**
Wave: 17 / WP77

## Good sharing candidates

- Versioned API DTO/contract definitions and safe serializers.
- Stable domain identifiers/value objects without app state.
- Error/result reason classes.
- Locale/currency/unit parsing utilities.
- Design tokens/accessibility primitives only if independently consumable.
- Test fixtures/contract conformance helpers without credentials.

## Do not share by default

- Navigation/router and deep-link state.
- Customer-specific Cubits/providers/repositories.
- Merchant permission/onboarding/QR operational state.
- App bootstrap/environment wiring.
- Customer UI widgets with hidden merchant branches.
- Auth session storage implementation without threat review.

## Governance

Shared packages have owners, semantic versions and consumer contract tests. A change cannot force simultaneous untested app releases. Duplicate a small app-specific abstraction when sharing would couple security or release lifecycle.
