-- DRAFT: local rehearsal only. Not in the automatic migrations directory.
-- Requires separate deployment authorization. No seed, trigger, reward or QR rule.
BEGIN;

-- Extend the existing banners contract; legacy rows remain version 1.
ALTER TABLE public.banners
  ADD COLUMN content_version integer NOT NULL DEFAULT 1 CHECK (content_version IN (1, 2)),
  ADD COLUMN cta_text text CHECK (length(cta_text) <= 48),
  ADD COLUMN audience text NOT NULL DEFAULT 'general'
    CHECK (audience IN ('general', 'customer', 'merchant')),
  ADD COLUMN category_scope text,
  ADD COLUMN city text,
  ADD COLUMN district text;
-- Existing action_type/action_url = target_type/target_value; sort_order = priority.
-- Empty image_url is permitted for the V2 local illustration. No stock-row upgrade.
ALTER TABLE public.banners ADD CONSTRAINT banners_v2_copy CHECK (
  content_version <> 2 OR (title IS NOT NULL AND length(btrim(title)) BETWEEN 1 AND 120
    AND subtitle IS NOT NULL AND length(btrim(subtitle)) BETWEEN 1 AND 300));

CREATE TABLE public.push_devices (
  installation_id uuid NOT NULL,
  app_role text NOT NULL CHECK (app_role IN ('customer', 'merchant')),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  push_token text NOT NULL UNIQUE CHECK (length(push_token) BETWEEN 1 AND 4096
    AND push_token !~ '[[:space:][:cntrl:]]'),
  platform text NOT NULL CHECK (platform IN ('android', 'ios')),
  enabled boolean NOT NULL DEFAULT true,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (installation_id, app_role)
);
CREATE INDEX push_devices_recipient ON public.push_devices(user_id, app_role) WHERE enabled;
ALTER TABLE public.push_devices ENABLE ROW LEVEL SECURITY;
-- Deliberately no client SELECT policy: even own device tokens are not listable.
REVOKE ALL ON public.push_devices FROM PUBLIC, anon, authenticated;
GRANT SELECT, UPDATE(enabled, updated_at) ON public.push_devices TO service_role;

CREATE TABLE public.notification_preferences (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  app_role text NOT NULL CHECK (app_role IN ('customer', 'merchant')),
  service_enabled boolean NOT NULL DEFAULT true,
  marketing_enabled boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, app_role)
);
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.notification_preferences FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.notification_preferences TO authenticated, service_role;
CREATE POLICY notification_preferences_read_own ON public.notification_preferences
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

-- Durable server-side idempotency, tied to the existing notification domain.
CREATE TABLE public.push_deliveries (
  notification_id uuid NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
  installation_id uuid NOT NULL,
  app_role text NOT NULL CHECK (app_role IN ('customer', 'merchant')),
  outcome text NOT NULL DEFAULT 'pending' CHECK (outcome IN ('pending', 'sent', 'failed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (notification_id, installation_id, app_role)
);
ALTER TABLE public.push_deliveries ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.push_deliveries FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE(outcome, updated_at) ON public.push_deliveries TO service_role;

CREATE FUNCTION public._assert_push_identity_v1(p_app_role text) RETURNS uuid
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_user uuid := auth.uid();
BEGIN
  IF v_user IS NULL OR p_app_role IS NULL OR p_app_role NOT IN ('customer','merchant')
    OR NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = v_user AND role = p_app_role) THEN
    RAISE EXCEPTION USING ERRCODE = '42501', MESSAGE = 'push_identity_denied';
  END IF;
  RETURN v_user;
END $$;
REVOKE ALL ON FUNCTION public._assert_push_identity_v1(text) FROM PUBLIC, anon, authenticated;

CREATE FUNCTION public.register_push_device_v1(p_installation_id uuid,
  p_app_role text, p_push_token text, p_platform text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_user uuid := public._assert_push_identity_v1(p_app_role);
BEGIN
  IF p_installation_id IS NULL OR p_push_token IS NULL OR p_platform IS NULL
    OR length(p_push_token) NOT BETWEEN 1 AND 4096 OR p_push_token ~ '[[:space:][:cntrl:]]'
    OR p_platform NOT IN ('android', 'ios') THEN
    RAISE EXCEPTION USING ERRCODE = '22023', MESSAGE = 'push_device_invalid';
  END IF;
  INSERT INTO public.push_devices(installation_id, app_role, user_id, push_token, platform)
    VALUES (p_installation_id, p_app_role, v_user, p_push_token, p_platform)
  ON CONFLICT (installation_id, app_role) DO UPDATE SET
    user_id = EXCLUDED.user_id, push_token = EXCLUDED.push_token,
    platform = EXCLUDED.platform, enabled = true, last_seen_at = now(), updated_at = now()
  WHERE push_devices.user_id = v_user OR NOT push_devices.enabled;
  IF NOT FOUND THEN
    RAISE EXCEPTION USING ERRCODE = '42501', MESSAGE = 'push_device_owned';
  END IF;
EXCEPTION WHEN unique_violation THEN
  -- Do not echo another owner's token in an error detail.
  RAISE EXCEPTION USING ERRCODE = '42501', MESSAGE = 'push_device_unavailable';
END $$;

CREATE FUNCTION public.disable_push_device_v1(p_installation_id uuid, p_app_role text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_user uuid := public._assert_push_identity_v1(p_app_role);
BEGIN
  UPDATE public.push_devices SET enabled = false, updated_at = now()
    WHERE installation_id = p_installation_id AND app_role = p_app_role AND user_id = v_user;
END $$;

CREATE FUNCTION public.set_notification_preferences_v1(p_app_role text, p_service boolean,
  p_marketing boolean) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
DECLARE v_user uuid := public._assert_push_identity_v1(p_app_role);
BEGIN
  IF p_service IS NULL OR p_marketing IS NULL THEN
    RAISE EXCEPTION USING ERRCODE = '22023', MESSAGE = 'notification_preferences_invalid';
  END IF;
  INSERT INTO public.notification_preferences(user_id, app_role, service_enabled, marketing_enabled)
    VALUES (v_user, p_app_role, p_service, p_marketing)
  ON CONFLICT (user_id, app_role) DO UPDATE SET service_enabled = EXCLUDED.service_enabled,
    marketing_enabled = EXCLUDED.marketing_enabled, updated_at = now();
END $$;

REVOKE ALL ON FUNCTION public.register_push_device_v1(uuid,text,text,text),
  public.disable_push_device_v1(uuid,text), public.set_notification_preferences_v1(text,boolean,boolean)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.register_push_device_v1(uuid,text,text,text),
  public.disable_push_device_v1(uuid,text), public.set_notification_preferences_v1(text,boolean,boolean)
  TO authenticated;
COMMIT;
