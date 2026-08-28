# Backend Media Write Authority

**State:** PROPOSED — CURRENT CLIENT WRITES REMAIN DENIED

| Media | Proposed writer | Required scope |
|---|---|---|
| Canonical product | trusted catalog/operations | product case/capability/provenance |
| Category/banner | trusted platform operations | exact entity and content policy |
| Shop listing | future merchant server contract | active membership + exact shop/listing capability |
| Avatar | future customer contract | own user namespace + privacy policy |
| Review image | future review contract | review author + active review/media policy |

Upload is a two-phase controlled operation: authorize target/path constraints,
upload/scan/verify, then atomically attach an approved object version. A raw object
upload never makes media active. Delete/replace is governed by reference and
retention checks.

Clients never receive service/admin credentials or bucket-wide delete/list. Path
prefix alone is insufficient: server resolves the linked database entity and
capability. Avatar/review buckets and all client upload flows remain deferred and
`OWNER_DECISION_REQUIRED`.

