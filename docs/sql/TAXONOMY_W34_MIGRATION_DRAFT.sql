-- TAXONOMY W34 MIGRATION DRAFT
-- STATUS: NOT EXECUTED / NOT AN ACTIVE SUPABASE MIGRATION
-- LOCATION CONTRACT: docs/sql only; never apply this file as-is.
-- BASE: origin/main@6415f09c8b84d3ef1c72d642c1908c433b534994
--
-- This draft deliberately aborts its own transaction. It contains no canonical
-- node UUID payload and no product reassignment payload. A future authorized
-- task must split schema/import/activation into reviewed active migrations.
-- Wave 35 local rehearsal hardened hierarchy validation and replaced the
-- unsafe single-target alias shape with locator + zero/one/many target edges.
-- The hardened PostgreSQL draft has still NOT been executed locally or remotely.

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

CREATE TABLE IF NOT EXISTS public.taxonomy_id_allocations (
  planning_key TEXT PRIMARY KEY,
  category_id UUID NOT NULL UNIQUE
    REFERENCES public.categories(id) ON DELETE RESTRICT
    DEFERRABLE INITIALLY DEFERRED,
  taxonomy_version TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT taxonomy_id_allocations_key_not_blank_check
    CHECK (length(btrim(planning_key)) > 0)
);

CREATE OR REPLACE FUNCTION public.validate_taxonomy_category_hierarchy()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $taxonomy_hierarchy$
DECLARE
  parent_level SMALLINT;
  cycle_found BOOLEAN;
BEGIN
  -- Legacy compatibility rows may remain NULL during the additive phase.
  IF NEW.level IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.level = 1 THEN
    IF NEW.parent_id IS NOT NULL THEN
      RAISE EXCEPTION 'L1 taxonomy category cannot have a parent';
    END IF;
    RETURN NEW;
  END IF;

  IF NEW.parent_id IS NULL THEN
    RAISE EXCEPTION 'L2-L4 taxonomy category requires a parent';
  END IF;

  IF NEW.parent_id = NEW.id THEN
    RAISE EXCEPTION 'taxonomy category cannot parent itself';
  END IF;

  SELECT level INTO parent_level
  FROM public.categories
  WHERE id = NEW.parent_id;

  IF NOT FOUND OR parent_level IS NULL OR parent_level <> NEW.level - 1 THEN
    RAISE EXCEPTION 'taxonomy parent level mismatch';
  END IF;

  WITH RECURSIVE ancestors(id, parent_id) AS (
    SELECT id, parent_id
    FROM public.categories
    WHERE id = NEW.parent_id
    UNION ALL
    SELECT category.id, category.parent_id
    FROM public.categories AS category
    JOIN ancestors ON category.id = ancestors.parent_id
  )
  SELECT EXISTS (SELECT 1 FROM ancestors WHERE id = NEW.id)
  INTO cycle_found;

  IF cycle_found THEN
    RAISE EXCEPTION 'taxonomy category cycle detected';
  END IF;

  RETURN NEW;
END
$taxonomy_hierarchy$;

DROP TRIGGER IF EXISTS validate_taxonomy_category_hierarchy
  ON public.categories;
CREATE TRIGGER validate_taxonomy_category_hierarchy
  BEFORE INSERT OR UPDATE OF parent_id, level
  ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_taxonomy_category_hierarchy();

CREATE TABLE IF NOT EXISTS public.taxonomy_aliases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  alias_kind TEXT NOT NULL,
  alias_locator TEXT NOT NULL,
  alias_text TEXT,
  alias_slug TEXT,
  alias_path TEXT,
  source_alias_type TEXT,
  resolution_state TEXT NOT NULL,
  direct_target_category_id UUID
    REFERENCES public.categories(id) ON DELETE RESTRICT,
  locale TEXT NOT NULL DEFAULT 'tr-TR',
  taxonomy_version TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT taxonomy_aliases_kind_check
    CHECK (alias_kind IN ('LEGACY_REDIRECT', 'SEARCH_SYNONYM')),
  CONSTRAINT taxonomy_aliases_locator_not_blank_check
    CHECK (length(btrim(alias_locator)) > 0),
  CONSTRAINT taxonomy_aliases_resolution_check
    CHECK (resolution_state IN (
      'RESOLVED',
      'AMBIGUOUS',
      'TOMBSTONE',
      'UNRESOLVED'
    )),
  CONSTRAINT taxonomy_aliases_value_check
    CHECK (
      length(btrim(coalesce(alias_text, ''))) > 0
      OR length(btrim(coalesce(alias_slug, ''))) > 0
    ),
  CONSTRAINT taxonomy_aliases_target_check
    CHECK (
      (resolution_state = 'RESOLVED' AND direct_target_category_id IS NOT NULL)
      OR (resolution_state <> 'RESOLVED' AND direct_target_category_id IS NULL)
    ),
  CONSTRAINT taxonomy_aliases_locator_key
    UNIQUE (alias_kind, alias_locator, taxonomy_version)
);

CREATE INDEX IF NOT EXISTS taxonomy_aliases_direct_target_idx
  ON public.taxonomy_aliases(direct_target_category_id)
  WHERE direct_target_category_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS taxonomy_aliases_slug_lookup_idx
  ON public.taxonomy_aliases(alias_kind, locale, lower(alias_slug))
  WHERE alias_slug IS NOT NULL AND is_active = true;

CREATE TABLE IF NOT EXISTS public.taxonomy_alias_targets (
  alias_id UUID NOT NULL
    REFERENCES public.taxonomy_aliases(id) ON DELETE CASCADE,
  target_category_id UUID NOT NULL
    REFERENCES public.categories(id) ON DELETE RESTRICT,
  PRIMARY KEY (alias_id, target_category_id)
);

CREATE INDEX IF NOT EXISTS taxonomy_alias_targets_target_idx
  ON public.taxonomy_alias_targets(target_category_id);

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
      'OUT',
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
        'OUT',
        'UNRESOLVED'
      )
    )
);

CREATE INDEX IF NOT EXISTS taxonomy_relationships_predecessor_idx
  ON public.taxonomy_node_relationships(predecessor_source_locator);

CREATE UNIQUE INDEX IF NOT EXISTS taxonomy_relationship_edge_unique_idx
  ON public.taxonomy_node_relationships(
    predecessor_source_locator,
    (coalesce(successor_category_id::TEXT, '')),
    action,
    taxonomy_version
  );

CREATE INDEX IF NOT EXISTS taxonomy_relationships_successor_idx
  ON public.taxonomy_node_relationships(successor_category_id)
  WHERE successor_category_id IS NOT NULL;

ALTER TABLE public.taxonomy_id_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_alias_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taxonomy_node_relationships ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.taxonomy_id_allocations
  FROM anon, authenticated;
REVOKE ALL ON public.taxonomy_aliases
  FROM anon, authenticated;
REVOKE ALL ON public.taxonomy_alias_targets
  FROM anon, authenticated;
REVOKE ALL ON public.taxonomy_node_relationships
  FROM anon, authenticated;

-- Future active migration work, intentionally absent from this draft:
--
-- 1. Validate all existing rows with the cycle/level/depth validator.
-- 2. Backfill current legacy rows as a named legacy taxonomy version.
-- 3. Import __REVIEWED_CANONICAL_NODE_MANIFEST__ with preallocated UUIDs as:
--      lifecycle_state = 'staged', is_active = false.
-- 4. Import __REVIEWED_ALIAS_MANIFEST__ as one locator row plus zero/one/many
--      alias target edges. A split alias remains AMBIGUOUS with no direct target.
--      Import __REVIEWED_PREDECESSOR_SUCCESSOR_MANIFEST__ separately.
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
