# Merchant App RLS Requirements

Status: **PROPOSED — NO SQL/POLICY IMPLEMENTATION**
Wave: 17 / WP80

## Conceptual rules

- Auth user reads only active memberships assigned to them.
- Merchant users read/write only organizations, shops and branches in explicit scope.
- Listing writes require catalog capability and target-shop membership; canonical fields are not writable through listing policy.
- QR confirmation is through narrow server operation; raw session rows are not broadly readable.
- Staff cannot grant/update own role, capability or shop scope.
- Analytics/audit/review reports expose minimized projections, not raw cross-user events.
- Suspended/revoked/policy-blocked states override ordinary role access.

## Testing expectations

Owner, manager, verifier, catalog editor, unrelated merchant, revoked staff and anon matrices. Include forged IDs, cross-shop joins, direct-table attempts, RPC misuse, stale sessions and security-definer search-path/grant audits.

## Defense in depth

RLS, RPC/application authorization and database constraints align. Client filtering is never security. Service-role/server-only secrets stay outside Flutter.
