BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='120s';
-- This candidate cannot be accidentally applied by db push or a remote SQL editor.
-- Removing this rehearsal-only guard requires a separate reviewed Production
-- write-decision package with verified backup/restore and the exact final hash.
DO $w52h_guard$
BEGIN
 IF current_setting('esnaftavar.w52h.execution_scope',true) IS DISTINCT FROM 'local-rehearsal'
 THEN RAISE EXCEPTION 'W52H_LOCAL_REHEARSAL_ONLY_NO_PRODUCTION_WRITE_AUTHORIZATION'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('w52h-production-canonical-adapter',0))
 THEN RAISE EXCEPTION 'W52H_SINGLE_WRITER_LOCK'; END IF;
 LOCK TABLE public.categories,public.products,public.shops,public.shop_products IN SHARE MODE;
 IF (SELECT count(*) FROM public.categories)<>4
 OR (SELECT count(*) FROM public.categories WHERE parent_id IS NULL)<>4
 OR (SELECT count(*) FROM public.products)<>20
 OR (SELECT count(*) FROM public.shop_products)<>285
 OR (SELECT count(*) FROM public.shops)<>57
 THEN RAISE EXCEPTION 'W52H_PRODUCTION_SHAPE_MISMATCH'; END IF;
 IF EXISTS(SELECT 1 FROM public.products p LEFT JOIN public.categories c ON c.id=p.category_id WHERE c.id IS NULL)
 OR EXISTS(SELECT 1 FROM public.shop_products sp LEFT JOIN public.products p ON p.id=sp.product_id LEFT JOIN public.shops s ON s.id=sp.shop_id WHERE p.id IS NULL OR s.id IS NULL)
 THEN RAISE EXCEPTION 'W52H_BASELINE_ORPHANS'; END IF;
 IF EXISTS(
  WITH expected(version,name) AS (VALUES /* EXPECTED_LEDGER */), delta AS (
   (SELECT version::text,name::text FROM supabase_migrations.schema_migrations EXCEPT SELECT * FROM expected)
   UNION ALL (SELECT * FROM expected EXCEPT SELECT version::text,name::text FROM supabase_migrations.schema_migrations)
  ) SELECT 1 FROM delta
 ) THEN RAISE EXCEPTION 'W52H_PRODUCTION_LEDGER_MISMATCH'; END IF;
 IF (SELECT count(*) FROM supabase_migrations.schema_migrations)<>9
 THEN RAISE EXCEPTION 'W52H_LEDGER_COUNT'; END IF;
 IF to_regclass('public.canonical_categories') IS NOT NULL
 OR to_regclass('public.taxonomy_id_allocations') IS NOT NULL
 OR to_regclass('public.production_taxonomy_config') IS NOT NULL
 OR to_regclass('public.product_canonical_assignments') IS NOT NULL
 THEN RAISE EXCEPTION 'W52H_ADAPTER_ALREADY_PRESENT_OR_CONFLICTING'; END IF;
END $w52h_guard$;
-- The original four categories and the original product FK remain untouched.
CREATE TABLE public.canonical_categories (
 id UUID PRIMARY KEY, name TEXT NOT NULL CHECK(length(btrim(name))>0),
 description TEXT, image_url TEXT,
 parent_id UUID REFERENCES public.canonical_categories(id) ON DELETE RESTRICT,
 sort_order INTEGER NOT NULL DEFAULT 0, is_active BOOLEAN NOT NULL DEFAULT false,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
ALTER TABLE public.canonical_categories ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.canonical_categories FROM PUBLIC,anon,authenticated,service_role;
