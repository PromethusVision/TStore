# Case Internal Notes Model

**State:** PROPOSED — NO CASE UI/STORAGE

## Purpose

Internal notes capture review reasoning, handoff, reproduction steps, evidence gaps, and next action. They are not authoritative domain data, private gossip, or a copy of sensitive evidence.

## Note envelope

Note ID, case, author/operator, timestamp, note type, sensitivity class, structured reason/topic, text, evidence references, mentioned operator/team, edit/superseding relation, and access scope.

## Rules

- facts, hypotheses, and opinions are labeled separately;
- use opaque subject IDs/references, not unnecessary name/email/phone;
- link evidence/logs instead of pasting payloads/documents;
- never include passwords, OTPs, tokens, QR secrets, signed URLs, full identity documents, payment data, precise location, or unrelated private messages;
- no discriminatory, insulting, speculative, or productivity-surveillance content;
- edits create version/supersession; no silent history rewrite;
- access follows case purpose/capability and is audited;
- retention follows case/evidence class.

## External boundary

Internal notes are never copied automatically into customer/merchant responses, exports, or appeal reasons. Customer-facing reasons use separately approved templates and safe facts. Data-subject/export/legal review determines disclosure case by case; “internal” is not a magical legal exemption.

## Automation

Summaries may be assistive only if source references, redaction, and human verification exist. No model-generated accusation or enforcement rationale becomes authoritative.

`INTERNAL_NOTES_PUBLIC_BY_DEFAULT: NO`

`SILENT_NOTE_EDIT: NO`
