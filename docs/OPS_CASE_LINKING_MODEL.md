# Operations Case Linking Model

**State:** PROPOSED — NO CASE GRAPH IMPLEMENTATION

## Link types

| Link | Meaning |
|---|---|
| DUPLICATE_OF | same underlying report/decision scope |
| RELATED_TO | relevant context, separate case outcome |
| PARENT_INCIDENT / CHILD_OF | case contributes to systemic incident |
| APPEAL_OF | reconsideration of exact decision |
| EVIDENCE_SHARED_WITH | authorized common evidence reference |
| PRECEDES / CAUSED_BY | temporal/causal hypothesis with confidence |
| SUPERSEDES | newer governed case/decision replaces operational effect |
| SAME_SUBJECT | common subject only; no guilt inference |

Links are typed, directed where necessary, versioned, reasoned, and audited.

## Rules

Linking does not merge reporter identity, evidence access, severity, retention, or decision. Authorization is evaluated on each case/evidence; a link does not grant access. Causal links are hypotheses until supported. Removing a mistaken link creates history.

## Use cases

Multiple customer reports about one listing; merchant suspension and dependent ads; catalog candidate and dedup/merge; QR fraud cluster and verified correction; security incident and account cases; policy change and affected listing/campaign reviews; original decision and appeal.

## Display

Show link type, safe subject summary, status/severity, why linked, confidence/source, and access-redacted state. Avoid graph sprawl and guilt-by-association.

`CASE_LINKING_FINAL: NO`

`LINK_EQUALS_SHARED_ACCESS: NO`
