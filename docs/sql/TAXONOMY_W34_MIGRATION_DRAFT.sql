-- TAXONOMY W34 MIGRATION DRAFT
-- STATUS: NOT EXECUTED / NOT AN ACTIVE SUPABASE MIGRATION
-- LOCATION CONTRACT: docs/sql only; never apply this file as-is.
-- BASE: origin/main@6415f09c8b84d3ef1c72d642c1908c433b534994
--
-- This draft deliberately aborts its own transaction. It contains no canonical
-- node UUID payload and no product reassignment payload. A future authorized
-- task must split schema/import/activation into reviewed active migrations.

BEGIN;

SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '30s';

DO $wave34_draft_guard$
BEGIN
  RAISE EXCEPTION
    'W34_DRAFT_NOT_EXECUTABLE: allocate/review canonical IDs, import manifests, backup, and Development authorization first';
END
$wave34_draft_guard$;

-- Everything below remains inside the transaction aborted by the guard above.
-- It documents a candidate additive schema; it is not an apply artifact.

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS source_key TEXT,
  ADD COLUMN IF NOT EXISTS slug TEXT,
  ADD COLUMN IF NOT EXISTS level SMALLINT,
  ADD COLUMN IF NOT EXISTS lifecycle_state TEXT,
  ADD COLUMN IF NOT EXISTS is_assignable BOOLEAN,
  ADD COLUMN IF NOT EXISTS policy_class TEXT,
  ADD COLUMN IF NOT EXISTS professional_review_status TEXT,
  ADD COLUMN IF NOT EXISTS taxonomy_version TEXT;

ALTER TABLE public.categories
  ADD CONSTRAINT categories_source_key_not_blank_check
    CHECK (source_key IS NULL OR length(btrim(source_key)) > 0) NOT VALID,
  ADD CONSTRAINT categories_slug_not_blank_check
    CHECK (slug IS NULL OR length(btrim(slug)) > 0) NOT VALID,
  ADD CONSTRAINT categories_level_range_check
    CHECK (level IS NULL OR level BETWEEN 1 AND 4) NOT VALID,
  ADD CONSTRAINT categories_lifecycle_state_check
    CHECK (
      lifecycle_state IS NULL
      OR lifecycle_state IN ('staged', 'active', 'retired')
    ) NOT VALID,
  ADD CONSTRAINT categories_policy_class_check
    CHECK (
      policy_class IS NULL
      OR policy_class IN (
        'NORMAL',
        'AGE_RESTRICTED',
        'REGULATED',
        'LEGAL_REVIEW_REQUIRED',
        'EXCLUDED'
      )
    ) NOT VALID,
  ADD CONSTRAINT categories_professional_review_status_check
    CHECK (
      professional_review_status IS NULL
      OR professional_review_status IN (
        'not_required',
        'pending',
        'approved',
        'rejected'
      )
    ) NOT VALID,
  ADD CONSTRAINT categories_not_own_parent_check
    CHECK (parent_id IS NULL OR parent_id <> id) NOT VALID;

CREATE UNIQUE INDEX IF NOT EXISTS categories_source_key_unique_idx
  ON public.categories(source_key)
  WHERE source_key IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS categories_slug_unique_idx
  ON public.categories(lower(slug))
  WHERE slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS categories_version_level_order_idx
  ON public.categories(taxonomy_version, level, parent_id, sort_order);

CREATE INDEX IF NOT EXISTS categories_public_tree_idx
  ON public.categories(parent_id, sort_order)
  WHERE is_active = true AND lifecycle_state = 'active';

CREATE TABLE IF NOT EXISTS public.taxonomy_aliases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_category_id UUID NOT NULL
    REFERENCES public.categories(id) ON DELETE RESTRICT,
  alias_type TEXT NOT NULL,
  alias_text TEXT,
  alias_slug TEXT,
  locale TEXT NOT NULL DEFAULT 'tr-TR',
  taxonomy_version TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT taxonomy_aliases_type_check
    CHECK (alias_type IN ('LEGACY_REDIRECT', 'SEARCH_SYNONYM')),
  CONSTRAINT taxonomy_aliases_value_check
    CHECK (
      length(btrim(coalesce(alias_text, ''))) > 0
      OR length(btrim(coalesce(alias_slug, ''))) > 0
    )
);

CREATE UNIQUE INDEX IF NOT EXISTS taxonomy_aliases_text_unique_idx
  ON public.taxonomy_aliases(
    alias_type,
    locale,
    lower(alias_text),
    taxonomy_version
  )
  WHERE alias_text IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS taxonomy_aliases_slug_unique_idx
  ON public.taxonomy_aliases(
    alias_type,
    locale,
    lower(alias_slug),
    taxonomy_version
  )
  WHERE alias_slug IS NOT NULL;

CREATE INDEX IF NOT EXISTS taxonomy_aliases_target_idx
  ON public.taxonomy_aliases(target_category_id);

CREATE TABLE IF NOT EXISTS public.taxonomy_node_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  predecessor_category_id UUID
    REFERENCES public.categories(id) ON DELETE RESTRICT,
  predecessor_source_locator TEXT NOT NULL,
  successor_category_id UUID
    REFERENCES public.categories(id) ON DELETE RESTRICT,
  action TEXT NOT NULL,
  target_state TEXT NOT NULL,
  classification_rule TEXT,
  confidence TEXT,
  taxonomy_version TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT taxonomy_relationship_action_check
    CHECK (action IN (
      'KEEP',
      'RENAME',
      'MOVE',
      'RENAME_AND_MOVE',
      'MERGE',
      'SPLIT',
      'RETIRE',
      'ALIAS_ONLY',
      'OUT_OF_PRODUCT_TAXONOMY',
      'UNRESOLVED'
    )),
  CONSTRAINT taxonomy_relationship_target_state_check
    CHECK (target_state IN (
      'CANONICAL_FINAL',
      'NO_TARGET_YET',
      'POLICY_REVIEW',
      'OUT_OF_SCOPE'
    )),
  CONSTRAINT taxonomy_relationship_successor_check
    CHECK (
      successor_category_id IS NOT NULL
      OR action IN (
        'RETIRE',
        'OUT_OF_PRODUCT_TAXONOMY',
        'UNRESOLVED'
      )
    )
);

CREATE INDEX IF NOT EXISTS taxonomy_relationships_predecessor_idx
  ON public.taxonomy_node_relationships(predecessor_source_locator);

CREATE INDEX IF NOT EXISTS taxonomy_relationships_successor_idx
  ON public.taxonomy_node_relationships(successor_category_id)
  WHERE successor_category_id IS NOT NULL;

ALTER TABLE public.taxonomy_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_node_relationships ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.taxonomy_aliases
  FROM anon, authenticated;
REVOKE ALL ON public.taxonomy_node_relationships
  FROM anon, authenticated;

-- Future active migration work, intentionally absent from this draft:
--
-- 1. Create a cycle/level/depth validator and validate existing rows.
-- 2. Backfill current legacy rows as a named legacy taxonomy version.
-- 3. Import __REVIEWED_CANONICAL_NODE_MANIFEST__ with preallocated UUIDs as:
--      lifecycle_state = 'staged', is_active = false.
-- 4. Import __REVIEWED_ALIAS_MANIFEST__ and
--      __REVIEWED_PREDECESSOR_SUCCESSOR_MANIFEST__.
-- 5. Create __PRODUCT_CATEGORY_MAPPING_SNAPSHOT__ and require one reviewed,
--      assignable successor per active product.
-- 6. Update products.category_id only from that snapshot. Never use the first
--      successor for a SPLIT.
-- 7. Add security-invoker root/children/descendant/alias catalog functions and
--      fail-closed product/listing publication gates.
-- 8. Validate all NOT VALID constraints, then make required canonical fields
--      non-null only after every legacy/canonical row has a declared state.
-- 9. Activation/legacy retirement belongs in a separate migration/change
--      window after the compatible client is deployed and rollback rehearsed.

COMMIT;

-- Because the guard raises inside this transaction, running this draft as-is
-- changes nothing. An authorized implementation must not merely remove the
-- guard: it must replace placeholders and pass the W34 preflight/checklists.
