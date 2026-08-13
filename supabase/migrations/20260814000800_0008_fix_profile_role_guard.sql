-- 0008: Repair the customer profile role guard without rewriting applied history.

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $preflight$
BEGIN
  IF to_regclass('public.profiles') IS NULL THEN
    RAISE EXCEPTION 'Missing prerequisite table: public.profiles';
  END IF;

  IF to_regprocedure(
       'public.prevent_profile_role_client_escalation()'
     ) IS NULL THEN
    RAISE EXCEPTION
      'Missing prerequisite function: public.prevent_profile_role_client_escalation()';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_trigger AS trigger_row
    JOIN pg_catalog.pg_proc AS function_proc
      ON function_proc.oid = trigger_row.tgfoid
    JOIN pg_catalog.pg_namespace AS function_namespace
      ON function_namespace.oid = function_proc.pronamespace
    WHERE trigger_row.tgrelid = 'public.profiles'::regclass
      AND trigger_row.tgname = 'prevent_profile_role_client_escalation'
      AND NOT trigger_row.tgisinternal
      AND function_namespace.nspname = 'public'
      AND function_proc.proname = 'prevent_profile_role_client_escalation'
  ) THEN
    RAISE EXCEPTION
      'Profile role guard trigger is missing or points to an unexpected function';
  END IF;
END
$preflight$;

CREATE OR REPLACE FUNCTION public.prevent_profile_role_client_escalation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $function$
BEGIN
  IF auth.role() = 'authenticated' THEN
    IF TG_OP = 'INSERT'
       AND coalesce(NEW.role, 'customer') <> 'customer' THEN
      RAISE EXCEPTION
        'Setting a privileged profile role from the client is not allowed'
        USING ERRCODE = '42501';
    END IF;

    IF TG_OP = 'UPDATE' AND OLD.role IS DISTINCT FROM NEW.role THEN
      RAISE EXCEPTION
        'Changing a profile role from the client is not allowed'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.prevent_profile_role_client_escalation()
  FROM PUBLIC, anon, authenticated;

COMMIT;
