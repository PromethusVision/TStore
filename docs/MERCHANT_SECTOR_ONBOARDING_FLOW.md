# EsnaftaVar Merchant Onboarding — Sector Selection Flow

**State:** PROPOSED FOR OWNER REVIEW — FLOW CONTRACT ONLY

This document covers only merchant-sector selection. It does not design the full
Merchant App, screens, Auth role assignment, database, verification workflow,
catalog onboarding, booking, reservation or service pricing.

## 1. Design goals

- A Turkish merchant should answer **“İşletmeniz en çok hangi tür işletme?”** in
  under a minute for a clear case.
- The flow must not show 67 flat choices without search/grouping.
- The merchant selects a business identity, not every Product L1 it stocks.
- Policy-sensitive choices fail closed without making ordinary merchants feel like
  they are filling out a legal activity form.
- The three owner-confirmed beauty leaves remain exact and discoverable; `Unisex
  Kuaför` is absent.

## 2. Proposed happy path

```text
Start
  → Search or browse sector
  → Select one assignable primary leaf
  → Confirm “Bu işletme bir …” summary
  → Optionally add up to three real secondary business lines
  → Show policy notice/evidence step only when signalled
  → Save proposed classification
```

### Step 1 — Search first, browse always available

- Search accepts canonical name plus controlled Turkish aliases.
- Browse groups choices under 14 proposed navigation families.
- Results show leaf name and short definition, not NACE code.
- Family/grouping nodes cannot be selected under the recommendation.
- Exact matches rank before broad parents or fuzzy aliases.

### Step 2 — Primary selection

Prompt: **“Müşteriler işletmenizi en çok nasıl tanımlar?”**

Show one-line inclusion/exclusion examples for ambiguous choices. For example:

- `Telefoncu & GSM Mağazası`: primarily device/accessory retail;
- `Telefon & Elektronik Teknik Servisi`: primarily diagnosis/repair;
- a merchant doing both chooses its main identity, then adds the other as secondary
  and can be marked `MIXED`.

### Step 3 — Confirmation

Display:

- selected primary sector;
- plain-language definition;
- default operating model as a suggestion;
- “Bu seçim sattığınız ürün kategorilerini sınırlandırmaz” notice.

The confirmation must not imply merchant verification or product authorization.

### Step 4 — Suggested secondary sectors

- Optional; zero is valid.
- Offer at most five contextual suggestions, not the whole tree.
- Merchant may search for another leaf.
- Maximum proposed active secondaries: three.
- Explain: “Yalnız müşterilerin ayrıca bu hizmet/mağaza türü için geldiği gerçek iş
  kollarını ekleyin.”
- Incidental stock and one-off services must not become secondaries.

### Step 5 — Policy notice

Only sectors with policy signals show a targeted notice:

- what type of business evidence may later be requested;
- that selecting the sector does not yet prove authorization;
- that products remain independently reviewed;
- how the merchant can save and continue if verification is asynchronous.

`LEGAL_REVIEW_REQUIRED` sectors must not be publicly activated by taxonomy selection
alone.

## 3. “Other” handling

Do not create a public `Diğer` sector or publish free text as taxonomy.

1. Merchant searches aliases and browses broader families.
2. If still unmatched, collect a private free-text request plus optional description.
3. Temporarily classify the request as `UNRESOLVED`, not an active sector.
4. Taxonomy operations review frequency, meaning, overlaps and policy risk.
5. Merchant chooses an existing broader valid leaf only when it truthfully describes
   the business; otherwise public activation waits.

This prevents typo-, brand- and keyword-based sector inflation.

## 4. Correction after onboarding

- Merchant can request/change a normal adjacent sector from profile settings.
- Show the current primary and effective secondaries before confirmation.
- Warn that changing primary sector can alter discovery labels and contextual
  defaults, not Product Taxonomy placement.
- Material, unrelated or regulated changes route to review.
- Preserve versioned history; never overwrite analytics evidence.
- Retired sectors resolve through successor guidance.

## 5. Catalog-derived suggestions later

Future catalog evidence may suggest sectors after enough representative listings
exist. It must never:

- auto-assign or auto-change a sector;
- infer one sector per Product L1;
- infer regulated eligibility;
- move product categories based on merchant identity;
- treat seasonal/inactive inventory as the main business.

Suggested rationale should be visible: “Kataloğunuzda çok sayıda X ürünü olduğu
için Y ikincil sektörünü değerlendirebilirsiniz.”

## 6. Error and abuse controls

| Case | Proposed behavior |
|---|---|
| No primary selected | Cannot finish sector step. |
| Family/grouping selected | Ask for a leaf. |
| Duplicate primary/secondary | Reject duplicate. |
| Fourth secondary | Explain three-sector limit; route unusual case to review. |
| Unrelated combination | Ask for evidence/description; do not publish automatically. |
| Regulated sector | Start verification/review state; no instant badge/capability. |
| Retired sector | Offer successor choices; do not silently choose after a split. |
| Search alias collision | Show disambiguation with definitions. |
| Network retry | Idempotent save; avoid duplicate sector assignments. |

## 7. Beauty subtree flow

Searching `berber`, `erkek kuaförü`, `kadın kuaförü`, `kuaför` or `güzellik salonu`
may reveal the confirmed grouping, but assignment must land on exactly one of:

- `Erkek Berberi`
- `Kadın Kuaförü`
- `Güzellik Salonu`

No `Unisex Kuaför` option is created. If a merchant truthfully operates multiple
confirmed lines, it selects one primary and another confirmed leaf as secondary
within the general limit. Booking/reservation/service prices remain `TBD`.

## 8. Accessibility and clarity requirements

- Search and browse work with Turkish diacritics and controlled ASCII variants.
- Definitions use plain Turkish and do not expose raw legal codes.
- Selection is not color-only; state and policy notices have text labels.
- Back/resume retains in-progress selection without publishing.
- No dark pattern encourages extra sectors.

## 9. Open owner decisions

1. Approve search-first plus grouped-browse interaction.
2. Approve three-secondary maximum.
3. Decide whether normal-sector changes can publish immediately.
4. Assign the policy-review owner and expected service level.
5. Decide customer-facing display of secondaries.
6. Approve non-selectable family/grouping nodes.

`MERCHANT_SECTOR_ONBOARDING_FLOW: PROPOSED_FOR_OWNER_REVIEW`

`FULL_MERCHANT_APP_DESIGNED: NO`
