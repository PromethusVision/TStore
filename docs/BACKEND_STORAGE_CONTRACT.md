# Backend Storage Contract

**State:** PRESERVES CANONICAL WAVE 6/0009 CONTRACT

## Active buckets

| Bucket | Read | Client write | Limit | MIME |
|---|---|---|---|---|
| `product-images` | public object | denied | 8 MiB | JPEG, PNG, WebP |
| `category-images` | public object | denied | 2 MiB | JPEG, PNG, WebP |
| `banner-images` | public object | denied | 5 MiB | JPEG, PNG, WebP |

Object listing and anon/authenticated insert/update/delete remain denied. Trusted
operations provisioning uses canonical versioned paths; no server credential is
placed in Flutter/assets. `brand-logos`, `avatars` and `review-images` remain
deferred.

## Invariants

- database identity/ownership, not path text or public URL, authorizes mutation;
- allowlisted bucket, lowercase controlled path, MIME and size are server checked;
- signed/public URL is presentation, never stable media identity;
- replacement uploads new version, verifies it, then atomically switches owning
  pointer;
- prior/unreferenced object remains at least seven days before trusted cleanup;
- media failure never changes product/purchase/review identity.

Any merchant upload path requires separate capability policies and migration.

