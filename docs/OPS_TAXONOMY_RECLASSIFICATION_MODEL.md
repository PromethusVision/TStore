# Taxonomy Reclassification Operations

**State:** PROPOSED — NO TAXONOMY OR RUNTIME MUTATION

Reclassification changes a canonical product's primary assignable leaf under an owner-final taxonomy. It does not change product identity unless a separate merge/split decision proves identity was wrong.

## Operation types

- stable-ID-preserving rename display refresh;
- move to another owner-final leaf with unchanged product identity;
- policy-driven temporary unassignable/review state;
- legacy predecessor-to-canonical mapping;
- proposal revision requiring no runtime action until final;
- split/merge requiring dedicated operations.

## Preconditions

Owner-final target stable ID, taxonomy revision, exactly-one-primary-leaf rule, source/evidence, policy check, impact preview, descendant/search/facet compatibility, alias/history behavior, and authorized review. Proposal-only targets remain provisional and cannot become authoritative runtime assignments.

## Impact view

Show product/listing counts, search/filter/deep-link behavior, merchant entry suggestions, demo/import data, analytics/saved filters, ads, and policy implications. Category placement never grants permission to list, sell, advertise, or claim.

## Decision record

Old/new stable leaf IDs and paths as-of their revisions, product ID, reason/rule version, evidence, effective time, operator/approver, affected projection counts, unresolved references, and reversal/superseding event.

## Safety

Do not derive immutable identity from Turkish label, slug, or path. Do not bulk reclassify merchant sectors. Do not automatically move products merely because a merchant sector changed. Unknown cross-domain/policy cases remain unassigned/reviewed rather than guessed.

`TAXONOMY_RUNTIME_IMPLEMENTATION: NO`

`PROPOSAL_TREATED_AS_FINAL: NO`
