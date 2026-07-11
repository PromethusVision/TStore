-- ===========================================
-- Esnafta Var - shops role gate preflight
-- ===========================================
-- Read-only checks to run before supabase_migration_shops_role_gate.sql.
-- Every executable statement in this file is a SELECT.
-- Run check 1 first. Later checks require public.shops and public.profiles.

-- 1. Required tables and columns
-- All four values must be true before the migration is run.
SELECT
  to_regclass('public.shops') IS NOT NULL AS shops_table_exists,
  to_regclass('public.profiles') IS NOT NULL AS profiles_table_exists,
  EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'shops'
      AND column_name = 'owner_user_id'
  ) AS shops_owner_user_id_exists,
  EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'role'
  ) AS profiles_role_exists;

-- 2. RLS status
-- Both rows must exist and rls_enabled must be true.
SELECT
  n.nspname AS schema_name,
  c.relname AS table_name,
  c.relrowsecurity AS rls_enabled,
  c.relforcerowsecurity AS rls_forced
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE n.nspname = 'public'
  AND c.relname IN ('shops', 'profiles')
  AND c.relkind IN ('r', 'p')
ORDER BY c.relname;

-- 3. Duplicate non-null shop owners
-- No rows means the one-shop-per-owner index can be created safely.
SELECT
  owner_user_id,
  COUNT(*) AS shop_count,
  ARRAY_AGG(id ORDER BY id) AS shop_ids
FROM public.shops
WHERE owner_user_id IS NOT NULL
GROUP BY owner_user_id
HAVING COUNT(*) > 1
ORDER BY owner_user_id;

-- 4. All current public.shops policies
-- Review every write policy because permissive policies combine with OR logic.
SELECT
  policyname,
  cmd,
  roles,
  permissive,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'shops'
ORDER BY cmd, policyname;

-- 5. Expected legacy write policy names
-- All three rows should normally report policy_exists = true before migration.
SELECT
  expected.policyname AS expected_policy_name,
  expected.cmd AS expected_command,
  (actual.policyname IS NOT NULL) AS policy_exists,
  actual.permissive,
  actual.roles,
  actual.qual,
  actual.with_check
FROM (
  SELECT *
  FROM UNNEST(
    ARRAY[
      'Shop owners can create own shops',
      'Shop owners can update own shops',
      'Shop owners can delete own shops'
    ],
    ARRAY['INSERT', 'UPDATE', 'DELETE']
  ) AS expected_policies(policyname, cmd)
) AS expected
LEFT JOIN pg_policies AS actual
  ON actual.schemaname = 'public'
  AND actual.tablename = 'shops'
  AND actual.policyname = expected.policyname
  AND actual.cmd = expected.cmd
ORDER BY expected.cmd;

-- 6. Unexpected shops write policies
-- No rows is ideal. Any PERMISSIVE result is a role-gate bypass blocker.
SELECT
  policyname,
  cmd,
  roles,
  permissive,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'shops'
  AND cmd IN ('INSERT', 'UPDATE', 'DELETE')
  AND (policyname, cmd) NOT IN (
    ('Shop owners can create own shops', 'INSERT'),
    ('Shop owners can update own shops', 'UPDATE'),
    ('Shop owners can delete own shops', 'DELETE')
  )
ORDER BY cmd, policyname;

-- 7. Existing one-shop-per-owner index definition
-- No row means the index is absent. If present, verify UNIQUE and the
-- owner_user_id IS NOT NULL predicate in indexdef.
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'shops'
  AND indexname = 'shops_owner_user_id_unique_idx';

-- 8. Null-owner demo shops
-- This count is informational; these rows remain outside the partial index.
SELECT
  COUNT(*) AS null_owner_shop_count
FROM public.shops
WHERE owner_user_id IS NULL;

-- 9. Shops and their owner profile roles
-- A null profile_role exposes a missing profile or a null role.
SELECT
  s.id AS shop_id,
  s.name AS shop_name,
  s.owner_user_id,
  p.role AS profile_role
FROM public.shops AS s
LEFT JOIN public.profiles AS p ON p.id = s.owner_user_id
WHERE s.owner_user_id IS NOT NULL
ORDER BY s.name, s.id;

-- 10. Owners that cannot pass the new role gate
-- No rows means every owned shop has a merchant/admin profile.
SELECT
  s.id AS shop_id,
  s.name AS shop_name,
  s.owner_user_id,
  p.role AS profile_role,
  CASE
    WHEN p.id IS NULL THEN 'missing_profile'
    WHEN p.role IS NULL THEN 'null_role'
    WHEN p.role = 'customer' THEN 'customer_role'
    ELSE 'unsupported_role'
  END AS incompatibility
FROM public.shops AS s
LEFT JOIN public.profiles AS p ON p.id = s.owner_user_id
WHERE s.owner_user_id IS NOT NULL
  AND (
    p.id IS NULL
    OR p.role IS NULL
    OR p.role NOT IN ('merchant', 'admin')
  )
ORDER BY s.name, s.id;

-- 11. Profile role distribution
-- Expected roles are shown even when their count is zero; unexpected and null
-- values are also included when present.
SELECT
  roles.role_name AS role,
  COALESCE(actual.user_count, 0) AS user_count
FROM (
  SELECT UNNEST(ARRAY['customer', 'merchant', 'admin']) AS role_name
  UNION
  SELECT COALESCE(role, '<NULL>') AS role_name
  FROM public.profiles
) AS roles
LEFT JOIN (
  SELECT
    COALESCE(role, '<NULL>') AS role_name,
    COUNT(*) AS user_count
  FROM public.profiles
  GROUP BY COALESCE(role, '<NULL>')
) AS actual ON actual.role_name = roles.role_name
ORDER BY
  CASE roles.role_name
    WHEN 'customer' THEN 1
    WHEN 'merchant' THEN 2
    WHEN 'admin' THEN 3
    ELSE 4
  END,
  roles.role_name;

-- 12. Check constraints that reference profiles.role
-- profiles_role_check should restrict values to customer, merchant, and admin.
SELECT
  con.conname AS constraint_name,
  pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_constraint AS con
JOIN pg_class AS cls ON cls.oid = con.conrelid
JOIN pg_namespace AS nsp ON nsp.oid = cls.relnamespace
WHERE nsp.nspname = 'public'
  AND cls.relname = 'profiles'
  AND con.contype = 'c'
  AND pg_get_constraintdef(con.oid, true) ILIKE '%role%'
ORDER BY con.conname;

-- 13. Non-internal triggers on public.profiles
-- Confirm trg_prevent_profile_role_client_escalation is present and enabled.
SELECT
  trg.tgname AS trigger_name,
  trg.tgenabled AS enabled_state,
  pg_get_triggerdef(trg.oid, true) AS trigger_definition
FROM pg_trigger AS trg
JOIN pg_class AS cls ON cls.oid = trg.tgrelid
JOIN pg_namespace AS nsp ON nsp.oid = cls.relnamespace
WHERE nsp.nspname = 'public'
  AND cls.relname = 'profiles'
  AND NOT trg.tgisinternal
ORDER BY trg.tgname;

-- 14. Role escalation guard function
-- One row should exist and security_definer should be true. Review the full
-- definition for authenticated INSERT and UPDATE protections.
SELECT
  nsp.nspname AS function_schema,
  proc.proname AS function_name,
  proc.prosecdef AS security_definer,
  pg_get_functiondef(proc.oid) AS function_definition
FROM pg_proc AS proc
JOIN pg_namespace AS nsp ON nsp.oid = proc.pronamespace
WHERE nsp.nspname = 'public'
  AND proc.proname = 'prevent_profile_role_client_escalation'
ORDER BY pg_get_function_identity_arguments(proc.oid);

-- 15. authenticated SELECT grant on public.profiles
-- has_profiles_select must be true for direct role lookup in shops RLS.
SELECT
  'authenticated' AS database_role,
  has_table_privilege(
    'authenticated',
    'public.profiles',
    'SELECT'
  ) AS has_profiles_select;

-- 16. authenticated write grants on public.shops
-- Grants should be true for the intended app flow. They do not bypass RLS.
SELECT
  'authenticated' AS database_role,
  has_table_privilege(
    'authenticated',
    'public.shops',
    'INSERT'
  ) AS has_shops_insert,
  has_table_privilege(
    'authenticated',
    'public.shops',
    'UPDATE'
  ) AS has_shops_update,
  has_table_privilege(
    'authenticated',
    'public.shops',
    'DELETE'
  ) AS has_shops_delete;
