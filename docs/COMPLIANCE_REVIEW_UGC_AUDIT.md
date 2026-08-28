# Review, UGC and Merchant-Response Compliance Audit

**State:** PROPOSED — LAWYER/PRODUCT/PRIVACY REVIEW REQUIRED  
**Research cut-off:** 2026-08-28

## Evidence baseline

The [Ministry Consumer Reviews Guide](https://tuketici.ticaret.gov.tr/data/65089fd113b8769d9861719f/T%C3%BCketici%20De%C4%9Ferlendirmeleri%20Hakk%C4%B1nda%20K%C4%B1lavuz%20-%20kurul%20karar%C4%B1.pdf)
supports transparency about whether a reviewer obtained the product/service, equal
treatment of positive and negative reviews, objective publication ordering and
controls against fake reviews. The [2026 Ministry update](https://ab.ticaret.gov.tr/haberler/ticaret-bakanligindan-tuketici-sikayet-platformlarinda-daha-hizli-ve-seffaf-surec)
adds current complaint/review-platform process signals effective 2026-08-01. These
sources do not decide that EsnaftaVar's QR mechanism is legally sufficient evidence
for every use of “purchase.”

## Verified-review claim

Customer-facing explanation should say, in substance:

> EsnaftaVar doğrulaması, müşteri ve mağazanın aynı QR işlemini onayladığını ve
> kaydedilen ürün/fiyat anlık görüntüsünü gösterir. Ödeme, fiş, fatura veya denetlenmiş
> mağaza cirosu kanıtı değildir.

Final copy requires owner/legal review. The badge and rating calculation must use
server-authoritative eligible evidence; client state, merchant assertion or payment
to EsnaftaVar cannot create verification.

## Publication and moderation contract

| Rule | V1 posture |
|---|---|
| Eligibility | exactly defined QR/verified-purchase rule; no arbitrary invite-only pool |
| Positive/negative parity | same objective publication and moderation criteria |
| Sorting | disclosed objective order; sponsorship never changes review order/score |
| Rejection | specific safe reason class, correction path and appeal/report route |
| Editing | preserve revision history and evidence status; no silent semantic edit |
| Merchant disagreement | response/report route, not veto/removal |
| Remedied complaint | verified remediation can be shown beside original; original not silently erased |
| Fake/manipulated review | investigate evidence and coordinated abuse; preserve appeal |
| Rating | deterministic eligible-review projection; operator cannot set arbitrary score |

## UGC report classes

- personal data/privacy exposure;
- threats, harassment, hate or unsafe content;
- illegal content or regulated-product claim;
- fabricated experience/conflict of interest/coordinated manipulation;
- irrelevant/spam/duplicate content;
- merchant response abuse;
- copyright/trademark or other rights claim requiring a defined notice route;
- child safety or self-harm emergency signal requiring specialist escalation.

This taxonomy is an operational intake aid, not a legal finding. Automated keyword
detection may prioritize but cannot be the sole final decision for high-impact cases.

## Merchant response and reporting

Merchants can answer a review under published content rules and report a review with
evidence. They cannot obtain removal merely because the review is negative, condition
a remedy on removal, reveal customer identity, publish private transaction/chat data,
or use a response as advertising. A response does not change rating. If the customer
reports a resolution, the verified resolution is displayed without rewriting history.

## Privacy and account deletion

- Public review content and public display name are separated from restricted QR
  evidence and account identifiers.
- Moderators see only the fields needed for the case; merchant never receives the
  customer's contact, exact location or raw QR secret.
- Account closure requires an approved rule among deletion, anonymized continued
  display or restricted retention. It must not fabricate a named author or convert
  an ineligible review into an eligible one.
- Search/analytics do not ingest free-text review or private moderation evidence by
  default.
- Screenshots/attachments, if supported later, need metadata stripping, malware/type
  controls, access and shorter retention.

## Due process

High-impact removal/restriction records content/version, rule version, evidence,
actor, reason, timestamps and appeal. Urgent containment can occur before full review
when ongoing harm is plausible, but it receives prompt reassessment. Reporter identity,
fraud thresholds and internal security notes are protected.

## Open decisions

1. Exact public definition/copy for QR verified purchase — `PRODUCT_OWNER` + `LAWYER`.
2. Which review-platform rules apply to this model — `LAWYER`.
3. Publication/rejection timing and merchant-response mechanics — `LAWYER` + owner.
4. Review/account-deletion and retention model — `LAWYER` +
   `KVKK/PRIVACY_SPECIALIST`.
5. Rating behavior after `VOIDED/DISPUTED/SUPERSEDED` evidence — `PRODUCT_OWNER`.
6. Illegal-content notice/counter-notice and emergency escalation — `LAWYER`.

`MERCHANT_CAN_REMOVE_NEGATIVE_REVIEW: NO`

