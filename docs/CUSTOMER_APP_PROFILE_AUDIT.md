# Customer App Profile Audit

Status: PASS WITH DEFERRED AVATAR CAPABILITY

## Active contract

- Authenticated profile fetch uses the current Auth user ID.
- If the trigger-created profile is temporarily missing, the repository attempts a user-scoped repair with Auth metadata; RLS remains authoritative.
- Profile update is limited to customer-editable `full_name` and `phone` fields.
- Empty updates re-fetch instead of issuing an empty mutation.
- Views do not render misleading sample identity values for partial profiles.
- Profile identity changes cause the old customer's rendered data to be replaced.
- Loading, error, retry, edit, account deletion confirmation, and narrow-width behavior have widget coverage.

## Session isolation

The root session listener clears Cart, Wishlist, and selected navigation state on logout/account change before loading the new user. Profile Cubits are route-scoped; profile-view identity change coverage protects against stale rendering. No cross-user cache was found in the profile repository.

## Avatar finding

`ProfileRepositoryImpl` retains upload/delete methods for an `avatars` Storage bucket. The current profile Cubit/UI has no discovered call site, while that bucket is explicitly deferred in the active Storage contract. Classification: `DEAD_CANDIDATE` plus `BACKEND_SCHEMA_REQUIRED` if the feature is revived. It is not removed because reachability alone does not establish owner intent, and it must not be exposed until bucket/policy/privacy decisions exist.

## Risks

- Missing-profile repair is a client write and depends on canonical RLS; current live historical evidence confirms user ownership rules. No remote verification is performed here.
- Phone validation is customer-facing and local; any future international format policy is an owner decision.

`PROFILE_AUDIT: PASS`  
`STALE_USER_PROFILE_RISK: COVERED`  
`AVATAR_RUNTIME_STATE: DEFERRED`
