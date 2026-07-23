-- Esnafta Var - customer notification permissions
-- Allows signed-in users to read and mark only their own notifications as
-- read. Existing row-level security policies remain the access boundary.

BEGIN;

DO $preflight$
BEGIN
  IF to_regclass('public.notifications') IS NULL THEN
    RAISE EXCEPTION
      'public.notifications is required before notification permissions';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_class AS c
    JOIN pg_namespace AS n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'notifications'
      AND c.relrowsecurity
  ) THEN
    RAISE EXCEPTION
      'Row-level security must be enabled on public.notifications';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notifications'
      AND policyname = 'Users can view own notifications'
  ) THEN
    RAISE EXCEPTION
      'Own-notification SELECT policy is required';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'notifications'
      AND policyname = 'Users can update own notifications'
  ) THEN
    RAISE EXCEPTION
      'Own-notification UPDATE policy is required';
  END IF;
END
$preflight$;

GRANT SELECT, UPDATE
  ON TABLE public.notifications
  TO authenticated;

COMMIT;

-- Optional postflight check (read-only):
-- SELECT
--   has_table_privilege(
--     'authenticated',
--     'public.notifications',
--     'SELECT'
--   ) AS authenticated_can_select,
--   has_table_privilege(
--     'authenticated',
--     'public.notifications',
--     'UPDATE'
--   ) AS authenticated_can_update;
