-- PHASE 1 DESIGN PROTOTYPE, NOT A MIGRATION OR DEPLOYMENT PACKAGE.
-- Authoritative rules: docs/ESNAFTAVAR_V1_TRUST_COMMERCE_CANONICAL.md.
-- Shapes/constraints only: no business RPC, funding, provider, job or UI activation.
-- All new objects live in an isolated local schema. Existing public/auth/storage
-- objects, migrations 0012/0013/0014/0015 and proposal 0016 remain untouched.
-- Future slices must translate reviewed shapes into individually gated migrations.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '60s';
DO $local_only$
BEGIN
  IF current_setting('esnaftavar.phase1.local_rehearsal', true)
       IS DISTINCT FROM 'local_rehearsal_only'
     OR version() NOT LIKE '%PGlite%'
  THEN
    RAISE EXCEPTION 'PHASE1_LOCAL_PGLITE_REHEARSAL_ONLY' USING ERRCODE='42501';
  END IF;
  IF to_regclass('public.products') IS NULL
     OR to_regclass('public.shop_products') IS NULL
     OR to_regclass('public.verified_transactions') IS NULL
     OR to_regclass('public.verified_transaction_items') IS NULL
  THEN
    RAISE EXCEPTION 'PHASE1_EXISTING_CANONICAL_ANCHORS_REQUIRED';
  END IF;
END $local_only$;
CREATE SCHEMA phase1_design;
REVOKE ALL ON SCHEMA phase1_design FROM PUBLIC, anon, authenticated, service_role;

-- H0: published config is immutable; numerical V1 defaults are specified in docs,
-- not seeded or hardcoded into Flutter by this proposal.
CREATE TABLE phase1_design.policy_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  policy_key text NOT NULL,
  version integer NOT NULL CHECK(version > 0),
  rules jsonb NOT NULL CHECK(jsonb_typeof(rules)='object'),
  rules_hash text NOT NULL,
  effective_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(policy_key, version)
);
CREATE TABLE phase1_design.commerce_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_kind text NOT NULL,
  aggregate_id uuid NOT NULL,
  event_kind text NOT NULL,
  source_key text NOT NULL UNIQUE,
  schema_version integer NOT NULL CHECK(schema_version > 0),
  policy_version_id uuid REFERENCES phase1_design.policy_versions(id),
  payload jsonb NOT NULL CHECK(jsonb_typeof(payload)='object'),
  occurred_at timestamptz NOT NULL DEFAULT now()
);
-- Delivery state is a rebuildable operational projection, not an economic event.
CREATE TABLE phase1_design.consumer_receipts (
  consumer_key text NOT NULL,
  event_id uuid NOT NULL REFERENCES phase1_design.commerce_events(id),
  applied_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY(consumer_key, event_id)
);

-- A: no second central product/listing store.
CREATE TABLE phase1_design.product_identity_meta (
  product_id uuid PRIMARY KEY REFERENCES public.products(id) ON DELETE RESTRICT,
  product_type text NOT NULL CHECK(product_type IN
    ('shared_catalog_product','merchant_unique_product')),
  origin_shop_id uuid,
  model text,
  variant text,
  normalized_name text NOT NULL,
  normalized_brand text,
  normalization_version integer NOT NULL CHECK(normalization_version > 0),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK((product_type='merchant_unique_product') = (origin_shop_id IS NOT NULL))
);
CREATE TABLE phase1_design.product_identifiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  scheme text NOT NULL CHECK(scheme='gtin'),
  normalized_value text NOT NULL CHECK(normalized_value ~ '^[0-9]{14}$'),
  validated_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(scheme, normalized_value)
);
-- Check-digit validation, canonical assignment and ambiguous similarity decisions
-- are REQUIRED future RPC work; digit shape alone does not validate a GTIN.
CREATE TABLE phase1_design.product_submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  submitted_by uuid NOT NULL,
  identity_payload jsonb NOT NULL CHECK(jsonb_typeof(identity_payload)='object'),
  intended_type text NOT NULL CHECK(intended_type IN
    ('shared_catalog_product','merchant_unique_product')),
  request_key text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(shop_id, request_key)
);
CREATE TABLE phase1_design.listing_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  listing_id uuid NOT NULL REFERENCES public.shop_products(id) ON DELETE RESTRICT,
  bucket_id text NOT NULL CHECK(length(bucket_id)>0),
  object_key text NOT NULL CHECK(length(object_key)>0),
  sort_order integer NOT NULL CHECK(sort_order >= 0),
  is_primary boolean NOT NULL DEFAULT false,
  publication_state text NOT NULL CHECK(publication_state IN ('pending','published','retired')),
  uploaded_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(bucket_id, object_key),
  UNIQUE(listing_id, sort_order)
);
CREATE UNIQUE INDEX listing_one_primary_published
  ON phase1_design.listing_images(listing_id)
  WHERE is_primary AND publication_state='published';
CREATE TABLE phase1_design.listing_unit_metadata (
  listing_id uuid PRIMARY KEY REFERENCES public.shop_products(id) ON DELETE RESTRICT,
  unit_code text NOT NULL CHECK(length(btrim(unit_code)) BETWEEN 1 AND 40),
  pack_quantity numeric(12,3) NOT NULL CHECK(pack_quantity > 0),
  measure_label text,
  updated_at timestamptz NOT NULL DEFAULT now()
);
-- Unit vocabulary is server-configured; V1 Cart quantities remain whole package
-- counts unless a later explicitly scoped measurement contract changes them.

-- B: terms supplement, not duplicate/rename, existing immutable purchase items.
CREATE TABLE phase1_design.purchase_terms (
  purchase_id uuid PRIMARY KEY REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  final_sale_minor bigint NOT NULL CHECK(final_sale_minor >= 0),
  ev_coupon_minor bigint NOT NULL CHECK(ev_coupon_minor >= 0),
  customer_payment_minor bigint GENERATED ALWAYS AS
    (final_sale_minor - ev_coupon_minor) STORED,
  voluntary_return_seconds bigint NOT NULL CHECK(voluntary_return_seconds >= 0),
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  allocation_snapshot jsonb NOT NULL CHECK(jsonb_typeof(allocation_snapshot)='object'),
  finalizing_user_id uuid NOT NULL,
  finalizing_auth_session_id uuid NOT NULL,
  finalizing_installation_id uuid NOT NULL,
  claim_id uuid NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  CHECK(ev_coupon_minor <= final_sale_minor)
);
-- These reference the SAME existing QR session UUID. Snapshot IDs are deliberately
-- not FKs to disposable auth/cart/qr rows; future RPC must authenticate live source.
CREATE TABLE phase1_design.qr_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  qr_session_id uuid NOT NULL UNIQUE,
  shop_id uuid NOT NULL,
  merchant_user_id uuid NOT NULL,
  auth_session_id uuid NOT NULL,
  installation_id uuid NOT NULL,
  claimed_at timestamptz NOT NULL,
  completion_expires_at timestamptz NOT NULL,
  request_key text NOT NULL,
  UNIQUE(merchant_user_id, request_key),
  CHECK(completion_expires_at > claimed_at)
);
CREATE TABLE phase1_design.qr_manual_aliases (
  qr_session_id uuid PRIMARY KEY,
  shop_id uuid NOT NULL,
  code_digest bytea NOT NULL,
  expires_at timestamptz NOT NULL,
  consumed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(shop_id, code_digest),
  CHECK(expires_at > created_at)
);
-- Codes are never stored in plaintext. Unique lookup/rate limits and both-channel
-- consumption are future atomic authority, not implemented by this shape.
CREATE TABLE phase1_design.purchase_returns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  return_kind text NOT NULL CHECK(return_kind IN ('genuine','administrative_correction')),
  actor_user_id uuid NOT NULL,
  reason text NOT NULL CHECK(length(btrim(reason))>0),
  request_key text NOT NULL UNIQUE,
  reverses_return_id uuid REFERENCES phase1_design.purchase_returns(id),
  occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE phase1_design.purchase_return_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  return_id uuid NOT NULL REFERENCES phase1_design.purchase_returns(id) ON DELETE RESTRICT,
  purchase_item_id uuid NOT NULL REFERENCES public.verified_transaction_items(id) ON DELETE RESTRICT,
  quantity integer NOT NULL CHECK(quantity > 0),
  sale_return_minor bigint NOT NULL CHECK(sale_return_minor >= 0),
  ev_coupon_return_minor bigint NOT NULL CHECK(ev_coupon_return_minor >= 0),
  UNIQUE(return_id, purchase_item_id),
  CHECK(ev_coupon_return_minor <= sale_return_minor)
);
-- Future locked RPC verifies same purchase, total returned qty <= purchased qty,
-- snapshotted allocations and administrative correction provenance.

-- C: companions to existing public.reviews, not another public-review API.
CREATE TABLE phase1_design.review_entitlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id) ON DELETE RESTRICT,
  evidence_item_id uuid NOT NULL REFERENCES public.verified_transaction_items(id) ON DELETE RESTRICT,
  customer_user_id uuid NOT NULL,
  product_id uuid NOT NULL,
  shop_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(purchase_id, product_id),
  UNIQUE(id, customer_user_id, product_id)
);
CREATE TABLE phase1_design.review_lifecycle (
  review_id uuid PRIMARY KEY,
  customer_user_id uuid NOT NULL,
  product_id uuid NOT NULL,
  visibility text NOT NULL CHECK(visibility IN ('public','withdrawn','hidden','under_review')),
  edit_until timestamptz NOT NULL,
  current_revision_id uuid,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(customer_user_id, product_id),
  UNIQUE(review_id, customer_user_id, product_id)
);
CREATE TABLE phase1_design.review_revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL,
  customer_user_id uuid NOT NULL,
  product_id uuid NOT NULL,
  entitlement_id uuid NOT NULL,
  rating smallint NOT NULL CHECK(rating BETWEEN 1 AND 5),
  written_text text,
  request_key text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(id, review_id),
  FOREIGN KEY(review_id, customer_user_id, product_id)
    REFERENCES phase1_design.review_lifecycle(review_id, customer_user_id, product_id),
  FOREIGN KEY(entitlement_id, customer_user_id, product_id)
    REFERENCES phase1_design.review_entitlements(id, customer_user_id, product_id)
);
ALTER TABLE phase1_design.review_lifecycle ADD CONSTRAINT review_current_revision_same_root
  FOREIGN KEY(current_revision_id, review_id)
  REFERENCES phase1_design.review_revisions(id, review_id);
CREATE TABLE phase1_design.review_entitlement_uses (
  entitlement_id uuid PRIMARY KEY REFERENCES phase1_design.review_entitlements(id),
  review_id uuid NOT NULL REFERENCES phase1_design.review_lifecycle(review_id),
  use_kind text NOT NULL CHECK(use_kind IN ('create','reopen')),
  window_opened_at timestamptz NOT NULL,
  edit_until timestamptz NOT NULL,
  request_key text NOT NULL UNIQUE,
  CHECK(edit_until > window_opened_at)
);
CREATE TABLE phase1_design.service_evaluations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL UNIQUE REFERENCES public.verified_transactions(id),
  customer_user_id uuid NOT NULL,
  shop_id uuid NOT NULL,
  friendliness smallint NOT NULL CHECK(friendliness BETWEEN 1 AND 5),
  communication smallint NOT NULL CHECK(communication BETWEEN 1 AND 5),
  cleanliness smallint NOT NULL CHECK(cleanliness BETWEEN 1 AND 5),
  request_key text NOT NULL UNIQUE,
  submitted_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE phase1_design.merchant_review_replies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL UNIQUE REFERENCES phase1_design.review_lifecycle(review_id),
  origin_revision_id uuid NOT NULL,
  replying_shop_id uuid NOT NULL,
  replying_user_id uuid NOT NULL,
  reply_text text NOT NULL CHECK(length(btrim(reply_text))>0),
  created_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY(origin_revision_id, review_id)
    REFERENCES phase1_design.review_revisions(id, review_id)
);
CREATE TABLE phase1_design.moderation_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_kind text NOT NULL CHECK(subject_kind IN ('purchase','review','reply','service_evaluation','submission')),
  subject_id uuid NOT NULL,
  action text NOT NULL CHECK(action IN ('hide','restore','under_review','fraud_invalid','spam_invalid','approve','reject','report')),
  actor_user_id uuid NOT NULL,
  reason text NOT NULL CHECK(length(btrim(reason))>0),
  request_key text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- D: no public geometry or private evidence publication by this proposal.
CREATE TABLE phase1_design.local_area_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  city_code text NOT NULL,
  district_code text NOT NULL,
  neighborhood_code text NOT NULL,
  dataset_version text NOT NULL,
  boundary_snapshot jsonb NOT NULL,
  boundary_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(city_code, district_code, neighborhood_code, dataset_version)
);
CREATE TABLE phase1_design.shop_area_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  area_version_id uuid NOT NULL REFERENCES phase1_design.local_area_versions(id),
  effective_at timestamptz NOT NULL,
  reason text NOT NULL,
  request_key text NOT NULL UNIQUE
);
CREATE TABLE phase1_design.badge_award_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_kind text NOT NULL CHECK(subject_kind IN ('customer','merchant')),
  subject_id uuid NOT NULL,
  family text NOT NULL,
  badge_code text NOT NULL,
  action text NOT NULL CHECK(action IN ('earned','qualification_lost','restored','evidence_invalidated')),
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  evidence_snapshot jsonb NOT NULL,
  source_key text NOT NULL UNIQUE,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

-- H0: journal/posting shapes; balancing/source authorization requires the future
-- atomic server implementation. There is intentionally no client posting function.
CREATE TABLE phase1_design.ledger_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_kind text NOT NULL CHECK(owner_kind IN ('platform','merchant','customer','package')),
  owner_id uuid NOT NULL,
  account_code text NOT NULL,
  currency char(3) NOT NULL CHECK(currency='TRY'),
  UNIQUE(owner_kind, owner_id, account_code, currency)
);
CREATE TABLE phase1_design.ledger_journals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_kind text NOT NULL,
  source_id uuid NOT NULL,
  source_class text NOT NULL CHECK(source_class IN
    ('coupon_redemption','package_funding','unused_package_fund','platform_service','settlement','reward_issue','return','admin_reversal')),
  request_key text NOT NULL UNIQUE,
  reverses_journal_id uuid REFERENCES phase1_design.ledger_journals(id),
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE phase1_design.ledger_postings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_id uuid NOT NULL REFERENCES phase1_design.ledger_journals(id) ON DELETE RESTRICT,
  account_id uuid NOT NULL REFERENCES phase1_design.ledger_accounts(id),
  amount_minor bigint NOT NULL CHECK(amount_minor <> 0),
  UNIQUE(journal_id, account_id)
);
CREATE TABLE phase1_design.future_reward_offsets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_user_id uuid NOT NULL,
  reversal_journal_id uuid NOT NULL REFERENCES phase1_design.ledger_journals(id),
  event_kind text NOT NULL CHECK(event_kind IN ('created','recovered')),
  amount_minor bigint NOT NULL CHECK(amount_minor > 0),
  source_key text NOT NULL UNIQUE,
  occurred_at timestamptz NOT NULL DEFAULT now()
);

-- E: states below are operational projections; immutable monetary effects are
-- contributions/journals. No rows are physically moved between cycles.
CREATE TABLE phase1_design.referral_packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  slot_count integer NOT NULL CHECK(slot_count > 0),
  fund_minor bigint NOT NULL CHECK(fund_minor > 0),
  service_fee_minor bigint NOT NULL CHECK(service_fee_minor >= 0),
  activated_at timestamptz NOT NULL,
  expires_at timestamptz NOT NULL,
  state text NOT NULL CHECK(state IN ('pending','active','expired','closed')),
  funding_journal_id uuid REFERENCES phase1_design.ledger_journals(id),
  CHECK(expires_at > activated_at),
  CHECK(state <> 'active' OR funding_journal_id IS NOT NULL)
);
CREATE UNIQUE INDEX referral_one_active_shop ON phase1_design.referral_packages(shop_id)
  WHERE state='active';
CREATE TABLE phase1_design.reward_reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_user_id uuid NOT NULL,
  cart_id uuid NOT NULL,
  cart_revision text NOT NULL,
  package_id uuid NOT NULL REFERENCES phase1_design.referral_packages(id),
  checkout_attempt_id uuid NOT NULL,
  state text NOT NULL CHECK(state IN ('reserved','checkout_hold','consumed','released','expired','cancelled')),
  reserved_at timestamptz NOT NULL,
  expires_at timestamptz NOT NULL,
  hold_expires_at timestamptz,
  claim_id uuid REFERENCES phase1_design.qr_claims(id),
  CHECK(expires_at > reserved_at),
  CHECK(state <> 'checkout_hold' OR (hold_expires_at IS NOT NULL AND claim_id IS NOT NULL))
);
CREATE UNIQUE INDEX reward_one_active_user ON phase1_design.reward_reservations(customer_user_id)
  WHERE state IN ('reserved','checkout_hold');
CREATE TABLE phase1_design.reward_contributions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL REFERENCES public.verified_transactions(id),
  customer_user_id uuid NOT NULL,
  package_id uuid NOT NULL REFERENCES phase1_design.referral_packages(id),
  event_kind text NOT NULL CHECK(event_kind IN ('grant','reversal')),
  amount_minor bigint NOT NULL CHECK(amount_minor > 0),
  reverses_contribution_id uuid REFERENCES phase1_design.reward_contributions(id),
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  matures_at timestamptz NOT NULL,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  source_key text NOT NULL UNIQUE,
  CHECK((event_kind='reversal') = (reverses_contribution_id IS NOT NULL))
);
CREATE UNIQUE INDEX reward_one_grant_purchase ON phase1_design.reward_contributions(purchase_id)
  WHERE event_kind='grant';
CREATE UNIQUE INDEX reward_one_reversal_grant ON phase1_design.reward_contributions(reverses_contribution_id)
  WHERE event_kind='reversal';
CREATE INDEX reward_chronology ON phase1_design.reward_contributions(customer_user_id, occurred_at, id);
CREATE TABLE phase1_design.reward_coupon_issues (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_user_id uuid NOT NULL,
  allocation_key text NOT NULL UNIQUE,
  face_value_minor bigint NOT NULL CHECK(face_value_minor > 0),
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  issued_at timestamptz NOT NULL,
  expires_at timestamptz,
  CHECK(expires_at IS NULL OR expires_at > issued_at)
);
CREATE TABLE phase1_design.coupon_contribution_links (
  coupon_id uuid NOT NULL REFERENCES phase1_design.reward_coupon_issues(id),
  contribution_id uuid NOT NULL UNIQUE REFERENCES phase1_design.reward_contributions(id),
  ordinal integer NOT NULL CHECK(ordinal > 0),
  PRIMARY KEY(coupon_id, ordinal)
);
CREATE TABLE phase1_design.coupon_redemptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id uuid NOT NULL UNIQUE REFERENCES public.verified_transactions(id),
  authorization_id uuid NOT NULL,
  journal_id uuid NOT NULL REFERENCES phase1_design.ledger_journals(id),
  request_key text NOT NULL UNIQUE,
  occurred_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE phase1_design.coupon_redemption_allocations (
  redemption_id uuid NOT NULL REFERENCES phase1_design.coupon_redemptions(id),
  coupon_id uuid NOT NULL REFERENCES phase1_design.reward_coupon_issues(id),
  amount_minor bigint NOT NULL CHECK(amount_minor > 0),
  PRIMARY KEY(redemption_id, coupon_id)
);
CREATE TABLE phase1_design.shop_coupon_preference (
  shop_id uuid PRIMARY KEY,
  preferred_enabled boolean NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);
-- Effective acceptance is derived from preferred_enabled OR active-package/
-- outstanding-hold obligation. There is no client-writable forced lock flag.

-- F: informational offers, no cart-discount/stacking engine.
CREATE TABLE phase1_design.merchant_offers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL,
  title text NOT NULL CHECK(length(btrim(title)) BETWEEN 1 AND 120),
  offer_type text NOT NULL CHECK(offer_type IN ('discounted_price','percentage','announcement')),
  scope text NOT NULL CHECK(scope IN ('one_listing','multiple_listings','shop')),
  discount_price_minor bigint CHECK(discount_price_minor >= 0),
  discount_percent numeric(5,2) CHECK(discount_percent > 0 AND discount_percent <= 100),
  short_description text,
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  is_active boolean NOT NULL DEFAULT false,
  CHECK(ends_at > starts_at),
  CHECK((offer_type='discounted_price') = (discount_price_minor IS NOT NULL)),
  CHECK((offer_type='percentage') = (discount_percent IS NOT NULL))
);
CREATE TABLE phase1_design.offer_listing_links (
  offer_id uuid NOT NULL REFERENCES phase1_design.merchant_offers(id),
  listing_id uuid NOT NULL REFERENCES public.shop_products(id),
  selected_image_id uuid REFERENCES phase1_design.listing_images(id),
  PRIMARY KEY(offer_id, listing_id)
);

-- G: time extensions do not create additional ranking weights.
CREATE TABLE phase1_design.visibility_packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL UNIQUE
);
CREATE TABLE phase1_design.visibility_purchase_intervals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id uuid NOT NULL REFERENCES phase1_design.visibility_packages(id),
  service_journal_id uuid NOT NULL UNIQUE REFERENCES phase1_design.ledger_journals(id),
  policy_version_id uuid NOT NULL REFERENCES phase1_design.policy_versions(id),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  promoted_offer_id uuid REFERENCES phase1_design.merchant_offers(id),
  CHECK(ends_at > starts_at)
);
CREATE TABLE phase1_design.sponsored_push_entitlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_interval_id uuid NOT NULL UNIQUE REFERENCES phase1_design.visibility_purchase_intervals(id),
  starts_at timestamptz NOT NULL,
  expires_at timestamptz NOT NULL,
  state text NOT NULL CHECK(state IN ('unused','queued','planned','dispatched','expired')),
  CHECK(expires_at > starts_at)
);
CREATE TABLE phase1_design.ad_copy_revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entitlement_id uuid NOT NULL REFERENCES phase1_design.sponsored_push_entitlements(id),
  intent text NOT NULL,
  subtype text NOT NULL,
  wording_family text NOT NULL,
  structured_facts jsonb NOT NULL,
  approved_copy text NOT NULL,
  approved_by uuid NOT NULL,
  approved_at timestamptz NOT NULL,
  source_key text NOT NULL UNIQUE
);
CREATE TABLE phase1_design.marketing_recipient_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_user_id uuid NOT NULL,
  bucket text NOT NULL CHECK(bucket IN ('sponsored_merchant','platform_general')),
  campaign_id uuid NOT NULL,
  entitlement_id uuid REFERENCES phase1_design.sponsored_push_entitlements(id),
  notification_id uuid,
  state text NOT NULL CHECK(state IN ('claimed','provider_accepted','unknown','failed','cancelled')),
  claimed_at timestamptz NOT NULL,
  provider_accepted_at timestamptz,
  UNIQUE(customer_user_id, campaign_id),
  CHECK((bucket='sponsored_merchant') = (entitlement_id IS NOT NULL))
);
-- Rolling24h serialized user-level bucket enforcement is future server logic.
-- One existing notifications row fans out via the UNCHANGED 0016 transport.
CREATE TABLE phase1_design.ad_observation_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_kind text NOT NULL CHECK(event_kind IN
    ('ad_impression','ad_click','shop_view','directions_requested','verified_purchase')),
  package_id uuid NOT NULL REFERENCES phase1_design.visibility_packages(id),
  placement text NOT NULL,
  observation_key text NOT NULL UNIQUE,
  context_snapshot jsonb NOT NULL,
  observed_at timestamptz NOT NULL DEFAULT now()
);

-- Schema is intentionally not usable by the apps, including service_role.
-- Future numbered migrations must provide reviewed public/own projections and RPCs.
DO $deny_all$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname='phase1_design' LOOP
    EXECUTE format('ALTER TABLE phase1_design.%I ENABLE ROW LEVEL SECURITY', t.tablename);
    EXECUTE format('ALTER TABLE phase1_design.%I FORCE ROW LEVEL SECURITY', t.tablename);
    EXECUTE format('REVOKE ALL ON TABLE phase1_design.%I FROM PUBLIC, anon, authenticated, service_role', t.tablename);
  END LOOP;
END $deny_all$;

-- Generic storage safeguard only, not a reward/review/Ads implementation.
CREATE FUNCTION phase1_design.reject_audit_mutation() RETURNS trigger
LANGUAGE plpgsql SET search_path=pg_catalog AS $immutable$
BEGIN
  RAISE EXCEPTION 'PHASE1_APPEND_ONLY_RECORD' USING ERRCODE='55000';
END $immutable$;
REVOKE ALL ON FUNCTION phase1_design.reject_audit_mutation()
  FROM PUBLIC, anon, authenticated, service_role;
DO $append_only$
DECLARE n text;
BEGIN
  FOREACH n IN ARRAY ARRAY[
    'policy_versions','commerce_events','consumer_receipts','product_submissions',
    'purchase_terms','qr_claims','purchase_returns','purchase_return_items',
    'review_entitlements','review_revisions','review_entitlement_uses',
    'service_evaluations','merchant_review_replies','moderation_events',
    'local_area_versions','shop_area_assignments','badge_award_events',
    'ledger_accounts','ledger_journals','ledger_postings','future_reward_offsets',
    'reward_contributions','reward_coupon_issues','coupon_contribution_links',
    'coupon_redemptions','coupon_redemption_allocations',
    'visibility_purchase_intervals','ad_copy_revisions','ad_observation_events'
  ] LOOP
    EXECUTE format('CREATE TRIGGER immutable_record BEFORE UPDATE OR DELETE ON phase1_design.%I FOR EACH ROW EXECUTE FUNCTION phase1_design.reject_audit_mutation()', n);
  END LOOP;
END $append_only$;
COMMIT;
