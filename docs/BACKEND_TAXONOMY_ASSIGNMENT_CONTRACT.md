# Backend Taxonomy Assignment Contract

**State:** PROPOSED — STABLE NODE ID REQUIRED BEFORE FUTURE MUTATIONS

Canonical product taxonomy assignment references an immutable node identity plus
the applicable taxonomy/rule version. Display name/path is mutable presentation.

## Rules

- active sellable product is assigned to an allowed product node, normally a leaf
  under the approved variable-depth model;
- facets/brands/compatibility values are not categories;
- merchant listing cannot override canonical assignment;
- candidate may propose an assignment with provenance, never self-approve it;
- policy-sensitive categories carry separate eligibility, not hidden in the name;
- historical events may snapshot display path but retain node ID/version.

Current category FK remains active. Multi-assignment, primary assignment and
version rollout are `OWNER_DECISION_REQUIRED`; recommendation is one primary
canonical placement plus explicit cross-discovery aliases, not duplicate products.

