# Merchant App Flutter Architecture Options

Status: **PROPOSED — OWNER/ENGINEERING DECISION REQUIRED**
Wave: 17 / WP76

## Options

| Option | Benefit | Risk |
|---|---|---|
| A — Separate Flutter project, selective packages | Independent release/security/navigation; explicit sharing | Package setup and version coordination |
| B — One Flutter workspace with app targets | Easier shared tooling | Accidental customer/merchant coupling and bundle leakage |
| C — Web dashboard first | Fast desktop operations, easy support | Camera/physical QR and local-device acceptance weaker |

## Recommendation

Option A: separate Merchant App project/release identity with intentionally shared, platform-neutral packages for tokens and versioned API/domain contracts. Recommendation is not owner-final.

## Boundaries

- Do not share navigation, auth screen state, customer Cubits or feature repositories by default.
- Shared contract models must not contain environment secrets or app-specific UI assumptions.
- Merchant app has independent production/development config contract and signing/release gates.
- QR camera, deep links and staff security require separate physical acceptance.

## Open decision

`ARCH-01 P1`: Native mobile-first separate app vs web-first pilot. Evaluate QR frequency, merchant device use and support burden before finalizing.
