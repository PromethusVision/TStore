\set ON_ERROR_STOP on

BEGIN READ ONLY;

SELECT json_build_object(
  'profiles_exists',
  to_regclass('public.profiles') IS NOT NULL,
  'profiles_role_exists',
  EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'role'
  ),
  'signup_trigger_exists',
  EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'on_auth_user_created'
      AND tgrelid = 'auth.users'::regclass
      AND NOT tgisinternal
  ),
  'signup_function_exists',
  to_regprocedure('public.handle_new_user()') IS NOT NULL,
  'signup_preserves_customer_role',
  COALESCE(
    position(
      '''customer''' IN pg_get_functiondef(
        to_regprocedure('public.handle_new_user()')
      )
    ) > 0,
    false
  ),
  'legal_consents_exists_before_migration',
  to_regclass('public.legal_consents') IS NOT NULL
) AS legal_consents_preflight;

COMMIT;
