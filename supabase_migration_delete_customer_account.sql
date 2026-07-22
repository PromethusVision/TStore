-- Esnafta Var - secure customer account deletion
-- Additive migration. Existing customer records are not changed when this
-- migration is installed. Data is deleted only when the signed-in customer
-- explicitly calls delete_current_customer_account().

BEGIN;

DO $preflight$
BEGIN
  IF to_regclass('public.profiles') IS NULL THEN
    RAISE EXCEPTION
      'public.profiles is required before customer account deletion migration';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'role'
  ) THEN
    RAISE EXCEPTION
      'public.profiles.role is required before customer account deletion migration';
  END IF;
END
$preflight$;

CREATE OR REPLACE FUNCTION public.delete_current_customer_account()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, auth
AS $function$
DECLARE
  v_user_id UUID := auth.uid();
  v_role TEXT;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required'
      USING ERRCODE = '28000';
  END IF;

  SELECT p.role
    INTO v_role
  FROM public.profiles AS p
  WHERE p.id = v_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Customer profile not found'
      USING ERRCODE = 'P0002';
  END IF;

  IF v_role <> 'customer' THEN
    RAISE EXCEPTION 'Only customer accounts can be deleted here'
      USING ERRCODE = '42501';
  END IF;

  -- Legacy TStore orders are not part of Esnafta Var's verified-purchase
  -- model. Removing them first avoids their old non-cascading user foreign key
  -- blocking account deletion. Their order_items are removed by cascade.
  IF to_regclass('public.orders') IS NOT NULL THEN
    EXECUTE 'DELETE FROM public.orders WHERE user_id = $1'
      USING v_user_id;
  END IF;

  -- Direct customer records use ON DELETE CASCADE. Permanent verified purchase
  -- proofs and shop ratings deliberately contain UUID snapshots without an
  -- auth.users foreign key, so commercial proof remains while profile, email,
  -- phone, messages, locations, favorites and active carts are removed.
  DELETE FROM auth.users
  WHERE id = v_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Authenticated customer account not found'
      USING ERRCODE = 'P0002';
  END IF;
END;
$function$;

REVOKE ALL ON FUNCTION public.delete_current_customer_account()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.delete_current_customer_account()
  TO authenticated;

COMMIT;

-- Optional postflight checks (read-only):
-- SELECT p.proname, p.prosecdef
-- FROM pg_proc AS p
-- JOIN pg_namespace AS n ON n.oid = p.pronamespace
-- WHERE n.nspname = 'public'
--   AND p.proname = 'delete_current_customer_account';
--
-- SELECT grantee, privilege_type
-- FROM information_schema.routine_privileges
-- WHERE routine_schema = 'public'
--   AND routine_name = 'delete_current_customer_account';
