# Merchant App Implementation Sequence

Status: **PROPOSED — NO IMPLEMENTATION**
Wave: 17 / WP95

1. Resolve nine P0 root decisions and confirm V1/anti-scope.
2. Freeze versioned Customer/Merchant/backend contracts and environment boundaries.
3. Design/review migrations, RLS, RPC, grants and rollback in isolated branches.
4. Create separate app skeleton, config contract, CI/static/security gates.
5. Implement auth, merchant membership, active shop and server authorization.
6. Implement onboarding, shop profile/location/lifecycle and policy states.
7. Implement catalog search, listing, price/availability, candidate/exception.
8. Implement QR camera, minimized validation, atomic confirmation and reconciliation.
9. Add action inbox, basic dashboard/analytics and read/report reviews as approved.
10. Run contract, adversarial, two-device, release and pilot operational acceptance.

## Sequencing rule

UI work may prototype against fixtures, but no feature is integrated ahead of its authorization/data contract. QR physical acceptance cannot be closed by mock/backend tests. Future engines begin only after separate owner approval.
