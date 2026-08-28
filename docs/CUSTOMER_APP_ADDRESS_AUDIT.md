# Customer App Address Audit

Status: ACTIVE SAVED LOCATIONS PASS; LEGACY POSTAL ADDRESS UI NOT ACTIVE

## Reachability finding

Two concepts exist in source:

1. `CustomerSavedLocationsView` is the active customer feature reached from Home/Profile. It stores a name, address text, coordinates, and one primary location for Nearby sorting.
2. `UserAddressesView`, `AddNewAddressesView`, the older address form/widgets, `AddressesCubit`, and address repository/use cases are not imported by active navigation. The old view renders hardcoded sample postal-address cards. They are `LEGACY/DEAD_CANDIDATE`, not a commercial customer feature.

The repository should not claim that postal-address CRUD is shipped. This is consistent with the O2O model, which has no shipping checkout. The legacy code is retained until a separate cleanup decision because DI registration and domain code alone are not proof that deletion is risk-free.

## Active saved-location behavior

- Login-gated user-owned list, create, primary selection, and delete.
- Empty/loading/error/retry states.
- Location capture is explicit and uses the permission-safe service.
- Names/address text are trimmed; invalid coordinates are rejected by the repository/service boundary.
- First location becomes primary; deleting a primary location selects the remaining first location locally, with backend ownership/RLS authoritative.
- Double add/capture/save/delete/default actions are suppressed while busy.
- Narrow-screen content is scrollable and covered.

## Decision

No shipping-address module is required for Minimal Commercial V1. If a future owner need emerges (billing, delivery, or merchant service address), define the product contract first rather than reviving the prototype.

`SAVED_LOCATION_AUDIT: PASS`
`POSTAL_ADDRESS_RUNTIME: INACTIVE`
`LEGACY_ADDRESS_CLEANUP: DEFERRED`
`MAJOR_V1_MODULE_REQUIRED: NO`
