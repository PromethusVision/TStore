-- ===========================================
-- Esnafta Var - profiles role migration
-- ===========================================
-- Purpose:
-- Add the first v1.0 role model to public.profiles.
--
-- Roles:
-- - customer: default app user
-- - merchant: shop owner/operator
-- - admin: trusted platform admin
--
-- This role is for UI/flow gating. Shop data security must continue to rely
-- on owner_user_id and RLS policies on shops/shop_products.
--
-- In the first pilot, merchant/admin roles should be assigned through the
-- Supabase dashboard or a trusted service-role path. Authenticated clients
-- must not be able to promote themselves to merchant/admin.
-- ===========================================

-- ====================
-- profiles.role
-- ====================
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS role TEXT;

ALTER TABLE public.profiles
  ALTER COLUMN role SET DEFAULT 'customer';

UPDATE public.profiles
  SET role = 'customer'
  WHERE role IS NULL;

ALTER TABLE public.profiles
  ALTER COLUMN role SET NOT NULL;

-- ====================
-- Role value constraint
-- ====================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'profiles_role_check'
      AND conrelid = 'public.profiles'::regclass
  ) THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_role_check
      CHECK (role IN ('customer', 'merchant', 'admin'));
  END IF;
END
$$;

-- ====================
-- Signup profile defaults
-- ====================
-- New users are explicitly created as customer profiles. This mirrors the
-- role column default and keeps signup behavior clear even if defaults change
-- later.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'phone',
    'customer'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ====================
-- Prevent client role escalation
-- ====================
-- Existing profile policies allow users to insert/update their own profile.
-- This trigger preserves normal profile edits such as full_name, phone, and
-- avatar_url, but blocks authenticated clients from setting privileged roles.
--
-- Trusted paths remain possible:
-- - Supabase dashboard/postgres execution
-- - service_role/admin server paths
DROP TRIGGER IF EXISTS trg_prevent_profile_role_self_update
  ON public.profiles;

DROP FUNCTION IF EXISTS public.prevent_profile_role_self_update();

CREATE OR REPLACE FUNCTION public.prevent_profile_role_client_escalation()
RETURNS TRIGGER AS $$
BEGIN
  IF auth.role() = 'authenticated' THEN
    IF TG_OP = 'INSERT'
       AND COALESCE(NEW.role, 'customer') <> 'customer' THEN
      RAISE EXCEPTION 'Setting privileged profile role from the client is not allowed'
        USING ERRCODE = '42501';
    END IF;

    IF TG_OP = 'UPDATE'
       AND OLD.role IS DISTINCT FROM NEW.role THEN
      RAISE EXCEPTION 'Changing profile role from the client is not allowed'
        USING ERRCODE = '42501';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_prevent_profile_role_client_escalation
  ON public.profiles;

CREATE TRIGGER trg_prevent_profile_role_client_escalation
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_profile_role_client_escalation();

-- ====================
-- Notes
-- ====================
-- No admin/shop policy is changed in this migration.
-- No client-side Flutter role mapping is added here.
-- Existing profile update policy can remain for normal profile fields because
-- role escalation is blocked for authenticated clients by the trigger above.
