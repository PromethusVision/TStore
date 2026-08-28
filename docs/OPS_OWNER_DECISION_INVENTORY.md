# Operations Owner Decision Inventory

State: OPEN — NO OWNER SELECTION RECORDED

## Method

Priority reflects architectural blast radius: P0 changes authority, irreversible history, regulated operation or incident containment; P1 changes cross-domain workflow and future implementation; P2 changes operational detail. `RECOMMENDED` is research guidance, not a final Product Owner decision.

## P0 decisions

| ID | Question | Options | Recommended | Why / systems | State |
|---|---|---|---|---|---|
| OD-001 | What is the minimum operator role set? | six proposed roles / fewer combined roles / more specialist roles | keep six role families; combine assignments only in pilot | avoids role explosion while separating policy and catalog authority; identity, permissions | OPEN |
| OD-002 | Which actions require two-person review? | none / all sensitive / enumerated highest-risk actions | enumerate permanent suspension, verified-history correction, destructive merge/split, broad kill switch and exceptional bulk actions | targets irreversible/high-blast-radius risk; enforcement, QR, catalog, incidents | OPEN |
| OD-003 | How is emergency break-glass access controlled? | no break glass / unrestricted super-admin / scoped time-limited grant | scoped, reasoned, strongly re-authenticated, expiring and retrospectively reviewed | balances containment with accountability; security, monitoring | OPEN |
| OD-004 | What dependencies does merchant suspension disable? | shop only / all dependent writes / case-by-case | versioned dependency plan covering shops, listings, QR, ads and sensitive staff capabilities | prevents orphan activity; merchant, QR, ads | OPEN |
| OD-005 | Can verified purchases be corrected operationally? | never / direct edit / superseding correction after high-risk review | superseding correction only; never silent erase | preserves review/reputation evidence; QR, reviews, analytics | OPEN |
| OD-006 | Who may authorize canonical product merge and split? | catalog reviewer / policy reviewer / dual review by risk | catalog authority with second review for destructive or ambiguous operations | protects stable identity and references; catalog, taxonomy | OPEN |
| OD-007 | Who owns regulated merchant and product policy decisions? | general moderator / named policy owner / external legal only | named internal policy authority with legal review for flagged classes | taxonomy is not permission; verification, listing, ads | OPEN_LEGAL_REVIEW |
| OD-008 | What strong-auth and re-auth controls apply to operators? | password only / MFA all / risk-based strong auth | strong auth for every operator and fresh re-auth for enumerated high-risk actions | privileged account compromise is P0; identity, all commands | OPEN |
| OD-009 | Must high-risk action fail when audit cannot be recorded? | proceed and backfill / queue action / fail closed | fail closed except separately designed safety containment path | prevents unaudited power; audit, incidents | OPEN |
| OD-010 | Who can activate feature kill switches? | any operator / super-admin only / scoped dual-authority model | capability-scoped authority, dual approval for broad switches, automatic expiry | limits misuse while enabling containment; runtime domains | OPEN |
| OD-011 | Are arbitrary manual Production database edits allowed for routine operations? | allowed / ticketed exceptions / prohibited | prohibit routine edits; use typed case-bound commands, with separately governed emergency procedure | preserves auth, audit and invariants; all domains | OPEN |
| OD-012 | What privacy-incident notification process applies? | ad hoc / fixed automatic notification / assessed documented workflow | immediate containment plus documented legal/policy assessment against applicable requirements | avoids missed duty and premature disclosure; privacy, security | OPEN_LEGAL_REVIEW |
| OD-013 | What enforcement ladder and permanent restriction rule applies? | warning-first always / risk-based ladder / direct permanent action | risk-based ladder with emergency containment and independent review for permanent restrictions | proportionality and false-positive control; moderation | OPEN_POLICY_REVIEW |
| OD-014 | Which appeals require an independent reviewer? | none / all / high-risk and conflicted cases | all P0/permanent actions and any conflict; risk-based for others | reduces confirmation bias; appeals, quality | OPEN |

## P1 decisions

| ID | Question | Options | Recommended | Why / systems | State |
|---|---|---|---|---|---|
| OD-015 | Which case lifecycle states are canonical? | proposed nine / reduced / domain-specific states | one lean shared lifecycle plus domain decisions | consistent queues without forcing enforcement into case status; cases | OPEN |
| OD-016 | Which evidence types and integrity metadata are accepted? | free text / typed evidence / typed plus provenance controls | typed evidence with source, capture time, integrity/access state | explainability and minimization; all reviews | OPEN |
| OD-017 | How often are merchant verifications rechecked? | fixed universal / risk-tiered / event-only | risk-tiered plus event-triggered recheck; exact periods pending policy | avoids one-size-fits-all expiry; verification | OPEN_POLICY_REVIEW |
| OD-018 | How does support verify customer ownership? | knowledge questions / canonical session/recovery / manual documents | session-bound proof and canonical recovery; no password or OTP | prevents social engineering; support, auth | OPEN |
| OD-019 | How does support verify merchant authority? | caller assertion / account membership / membership plus high-risk step-up | active org/shop membership plus step-up for sensitive changes | tenant isolation; merchant support | OPEN |
| OD-020 | What identity bar applies to export, deletion and correction requests? | current session / fresh step-up / manual review always | risk-based step-up, case workflow and no password | protects data requests; privacy, auth | OPEN_POLICY_REVIEW |
| OD-021 | When may advertising review be automated? | never / score threshold / only exact deterministic gates | deterministic eligibility gates; suspicious traffic remains reviewable | ads proposal is not yet runtime-final; ads | OPEN |
| OD-022 | How are invalid-traffic signals used? | automatic punishment / metrics exclusion only / hold plus review | dedupe/exclude measurement where deterministic; enforcement needs evidence review | avoids opaque punishment; ads, fraud | OPEN |
| OD-023 | When may future reward-abuse controls affect balances or reputation? | automatic score / manual edit / source-event adjudication | source-event adjudication with superseding corrections; feature remains disabled until approved | reward source is unavailable and runtime deferred; rewards | OPEN |
| OD-024 | What public and internal decision-reason taxonomy is used? | free text / one shared code / paired public/internal codes | paired structured codes plus safe explanation | consistency without abuse-signal leakage; support, moderation | OPEN |
| OD-025 | How do policy changes affect existing listings/campaigns? | immediate retroactive / grandfather all / versioned transition | impact analysis with explicit transition per policy change | prevents silent inconsistent enforcement; policy, listing, ads | OPEN_POLICY_REVIEW |
| OD-026 | What retention schedules apply to cases, evidence and audit? | one period / object-risk tiers / indefinite | object/purpose/risk-specific schedules with legal review and holds | minimization versus accountability; privacy, audit | OPEN_LEGAL_REVIEW |
| OD-027 | What internal response targets and escalation clocks apply? | contractual SLA / no targets / risk-tier targets | internal non-contractual targets measured by risk and waiting state | supports lean capacity planning; queues | OPEN |
| OD-028 | Which admin/support tooling path should pilot use? | Supabase/manual / external ticketing / lightweight internal/hybrid | lightweight case-bound console, optionally hybrid for inbound tickets; no arbitrary DB ops | least privileged lean start; tooling | OPEN |

## P2 decisions

| ID | Question | Options | Recommended | Why / systems | State |
|---|---|---|---|---|---|
| OD-029 | Which inbound support channels launch in pilot? | in-app / email / WhatsApp / web form / combination | one traceable in-app or web intake plus email fallback | minimizes fragmented identity/evidence; support | OPEN |
| OD-030 | Which pilot staffing arrangement is used? | owner-operated / one operator / partial outsource / automation-first | measure workload before choosing; preserve named accountability | no hiring decision in this design; staffing | OPEN |
| OD-031 | What quality sample rates and calibration cadence apply? | fixed / risk-weighted / ad hoc | risk-weighted sample including all P0 actions; exact rates later | focuses scarce review effort; quality | OPEN |
| OD-032 | Which dashboard metrics are visible? | volume only / productivity rankings / queue-risk-quality set | queue age, severity, reopen, reversal and health; no operator league tables | avoids vanity and surveillance; analytics | OPEN |
| OD-033 | What admin search modes are permitted? | broad text / exact identifiers / role-specific modes | exact case/entity identifiers and purpose-scoped role modes | minimizes PII exposure; search | OPEN |
| OD-034 | Which customer and merchant report categories launch? | free text / proposed taxonomies / minimal shared list | minimal structured domain lists with free-text context | routing without confusing product taxonomy; reports | OPEN |
| OD-035 | How are likely duplicate cases presented? | auto-merge / suggestion / no detection | explainable link suggestion; operator confirms relationships | avoids silent loss; cases | OPEN |
| OD-036 | What structured internal-note templates are required? | free text / strict fields / hybrid | structured findings/reasons with limited contextual note | quality and privacy balance; cases | OPEN |

## Counts

| Priority | Decisions |
|---|---:|
| P0 | 14 |
| P1 | 14 |
| P2 | 8 |
| **Total** | **36** |

No option is selected in this document. `OPEN_LEGAL_REVIEW` and `OPEN_POLICY_REVIEW` are fail-closed dependencies, not legal conclusions.
