# EsnaftaVar Merchant Product Attribute Onboarding

**State:** `PROVISIONAL ATTRIBUTE-ENTRY DESIGN`  
**Scope:** Attribute-entry implications only; not a merchant-app, UI or runtime design

## Goal

Collect the smallest reliable set of product facts needed for local discovery,
comparison, compatibility and safety without asking a merchant to understand the
taxonomy architecture or fill dozens of irrelevant fields.

## Ownership classes

| Class | Merchant experience | Examples | Guardrail |
|---|---|---|---|
| `AUTO_INHERITED_FROM_CANONICAL_PRODUCT` | Shown read-only; merchant confirms product match | canonical title, brand/manufacturer, model, packaged-product facts | A wrong match must be correctable via review, not local overwrite. |
| `MERCHANT_REQUIRED` | Small leaf/profile-specific minimum | exact leaf, listing condition, applicable variant selections, mandatory compatibility target/evidence | Required only when applicable; no global mega-form. |
| `MERCHANT_OPTIONAL` | Progressive optional section | color/material details, dimensions, extra discovery attributes | Optional values cannot be fabricated from title. |
| `SYSTEM_DERIVED` | Not directly editable | normalized color/units, search tokens, compatibility result/confidence | Source facts and rule version retained. |
| `NOT_MERCHANT_EDITABLE` | Read-only policy/system state | certification verification, eligibility, moderation, canonical concept identity | Merchant may submit evidence, never approve it. |

## Product, listing and taxonomy separation

| Data | Classification | Reason |
|---|---|---|
| Canonical product title/identity | inherited or canonical-review flow | Shared product fact, not shop-local prose. |
| Shop price | listing/offer data | Not a taxonomy facet. |
| Shop stock/availability | listing state | Local and time-varying. |
| Shop-specific SKU | listing identity | Not canonical product identity. |
| Brand/manufacturer/model | canonical product attribute where matched | Merchant can propose correction/evidence, not fork concepts. |
| Color/size | product/variant candidate by profile | Boundary remains provisional; avoid premature universal rule. |
| Condition | listing/product-instance state | New/refurbished/used policy differs by domain. |
| Compatibility | structured target input; result system-derived | Merchant prose cannot set `compatible`. |
| Policy/certification | evidence submission plus policy decision | Category assignment does not grant approval. |

## Progressive flow

1. **Find canonical product:** scan/search or choose one primary leaf; show why the
   match is expected. A missing product creates a review proposal, not a duplicate.
2. **Confirm shop listing facts:** shop SKU, price, stock/availability and condition.
3. **Complete required attribute set:** only leaf/profile `REQUIRED` and
   `POLICY_CONDITIONAL` fields.
4. **Select variant where applicable:** reuse an existing variant or propose a new
   combination; do not embed values in category/title alone.
5. **Declare compatibility targets:** select governed devices/models/vehicles/systems;
   upload/attach permitted evidence through a future safe flow.
6. **Add optional discovery facts:** short, ranked groups rather than an exhaustive form.
7. **Review summary:** show inherited, merchant-entered, derived and pending-review
   values distinctly before publish/request-review.

## Form-load controls

- Profile by exact leaf; hide `NOT_APPLICABLE` fields.
- Start with a target of 5–8 ordinary required inputs after canonical match; high-risk
  products may require more evidence, but that is a policy gate, not form inflation.
- Group as Identity, Variant/measure, Compatibility, Safety/evidence and Optional.
- Use controlled choice/reference and unit-aware numeric inputs before free text.
- Inherit values from canonical product/variant; never make merchants retype them.
- Explain why a value is required and give physical examples, not technical jargon.
- Save draft and retain provenance; incomplete draft is not silently publishable.
- Conditional reveal: e.g. entering a medical/protective/organic claim reveals
  evidence requirements and may route to review.

## Validation behavior

| Situation | Safe behavior |
|---|---|
| Known value alias (`black`) | Normalize to governed `Siyah`; show merchant the resolved value. |
| Unknown enum/material | Preserve source in draft and request review; do not create enum automatically. |
| Missing required compatibility target | Keep unpublished/review state; never assume universal fit. |
| Contradictory inherited fact | Merchant submits correction evidence; existing canonical product is not overwritten. |
| Unsupported unit/free-text number | Ask for unit/type correction; do not parse optimistically. |
| Duplicate product/variant candidate | Present existing match and differences before creating anything. |
| Policy-sensitive claim | Capture evidence, set pending; do not show verified filter/claim. |

## Domain examples

### Generic packaged food

Inherited: canonical product/title, brand, packaged ingredients when already verified.
Merchant required: listing condition/availability and exact pack/variant selection.
Optional: local lot/expiry only if future listing policy requires it. Dietary/allergen
claims are inherited/verified, not casual merchant toggles.

### T-shirt

Inherited: model/style identity, brand and material when canonical. Merchant chooses
the exact color/size variant and enters shop price/stock. Gender, style and occasion
remain discovery facets; they do not create merchant-only categories.

### Phone accessory

Inherited: product type/material and known model relations. Merchant selects exact
canonical accessory/variant, condition, price/stock. If compatibility is missing,
the merchant selects governed device models; system computes status.

### Vehicle part

Part number and product identity are inherited/verified where possible. Merchant
must not type a comma-separated vehicle list. Structured vehicle targets/evidence
are required and eligibility remains policy-controlled.

### Health/medical product

Fail closed. Canonical match does not permit listing. Merchant submits classification,
authorization and traceability evidence through a future policy-owned workflow;
merchant cannot mark it verified.

## Editing and conflict ownership

- Shop-local price/stock edits never mutate canonical product facts.
- Canonical fact corrections enter reviewed change flow with source/provenance.
- Variant proposal must show which facet combination differs.
- Display-label alias changes do not require merchant data re-entry.
- Deprecated values are mapped/migrated through governed alias rules and surfaced
  only when merchant intervention is genuinely necessary.

## Metrics for future UX validation

- completion time and abandonment by profile;
- required-field count and validation error rate;
- canonical match reuse vs duplicate proposal rate;
- unknown enum/free-text leakage rate;
- compatibility target coverage and false claim rate;
- policy-sensitive drafts blocked before publish;
- merchant correction acceptance/rejection rate.

## Owner/runtime questions

1. canonical product creation/correction authority and review SLA;
2. exact variant candidate facets per leaf;
3. publication states and which domains are fail-closed;
4. evidence upload/review ownership;
5. acceptable required-field budget per domain;
6. bulk import contract and error feedback.

`MERCHANT_ATTRIBUTE_ONBOARDING_MODEL: PASS`

`MERCHANT_CAN_APPROVE_POLICY_EVIDENCE: NO`

`MERCHANT_FORM_IMPLEMENTED: NO`
