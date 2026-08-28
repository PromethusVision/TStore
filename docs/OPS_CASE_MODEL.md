# Operations Case Model

**State:** PROPOSED — NO DATABASE DESIGN

## Core concepts

| Concept | Contract |
|---|---|
| CASE | Immutable opaque ID, case type, source, created time, current status/severity/priority, policy version |
| SUBJECT | One primary customer, merchant, shop, product, listing, review, QR transaction, campaign, reward event, or incident |
| REPORTER | Customer/merchant/system/operator source; identity minimized and protected from the subject |
| ASSIGNEE | Active operator/team assignment with purpose and time bounds |
| CATEGORY | Operations report type, not Product or Merchant Taxonomy |
| SEVERITY | Harm/impact if true |
| STATUS | Workflow state, independent from subject enforcement state |
| EVIDENCE | Typed immutable/reference evidence with provenance and access class |
| DECISION | Outcome, reason, policy version, effective time, impact, approver |
| APPEAL | Linked reconsideration with independent reviewer where possible |
| HISTORY | Append-only case/status/assignment/evidence/decision events |

## Relationships

A case has exactly one primary subject and may link secondary subjects or related cases. Several reports may deduplicate into one case without merging reporter identities. One subject may have multiple independent cases over time. Closing a case does not delete its evidence or silently restore/restrict the subject.

## Minimal fields

- case ID, type, source, status, severity, priority;
- primary subject type/opaque ID;
- reporter class and protected reporter reference if needed;
- assigned queue/operator;
- created/updated/target timestamps;
- policy/rule version;
- evidence and related-case references;
- current decision/reason/appeal state;
- access sensitivity and retention class.

## Safety

Case notes are not authoritative product facts. Enforcement state changes only through dedicated server actions linked to a decision. Reporter identity is hidden unless strictly necessary. Large payloads/media/logs are referenced, not duplicated. Cases do not store passwords, tokens, raw payment secrets, or unrestricted private messages.

## Open decisions

- report anonymity and reporter follow-up rules;
- duplicate-report consolidation threshold;
- appeal independence at one-person scale;
- exact retention classes;
- which system signals auto-create versus only suggest a case.

`CASE_MODEL_READY_FOR_OWNER_REVIEW: YES`

`CASE_SCHEMA_CREATED: NO`
