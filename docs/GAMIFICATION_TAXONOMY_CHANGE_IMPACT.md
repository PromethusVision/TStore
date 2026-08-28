# Gamification Taxonomy Change Impact

**State:** PROPOSED — NO TAXONOMY RUNTIME CHANGE

Category-explorer badges/challenges are the primary taxonomy-dependent risk. They must use stable category IDs, versioned lineage and the policy snapshot valid at event evaluation—not a mutable Turkish name/path.

| Taxonomy change | Safe derived behavior |
|---|---|
| Rename | Display current name; historical event remains bound to stable ID/version; no new progress. |
| Move | No new explorer credit merely because ancestors changed; recompute presentation separately. |
| Split | No automatic multi-credit; map only with deterministic product/category lineage or hold ambiguous history. |
| Merge | Deduplicate prior credits to one current canonical node without revoking earned history silently. |
| Retire | Preserve historical badge evidence; stop future earning; optionally retire/supersede badge definition. |

## Guardrails

- Category path/name is never an idempotency key.
- A product correction cannot manufacture a purchase, review right, reward or reputation event.
- Policy-sensitive categories remain fail closed after a move until explicit policy re-evaluation.
- Badge explanation states whether it reflects historical or current taxonomy.
- Replay stores derivation version and produces reconciliation output before public state changes.
