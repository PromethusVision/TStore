-- ===========================================
-- Esnafta Var - customer legal consent records
-- ===========================================
-- Purpose:
-- - Keep privacy notice acknowledgement and terms acceptance separate.
-- - Record the exact document version at account creation time.
-- - Prevent authenticated clients from modifying consent evidence.
-- - Preserve the existing customer role assignment in handle_new_user().
--
-- This migration does not backfill existing users and does not modify
-- existing profile or authentication records.
-- ===========================================

BEGIN;

-- ====================
-- Preconditions
-- ====================
DO $$
BEGIN
  IF to_regclass('public.profiles') IS NULL THEN
    RAISE EXCEPTION 'public.profiles is required before legal consents migration'
      USING ERRCODE = '42P01';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'profiles'
      AND column_name = 'role'
  ) THEN
    RAISE EXCEPTION 'public.profiles.role is required before legal consents migration'
      USING ERRCODE = '42703';
  END IF;
END
$$;

-- ====================
-- Immutable consent evidence
-- ====================
CREATE TABLE IF NOT EXISTS public.legal_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL,
  document_version TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'customer_signup',
  accepted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT legal_consents_document_type_check
    CHECK (
      document_type IN (
        'privacy_notice_acknowledged',
        'terms_of_use_accepted'
      )
    ),
  CONSTRAINT legal_consents_document_version_not_empty
    CHECK (length(btrim(document_version)) > 0),
  CONSTRAINT legal_consents_source_check
    CHECK (source IN ('customer_signup')),
  CONSTRAINT legal_consents_user_document_version_unique
    UNIQUE (user_id, document_type, document_version)
);

CREATE INDEX IF NOT EXISTS legal_consents_user_accepted_at_idx
  ON public.legal_consents(user_id, accepted_at DESC);

ALTER TABLE public.legal_consents ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.legal_consents FROM anon;
REVOKE ALL ON TABLE public.legal_consents FROM authenticated;
GRANT SELECT ON TABLE public.legal_consents TO authenticated;

DROP POLICY IF EXISTS "Customers can view own legal consents"
  ON public.legal_consents;

CREATE POLICY "Customers can view own legal consents"
  ON public.legal_consents
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- ====================
-- Account creation
-- ====================
-- The client sends the accepted versions in auth user metadata. The trigger
-- accepts only the document versions shipped with this migration, records
-- the database timestamp, and still creates every new profile as customer.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone',
    'customer'
  );

  IF NEW.raw_user_meta_data->>'privacy_notice_acknowledged' = 'true'
     AND NEW.raw_user_meta_data->>'privacy_notice_version' = '2026-07-17' THEN
    INSERT INTO public.legal_consents (
      user_id,
      document_type,
      document_version
    )
    VALUES (
      NEW.id,
      'privacy_notice_acknowledged',
      '2026-07-17'
    )
    ON CONFLICT (user_id, document_type, document_version) DO NOTHING;
  END IF;

  IF NEW.raw_user_meta_data->>'terms_of_use_accepted' = 'true'
     AND NEW.raw_user_meta_data->>'terms_of_use_version' = '2026-07-17' THEN
    INSERT INTO public.legal_consents (
      user_id,
      document_type,
      document_version
    )
    VALUES (
      NEW.id,
      'terms_of_use_accepted',
      '2026-07-17'
    )
    ON CONFLICT (user_id, document_type, document_version) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

COMMIT;

-- ====================
-- Read-only verification
-- ====================
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public'
--   AND table_name = 'legal_consents'
-- ORDER BY ordinal_position;
--
-- SELECT policyname, cmd, roles
-- FROM pg_policies
-- WHERE schemaname = 'public'
--   AND tablename = 'legal_consents';
--
-- SELECT routine_name, security_type
-- FROM information_schema.routines
-- WHERE routine_schema = 'public'
--   AND routine_name = 'handle_new_user';
