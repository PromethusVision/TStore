# Merchant App Local Merchant Realism Audit

Status: **RESEARCH — PROPOSED RECOMMENDATIONS**
Wave: 17 / WP72

## Would a neighborhood merchant use it?

Yes, conditionally: the pilot must center four daily jobs—scan QR, find/add product, change price, change availability—and hide organization/taxonomy complexity behind safe defaults.

## Realism findings

| Reality | Architecture response |
|---|---|
| Merchant has little time | One visible shop context, recent products, few taps |
| Stock is not digitally exact | Explicit known/unknown availability; no fake inventory |
| Many products lack reliable barcode | Search + custom candidate; barcode not mandatory |
| Prices change frequently | Fast single-listing edit with revision/audit |
| Same person does all work | OWNER can operate; staff model optional |
| Staff turnover occurs | Narrow, revocable permissions and session recheck |
| Internet can be weak | Read cache/draft preservation; server-required writes clear |
| Turkish terms vary | Synonyms/search; do not force merchant to browse taxonomy |
| Service/mixed/regulated shops exist | Separate operating model/policy review, fail closed |
| Branch prices differ | Listing is branch-specific; no hidden sync |

## Complexity to remove

- Do not expose canonical/variant/listing jargon in ordinary labels.
- Do not require exact inventory, enterprise hierarchy or analytics setup.
- Keep candidate review statuses limited and actionable.
- Defer bulk price, campaign management, booking and advanced staff roles.

## Pilot research needed

Observe 8–12 synthetic/usability sessions across technically inexperienced, barcode-heavy, custom-product, regulated, service/mixed and multi-branch personas. No real PII should enter research artifacts.
