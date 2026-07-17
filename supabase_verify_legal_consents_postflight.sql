\set ON_ERROR_STOP on

BEGIN READ ONLY;

SELECT json_build_object(
  'legal_consents_exists',
  to_regclass('public.legal_consents') IS NOT NULL,
  'row_level_security_enabled',
  COALESCE(
    (
      SELECT relrowsecurity
      FROM pg_class
      WHERE oid = to_regclass('public.legal_consents')
    ),
    false
  ),
  'required_columns_exist',
  (
    SELECT count(*) = 6
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'legal_consents'
      AND column_name IN (
        'id',
        'user_id',
        'document_type',
        'document_version',
        'source',
        'accepted_at'
      )
  ),
  'required_constraints_exist',
  (
    SELECT count(*) = 4
    FROM pg_constraint
    WHERE conrelid = to_regclass('public.legal_consents')
      AND conname IN (
        'legal_consents_document_type_check',
        'legal_consents_document_version_not_empty',
        'legal_consents_source_check',
        'legal_consents_user_document_version_unique'
      )
  ),
  'own_records_select_policy_exists',
  EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'legal_consents'
      AND policyname = 'Customers can view own legal consents'
      AND cmd = 'SELECT'
      AND roles = ARRAY['authenticated']::name[]
      AND qual = '(user_id = auth.uid())'
  ),
  'authenticated_can_only_select',
  has_table_privilege(
    'authenticated',
    'public.legal_consents',
    'SELECT'
  )
  AND NOT has_table_privilege(
    'authenticated',
    'public.legal_consents',
    'INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'
  ),
  'anonymous_has_no_table_privileges',
  NOT has_table_privilege(
    'anon',
    'public.legal_consents',
    'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'
  ),
  'signup_trigger_exists',
  EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'on_auth_user_created'
      AND tgrelid = 'auth.users'::regclass
      AND NOT tgisinternal
  ),
  'signup_function_is_security_definer',
  COALESCE(
    (
      SELECT prosecdef
      FROM pg_proc
      WHERE oid = to_regprocedure('public.handle_new_user()')
    ),
    false
  ),
  'signup_preserves_customer_role',
  COALESCE(
    position(
      '''customer''' IN pg_get_functiondef(
        to_regprocedure('public.handle_new_user()')
      )
    ) > 0,
    false
  ),
  'signup_records_privacy_version',
  COALESCE(
    position(
      '''privacy_notice_acknowledged''' IN pg_get_functiondef(
        to_regprocedure('public.handle_new_user()')
      )
    ) > 0
    AND position(
      '''2026-07-17''' IN pg_get_functiondef(
        to_regprocedure('public.handle_new_user()')
      )
    ) > 0,
    false
  ),
  'signup_records_terms_version',
  COALESCE(
    position(
      '''terms_of_use_accepted''' IN pg_get_functiondef(
        to_regprocedure('public.handle_new_user()')
      )
    ) > 0
    AND position(
      '''2026-07-17''' IN pg_get_functiondef(
        to_regprocedure('public.handle_new_user()')
      )
    ) > 0,
    false
  ),
  'no_existing_rows_backfilled',
  NOT EXISTS (
    SELECT 1
    FROM public.legal_consents
  )
) AS legal_consents_postflight;

COMMIT;
