# Customer App Session-expiry Audit

Status: PASS

- A Supabase `signedOut` event is authoritative.
- Automatic expiry clears Cart/Wishlist/navigation, removes the protected route stack, opens public customer Home, and displays “Oturumunuz sona erdi” feedback.
- User-initiated logout performs the same cleanup but avoids false expiry messaging/navigation.
- Guest `signedOut` noise remains silent.
- Same-user token refresh preserves local state.
- Recovery's controlled sign-out/fresh-login proof is marked internal so the root listener does not destroy the recovery route mid-operation.
- Repository current-session checks map an identity change/expired session to a safe re-login requirement rather than applying old results.
- Raw 401/Auth exception text is not displayed.

Local tests simulate expiry and Auth state transitions. Remote refresh-token expiration is not induced in this no-remote-write wave.

`SESSION_EXPIRY_AUDIT: PASS`
`STALE_AUTHENTICATED_UI_FOUND: NO`
