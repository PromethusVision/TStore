-- ===========================================
-- Esnafta Var - shops role gate + one shop per owner
-- ===========================================
-- Purpose:
-- Harden public.shops writes before enabling My Shop create/update flows.
--
-- Security goals:
-- - Only merchant/admin users can create, update, or delete their own shop.
-- - Admin users do not receive global shop management in this migration.
-- - owner_user_id remains nullable so demo shops with NULL owners are not
--   modified.
-- - A non-null owner_user_id can own at most one shop.
--
-- This migration is intentionally limited to public.shops.
-- It does not modify shop_products, rating/is_active behavior, Flutter code,
-- or existing shop rows.
-- ===========================================

BEGIN;

-- ====================
-- Preconditions
-- ====================
DO $$
DECLARE
  duplicate_owners TEXT;
BEGIN
  IF to_regclass('public.profiles') IS NULL THEN
    RAISE EXCEPTION 'public.profiles table is required before running shops role gate migration'
      USING ERRCODE = '42P01';
  END IF;

  IF to_regclass('public.shops') IS NULL THEN
    RAISE EXCEPTION 'public.shops table is required before running shops role gate migration'
      USING ERRCODE = '42P01';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'role'
  ) THEN
    RAISE EXCEPTION 'public.profiles.role is required before running shops role gate migration'
      USING ERRCODE = '42703';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'shops'
      AND column_name = 'owner_user_id'
  ) THEN
    RAISE EXCEPTION 'public.shops.owner_user_id is required before running shops role gate migration'
      USING ERRCODE = '42703';
  END IF;

  SELECT string_agg(owner_user_id::TEXT || ' (' || shop_count || ' shops)', ', ')
    INTO duplicate_owners
  FROM (
    SELECT owner_user_id, COUNT(*) AS shop_count
    FROM public.shops
    WHERE owner_user_id IS NOT NULL
    GROUP BY owner_user_id
    HAVING COUNT(*) > 1
  ) AS duplicate_owner_rows;

  IF duplicate_owners IS NOT NULL THEN
    RAISE EXCEPTION
      'Duplicate shops found for owner_user_id values: %. Resolve duplicate owner shops manually before running this migration.',
      duplicate_owners
      USING ERRCODE = '23505';
  END IF;
END
$$;

ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY;

-- ====================
-- One shop per non-null owner
-- ====================
-- NULL owner_user_id demo shops are intentionally outside this index.
CREATE UNIQUE INDEX IF NOT EXISTS shops_owner_user_id_unique_idx
  ON public.shops(owner_user_id)
  WHERE owner_user_id IS NOT NULL;

-- ====================
-- Role-gated owner write policies
-- ====================
-- Public read and owner read policies are intentionally left unchanged.
-- Role lookup uses public.profiles.id = auth.uid(); the existing own-profile
-- SELECT policy allows users to read their own profile role and does not create
-- shops/profiles RLS recursion.

DROP POLICY IF EXISTS "Shop owners can create own shops" ON public.shops;
DROP POLICY IF EXISTS "Shop owners can update own shops" ON public.shops;
DROP POLICY IF EXISTS "Shop owners can delete own shops" ON public.shops;

CREATE POLICY "Shop owners can create own shops"
  ON public.shops
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role IN ('merchant', 'admin')
    )
  );

CREATE POLICY "Shop owners can update own shops"
  ON public.shops
  FOR UPDATE
  TO authenticated
  USING (
    owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role IN ('merchant', 'admin')
    )
  )
  WITH CHECK (
    owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role IN ('merchant', 'admin')
    )
  );

CREATE POLICY "Shop owners can delete own shops"
  ON public.shops
  FOR DELETE
  TO authenticated
  USING (
    owner_user_id = auth.uid()
    AND EXISTS (
      SELECT 1
      FROM public.profiles AS p
      WHERE p.id = auth.uid()
        AND p.role IN ('merchant', 'admin')
    )
  );

COMMIT;

-- ====================
-- Manual verification queries
-- ====================
-- 1. Duplicate owner check:
-- SELECT owner_user_id, COUNT(*) AS shop_count
-- FROM public.shops
-- WHERE owner_user_id IS NOT NULL
-- GROUP BY owner_user_id
-- HAVING COUNT(*) > 1;
--
-- 2. Partial unique index exists:
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE schemaname = 'public'
--   AND tablename = 'shops'
--   AND indexname = 'shops_owner_user_id_unique_idx';
--
-- 3. RLS is enabled on public.shops:
-- SELECT relrowsecurity
-- FROM pg_class
-- WHERE oid = 'public.shops'::regclass;
--
-- 4. shops policy list:
-- SELECT policyname, cmd, roles
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename = 'shops'
-- ORDER BY policyname;
--
-- 5. INSERT/UPDATE/DELETE policy definitions:
-- SELECT policyname, cmd, qual, with_check
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename = 'shops'
--   AND cmd IN ('INSERT', 'UPDATE', 'DELETE')
-- ORDER BY policyname;
--
-- 6. NULL owner demo shops:
-- SELECT COUNT(*) AS null_owner_shop_count
-- FROM public.shops
-- WHERE owner_user_id IS NULL;
--
-- 7. Role distribution:
-- SELECT role, COUNT(*) AS user_count
-- FROM public.profiles
-- GROUP BY role
-- ORDER BY role;
