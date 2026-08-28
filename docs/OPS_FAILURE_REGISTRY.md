# Operations Failure Registry

State: DESIGN STRESS FINDINGS — PROPOSED FOR OWNER REVIEW

## Interpretation

These are failure modes exposed by the 4,400 synthetic cases. They are not claims that current runtime produced 4,400 incidents. A row is closed only when a future server-authoritative implementation, policy decision and acceptance test all prove the control.

## Registry

| ID | Priority | Failure mode | Stress evidence | Root control | State |
|---|---|---|---|---|---|
| OPS-F001 | P0 | Privileged action trusts admin UI or role label instead of server authorization | mixed, operator-error, merchant moderation | capability + tenant + lifecycle authorization on every command | DESIGN_REQUIRED |
| OPS-F002 | P0 | High-risk action succeeds when audit append fails | security, operator-error, mixed | fail command closed; durable append-only audit | DESIGN_REQUIRED |
| OPS-F003 | P0 | Wrong subject or overbroad bulk scope is acted on | operator-error, privacy | preview, exact identifiers, limits and second review | DESIGN_REQUIRED |
| OPS-F004 | P0 | QR confirmation is replayed or two confirmations both succeed | QR, mixed | atomic idempotent server transition | DESIGN_REQUIRED |
| OPS-F005 | P0 | Account, token or operator compromise retains active authority | security, merchant moderation | scoped revocation, containment and reauthorization | DESIGN_REQUIRED |
| OPS-F006 | P0 | Secrets or personal data enter logs, exports or unsafe evidence | privacy, security, support | denylist/redaction, purpose access and breach response | DESIGN_REQUIRED |
| OPS-F007 | P0 | Verified purchase, audit or canonical history is silently deleted | QR, catalog, operator-error | immutable events and superseding corrections | DESIGN_REQUIRED |
| OPS-F008 | P0 | Merchant suspension leaves listing, QR or advertising authority active | merchant moderation, mixed | versioned dependency plan and safe restoration | DESIGN_REQUIRED |
| OPS-F009 | P0 | Routine operations rely on arbitrary Production SQL or row edits | operator-error, mixed | typed case-bound server commands | DESIGN_REQUIRED |
| OPS-F010 | P0 | Critical feature cannot be disabled safely or kill switch is misused | operator-error, mixed | scoped server switch, expiry, reason and dual control | OWNER_DECISION_OPEN |
| OPS-F011 | P1 | Regulated product or merchant is approved with missing/expired evidence | policy, merchant moderation | fail-closed policy and verification queues | POLICY_REVIEW_OPEN |
| OPS-F012 | P1 | Different policy versions produce incompatible decisions | policy, mixed, appeals | effective version pin and transition plan | OWNER_DECISION_OPEN |
| OPS-F013 | P1 | Product merge loses listings, reviews, verified history or aliases | catalog, mixed | stable IDs and predecessor/successor graph | DESIGN_REQUIRED |
| OPS-F014 | P1 | Ambiguous product split points legacy identity to an arbitrary child | catalog, operator-error | manual classification or deterministic split rule | OWNER_DECISION_OPEN |
| OPS-F015 | P1 | Invalid advertising traffic changes metrics or enforcement automatically | ads, mixed | deduped events, hold state and explainable review | OWNER_DECISION_OPEN |
| OPS-F016 | P1 | Staff or operator acts outside shop/case scope | merchant moderation, privacy | least privilege and assignment-aware access | DESIGN_REQUIRED |
| OPS-F017 | P1 | Appeal reviewer is conflicted or original record is missing | appeals, operator-error | independent review and remand path | OWNER_DECISION_OPEN |
| OPS-F018 | P1 | Repeat-abuse signal becomes an opaque automatic punitive score | merchant moderation, ads | human review, explainable linked evidence | POLICY_REVIEW_OPEN |
| OPS-F019 | P1 | Review correction manipulates rating or verified eligibility | support, merchant moderation, mixed | source-event review; no direct score edit | DESIGN_REQUIRED |
| OPS-F020 | P1 | Evidence is inaccessible, mutable or lacks provenance | catalog, policy, operator-error | typed evidence, hash/provenance and access state | DESIGN_REQUIRED |
| OPS-F021 | P1 | Privacy or security event lacks notification-duty assessment | security, privacy | incident/privacy escalation and documented assessment | POLICY_REVIEW_OPEN |
| OPS-F022 | P1 | Monitoring cannot correlate customer symptom, command and server event | security, mixed | safe correlation IDs across logs/cases | DESIGN_REQUIRED |
| OPS-F023 | P1 | Offboarded/shared operator account destroys attribution | operator-error, security | individual identity, strong auth and rapid revocation | DESIGN_REQUIRED |
| OPS-F024 | P1 | Internal notes or reporter identity leak through decision communication | privacy, appeals | channel separation and safe reason templates | DESIGN_REQUIRED |
| OPS-F025 | P2 | Duplicate reports are deleted or merged despite different subjects/reporters | support, operator-error, mixed | relationship links, not destructive collapse | DESIGN_REQUIRED |
| OPS-F026 | P2 | Name similarity alone triggers catalog merge | catalog | explainable signal thresholds and manual review | OWNER_DECISION_OPEN |
| OPS-F027 | P2 | Taxonomy placement is treated as permission to list or advertise | catalog, policy, ads | independent policy eligibility | POLICY_REVIEW_OPEN |
| OPS-F028 | P2 | Missing measurement is converted to zero or invented ad performance | ads | explicit unknown state and event integrity | OWNER_DECISION_OPEN |
| OPS-F029 | P2 | Support collects passwords or unnecessary identity evidence | support, privacy | canonical recovery and minimum verification | DESIGN_REQUIRED |
| OPS-F030 | P2 | Appeal or rejection reason exposes abuse-detection methods | appeals, policy | public reason code separated from internal rationale | POLICY_REVIEW_OPEN |
| OPS-F031 | P3 | Incident-driven duplicate contacts overload queues and hide one root cause | support, mixed | incident/case linking and safe status communication | DESIGN_REQUIRED |
| OPS-F032 | P3 | Queue and quality metrics incentivize speed over correct decisions | support, quality | risk-weighted review without operator quotas | OWNER_DECISION_OPEN |

## Counts

| Priority | Failure modes |
|---|---:|
| P0 | 10 |
| P1 | 14 |
| P2 | 6 |
| P3 | 2 |
| **Total** | **32** |

## Release interpretation

P0 and P1 items are foundation gates for the affected capability, not a declaration that every future feature must ship at once. Deferred ads and rewards remain disabled rather than inheriting incomplete controls. Policy/legal review items remain fail-closed and no choice is finalized here.
