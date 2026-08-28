# Catalog Policy Metadata Model

Status: **OWNER REVIEW DRAFT — POLICY CLASSES NOT OWNER FINAL**
Wave: 16, Work Package 26

Correct identity does not grant permission to list, discover or sell. Policy is an
orthogonal, evidence-bearing projection evaluated for product, variant, listing and
bundle components.

## Conceptual classes

| Class | Meaning | Default behavior |
| --- | --- | --- |
| `NORMAL` | No catalog-specific restriction identified under current rules | Normal discovery subject to general safety. |
| `AGE_RESTRICTED` | Age gate or controlled presentation is required | Fail closed until required verification/flow exists. |
| `REGULATED` | Legal status, intended use, claim or authorization controls sale | Require authoritative metadata and allowed operational capability. |
| `LEGAL_REVIEW_REQUIRED` | Classification/evidence is ambiguous or jurisdiction-dependent | Not assignable/sellable until review. |
| `EXCLUDED` | Outside authorized EsnaftaVar physical-product scope | Preserve audit/history; block new active listing. |

## Metadata envelope

Policy class, reason code, jurisdiction, evidence/source, intended use, claim type,
actor, effective interval, last verified time, review owner and rule version. Free
text alone cannot unlock a restricted product.

## Rules

- Apply Wave 15 separation: policy is not a taxonomy branch or product facet used to
  conceal permission logic.
- Medical intended use/regulatory status, PPE certification, age restriction and
  excluded weapons/pyrotechnics/digital/service scope require owner/legal decisions.
- Bundle policy is at least as restrictive as every component and may add composition
  rules.
- Merchant cannot self-approve regulated evidence. Trusted import is authoritative
  only for explicitly covered fields and jurisdiction.
- Missing policy metadata fails closed only for rule-scoped sensitive classes; it
  must not block ordinary products indiscriminately.
- Policy change does not rewrite identity or historical purchase; it changes current
  assignability/discovery with an audit event.

This is classification architecture, not legal advice or an implemented permission
system.
