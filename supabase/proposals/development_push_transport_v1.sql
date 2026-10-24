-- DEVELOPMENT PUSH TRANSPORT V1 — separate reviewed proposal, NOT applied.
-- Only transport tables/RPCs; no banners, commerce, reward, review or QR activation.
-- Source LF SHA256 0016: 7739e6f081f0f7e3098b27855b2f22fe4119ffe72cd288e36e60484a090d6302
-- Source LF SHA256 0029: 4aeb04ecbd90959580c6e6ef5ae50560e093f42f3828a3d79301a16be65fbed7
-- Session semantics copied from integrated 0018 under a transport-owned name.
-- Historical sources remain untouched. Default dispatch gate stays OFF.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
DO $preflight$ BEGIN
 IF to_regclass('public.notifications') IS NULL OR to_regclass('auth.sessions') IS NULL
 OR to_regclass('public.push_devices') IS NOT NULL
 OR to_regclass('public.push_deliveries') IS NOT NULL
 OR to_regclass('public.notification_preferences') IS NOT NULL
 OR to_regclass('public.push_dispatch_config') IS NOT NULL THEN
  RAISE EXCEPTION 'Development push requires an inspected fresh transport baseline';
 END IF;
END $preflight$;
CREATE FUNCTION public._push_auth_session_development_v1() RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $body$
DECLARE sid uuid; BEGIN
  IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' THEN
    RAISE EXCEPTION 'Authentication required' USING ERRCODE='28000'; END IF;
  sid := (auth.jwt()->>'session_id')::uuid;
  PERFORM s.id FROM auth.sessions s WHERE s.id=sid AND s.user_id=auth.uid()
    AND (s.not_after IS NULL OR s.not_after>clock_timestamp()) FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Live authentication session required' USING ERRCODE='28000'; END IF;
  RETURN sid;
END $body$;
REVOKE ALL ON FUNCTION public._push_auth_session_development_v1() FROM PUBLIC,anon,authenticated,service_role;
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


SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
DO $preflight$ BEGIN
 IF to_regclass('public.push_deliveries') IS NULL
 OR to_regprocedure('public._push_auth_session_development_v1()') IS NULL THEN
   RAISE EXCEPTION 'I0 requires unchanged engagement 0016 and integrated live Auth contract';
 END IF;
END $preflight$;

CREATE TABLE public.push_dispatch_config (
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
 enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.push_dispatch_config DEFAULT VALUES;
ALTER TABLE public.push_dispatch_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.push_dispatch_config FROM PUBLIC,anon,authenticated,service_role;

ALTER TABLE public.push_devices ADD COLUMN revision uuid NOT NULL DEFAULT gen_random_uuid(),
 ADD COLUMN auth_session_id uuid;
ALTER TABLE public.push_deliveries
 ADD COLUMN claim_id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
 ADD COLUMN recipient_id uuid,
 ADD COLUMN device_revision uuid,
 ADD COLUMN attempted_at timestamptz,
 ADD COLUMN resolved_at timestamptz;
ALTER TABLE public.push_deliveries DROP CONSTRAINT push_deliveries_outcome_check;
ALTER TABLE public.push_deliveries ADD CONSTRAINT push_deliveries_outcome_check
 CHECK(outcome IN ('pending','sent','failed','planned','unknown','provider_accepted','cancelled'));
-- Preserve historical outcomes; never reinterpret an old pending row as retryable.
REVOKE ALL ON public.push_devices,public.push_deliveries,public.notification_preferences
 FROM service_role;
-- Table-level REVOKE does not remove column ACLs.
REVOKE UPDATE(enabled,updated_at) ON public.push_devices FROM service_role;
REVOKE UPDATE(outcome,updated_at) ON public.push_deliveries FROM service_role;

CREATE FUNCTION public._push_revision_i0() RETURNS trigger
LANGUAGE plpgsql SET search_path='' AS $i0$
BEGIN
 IF (NEW.user_id,NEW.push_token,NEW.platform,NEW.enabled,NEW.auth_session_id)
 IS DISTINCT FROM (OLD.user_id,OLD.push_token,OLD.platform,OLD.enabled,OLD.auth_session_id)
 THEN NEW.revision:=gen_random_uuid(); END IF;
 RETURN NEW;
END $i0$;
CREATE TRIGGER push_device_revision_i0 BEFORE UPDATE ON public.push_devices
 FOR EACH ROW EXECUTE FUNCTION public._push_revision_i0();

CREATE OR REPLACE FUNCTION public._assert_push_identity_v1(p_app_role text) RETURNS uuid
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $i0$
DECLARE uid uuid:=auth.uid();
BEGIN
 PERFORM public._push_auth_session_development_v1();
 PERFORM id FROM public.profiles WHERE id=uid AND role=p_app_role
   AND p_app_role IN ('customer','merchant') FOR SHARE;
 IF NOT FOUND THEN RAISE EXCEPTION 'push_identity_denied' USING ERRCODE='42501'; END IF;
 -- Also protects an absent preference row against concurrent first opt-out.
 PERFORM pg_advisory_xact_lock(hashtextextended('push-user:'||uid::text,0));
 RETURN uid;
END $i0$;

CREATE OR REPLACE FUNCTION public.register_push_device_v1(p_installation_id uuid,
 p_app_role text,p_push_token text,p_platform text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE uid uuid:=public._assert_push_identity_v1(p_app_role);
 sid uuid:=(auth.jwt()->>'session_id')::uuid;
BEGIN
 IF p_installation_id IS NULL OR p_push_token IS NULL OR p_platform IS NULL
 OR length(p_push_token) NOT BETWEEN 1 AND 4096 OR p_push_token ~ '[[:space:][:cntrl:]]'
 OR p_platform NOT IN ('android','ios') THEN
 RAISE EXCEPTION 'push_device_invalid' USING ERRCODE='22023'; END IF;
 INSERT INTO public.push_devices(installation_id,app_role,user_id,push_token,platform,auth_session_id)
 VALUES(p_installation_id,p_app_role,uid,p_push_token,p_platform,sid)
 ON CONFLICT(installation_id,app_role) DO UPDATE SET user_id=EXCLUDED.user_id,
 push_token=EXCLUDED.push_token,platform=EXCLUDED.platform,auth_session_id=sid,
 enabled=true,last_seen_at=clock_timestamp(),updated_at=clock_timestamp()
 WHERE push_devices.user_id=uid OR NOT push_devices.enabled;
 IF NOT FOUND THEN RAISE EXCEPTION 'push_device_owned' USING ERRCODE='42501'; END IF;
EXCEPTION WHEN unique_violation THEN
 RAISE EXCEPTION 'push_device_unavailable' USING ERRCODE='42501';
END $i0$;
CREATE OR REPLACE FUNCTION public.disable_push_device_v1(p_installation_id uuid,p_app_role text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE uid uuid:=public._assert_push_identity_v1(p_app_role);
BEGIN
 UPDATE public.push_devices SET enabled=false,updated_at=clock_timestamp()
 WHERE installation_id=p_installation_id AND app_role=p_app_role AND user_id=uid
 AND auth_session_id=(auth.jwt()->>'session_id')::uuid;
END $i0$;
-- Existing preferences RPC calls the strengthened identity guard.
-- Read policy remains compatible with the existing adapter but rejects stale sessions/roles.
CREATE FUNCTION public._push_read_identity_i0(p_user uuid,p_role text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $i0$
 SELECT p_user=auth.uid() AND auth.role()='authenticated'
 AND EXISTS(SELECT 1 FROM public.profiles WHERE id=p_user AND role=p_role)
 AND EXISTS(SELECT 1 FROM auth.sessions WHERE id::text=auth.jwt()->>'session_id'
 AND user_id=p_user AND (not_after IS NULL OR not_after>statement_timestamp()))
$i0$;
DROP POLICY notification_preferences_read_own ON public.notification_preferences;
CREATE POLICY notification_preferences_read_own ON public.notification_preferences
 FOR SELECT TO authenticated USING(public._push_read_identity_i0(user_id,app_role));

-- All callers take these locks in the same order: config, notification, profile,
-- recipient advisory lock, then delivery/device. No locks span provider I/O.
CREATE FUNCTION public._push_eligible_i0(p_notification uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE n public.notifications; r text; purpose text;
BEGIN
 IF current_setting('transaction_isolation')<>'read committed' THEN
 RAISE EXCEPTION 'push_fresh_snapshot_required' USING ERRCODE='25001'; END IF;
 PERFORM singleton FROM public.push_dispatch_config WHERE enabled FOR SHARE;
 IF NOT FOUND THEN RETURN jsonb_build_object('status','disabled'); END IF;
 SELECT * INTO n FROM public.notifications WHERE id=p_notification FOR SHARE;
 IF NOT FOUND THEN RETURN jsonb_build_object('status','rejected'); END IF;
 SELECT role INTO r FROM public.profiles WHERE id=n.user_id FOR SHARE;
 IF r IS NULL OR r NOT IN ('customer','merchant') OR
 (n.data ? 'app_role' AND n.data->>'app_role' IS DISTINCT FROM r) THEN
 RETURN jsonb_build_object('status','rejected'); END IF;
 purpose:=CASE WHEN n.data ? 'delivery_purpose' THEN n.data->>'delivery_purpose'
   WHEN n.type='promotion' THEN 'marketing' WHEN n.type IN ('order','chat') THEN 'service' END;
 -- No marketing path until canonical G/O10 recipient quota/consent policy exists.
 IF n.type='promotion' OR purpose='marketing' OR n.data ? 'campaign_id' THEN
 RETURN jsonb_build_object('status','marketing_deferred'); END IF;
 IF purpose IS DISTINCT FROM 'service' THEN RETURN jsonb_build_object('status','rejected'); END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('push-user:'||n.user_id::text,0));
 IF EXISTS(SELECT 1 FROM public.notification_preferences WHERE user_id=n.user_id
 AND app_role=r AND NOT service_enabled) THEN RETURN jsonb_build_object('status','opted_out'); END IF;
 RETURN jsonb_build_object('status','ready','user_id',n.user_id,'app_role',r,'notification_id',n.id);
END $i0$;

CREATE FUNCTION public.push_dispatch_page_i0(p_notification_id uuid,p_after uuid DEFAULT NULL)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE context jsonb; items jsonb;
BEGIN
 context:=public._push_eligible_i0(p_notification_id);
 IF context->>'status'<>'ready' THEN RETURN context; END IF;
 SELECT coalesce(jsonb_agg(x.installation_id ORDER BY x.installation_id),'[]'::jsonb) INTO items
 FROM (SELECT d.installation_id FROM public.push_devices d JOIN auth.sessions s ON s.id=d.auth_session_id
 WHERE d.user_id=(context->>'user_id')::uuid AND d.app_role=context->>'app_role' AND d.enabled
 AND s.user_id=d.user_id AND (s.not_after IS NULL OR s.not_after>clock_timestamp())
 AND (p_after IS NULL OR d.installation_id>p_after) ORDER BY d.installation_id LIMIT 100) x;
 RETURN context||jsonb_build_object('installations',items);
END $i0$;

CREATE FUNCTION public.claim_push_dispatch_i0(p_notification_id uuid,p_installation_id uuid)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE context jsonb; d public.push_devices; claim uuid;
BEGIN
 context:=public._push_eligible_i0(p_notification_id);
 IF context->>'status'<>'ready' THEN RETURN NULL; END IF;
 SELECT * INTO d FROM public.push_devices WHERE installation_id=p_installation_id
 AND app_role=context->>'app_role' AND user_id=(context->>'user_id')::uuid AND enabled FOR UPDATE;
 IF NOT FOUND THEN RETURN NULL; END IF;
 PERFORM id FROM auth.sessions WHERE id=d.auth_session_id AND user_id=d.user_id
 AND (not_after IS NULL OR not_after>clock_timestamp()) FOR SHARE;
 IF NOT FOUND THEN RETURN NULL; END IF;
 INSERT INTO public.push_deliveries(notification_id,installation_id,app_role,outcome,recipient_id,device_revision)
 VALUES(p_notification_id,p_installation_id,d.app_role,'planned',d.user_id,d.revision)
 ON CONFLICT(notification_id,installation_id,app_role) DO NOTHING RETURNING claim_id INTO claim;
 RETURN claim;
END $i0$;

CREATE FUNCTION public.begin_push_dispatch_i0(p_claim_id uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE c public.push_deliveries; d public.push_devices; context jsonb;
BEGIN
 SELECT * INTO c FROM public.push_deliveries WHERE claim_id=p_claim_id;
 IF NOT FOUND THEN RETURN NULL; END IF;
 context:=public._push_eligible_i0(c.notification_id);
 -- Even a now-ineligible notification must serialize with preference/identity updates.
 PERFORM pg_advisory_xact_lock(hashtextextended('push-user:'||c.recipient_id::text,0));
 SELECT * INTO c FROM public.push_deliveries WHERE claim_id=p_claim_id FOR UPDATE;
 IF NOT FOUND OR c.outcome<>'planned' THEN RETURN NULL; END IF;
 SELECT * INTO d FROM public.push_devices WHERE installation_id=c.installation_id AND app_role=c.app_role FOR UPDATE;
 IF context->>'status'<>'ready' OR context->>'user_id' IS DISTINCT FROM c.recipient_id::text
 OR context->>'app_role' IS DISTINCT FROM c.app_role OR d.revision IS DISTINCT FROM c.device_revision
 OR d.user_id IS DISTINCT FROM c.recipient_id OR d.enabled IS DISTINCT FROM true THEN
 UPDATE public.push_deliveries SET outcome='cancelled',updated_at=clock_timestamp(),resolved_at=clock_timestamp()
 WHERE claim_id=p_claim_id; RETURN NULL; END IF;
 PERFORM id FROM auth.sessions WHERE id=d.auth_session_id AND user_id=d.user_id
 AND (not_after IS NULL OR not_after>clock_timestamp()) FOR SHARE;
 IF NOT FOUND THEN
 UPDATE public.push_deliveries SET outcome='cancelled',updated_at=clock_timestamp(),resolved_at=clock_timestamp()
 WHERE claim_id=p_claim_id; RETURN NULL; END IF;
 -- Commit UNKNOWN before external I/O. A crash/timeout/DB-ack loss can never release the claim.
 UPDATE public.push_deliveries SET outcome='unknown',attempted_at=clock_timestamp(),updated_at=clock_timestamp()
 WHERE claim_id=p_claim_id;
 RETURN jsonb_build_object('token',d.push_token,'notification_id',c.notification_id,
 'user_id',c.recipient_id,'app_role',c.app_role);
END $i0$;

CREATE FUNCTION public.finish_push_dispatch_i0(p_claim_id uuid,p_outcome text,p_token_unregistered boolean DEFAULT false)
RETURNS text LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $i0$
DECLARE c public.push_deliveries;
BEGIN
 IF p_outcome IS NULL OR p_outcome NOT IN ('provider_accepted','failed','unknown') OR p_token_unregistered IS NULL
 OR (p_token_unregistered AND p_outcome<>'failed') THEN
 RAISE EXCEPTION 'push_outcome_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO c FROM public.push_deliveries WHERE claim_id=p_claim_id;
 IF NOT FOUND THEN RETURN NULL; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('push-user:'||c.recipient_id::text,0));
 SELECT * INTO c FROM public.push_deliveries WHERE claim_id=p_claim_id FOR UPDATE;
 IF NOT FOUND THEN RETURN NULL; END IF;
 IF c.outcome IN ('provider_accepted','failed') THEN
 IF c.outcome<>p_outcome THEN RAISE EXCEPTION 'push_outcome_conflict' USING ERRCODE='40001'; END IF;
 RETURN c.outcome; END IF;
 IF c.outcome<>'unknown' THEN RAISE EXCEPTION 'push_not_attempted' USING ERRCODE='22023'; END IF;
 IF p_token_unregistered THEN
 UPDATE public.push_devices SET enabled=false,updated_at=clock_timestamp()
 WHERE installation_id=c.installation_id AND app_role=c.app_role
 AND user_id=c.recipient_id AND revision=c.device_revision;
 END IF;
 UPDATE public.push_deliveries SET outcome=p_outcome,updated_at=clock_timestamp(),
 resolved_at=CASE WHEN p_outcome<>'unknown' THEN clock_timestamp() END WHERE claim_id=p_claim_id;
 RETURN p_outcome;
END $i0$;

-- Minimal operator reconciliation projection: no token, provider body or notification content.
CREATE FUNCTION public.read_push_dispatch_i0(p_claim_id uuid DEFAULT NULL,
 p_notification_id uuid DEFAULT NULL,p_installation_id uuid DEFAULT NULL,p_app_role text DEFAULT NULL) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $i0$
 SELECT jsonb_build_object('claim_id',claim_id,'outcome',outcome,'attempted_at',attempted_at,
 'resolved_at',resolved_at) FROM public.push_deliveries
 WHERE (claim_id=p_claim_id AND p_notification_id IS NULL AND p_installation_id IS NULL AND p_app_role IS NULL)
 OR (p_claim_id IS NULL AND notification_id=p_notification_id AND installation_id=p_installation_id AND app_role=p_app_role)
$i0$;

REVOKE ALL ON FUNCTION public._push_revision_i0() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._assert_push_identity_v1(text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.register_push_device_v1(uuid,text,text,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.disable_push_device_v1(uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._push_read_identity_i0(uuid,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._push_eligible_i0(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.push_dispatch_page_i0(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.claim_push_dispatch_i0(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.begin_push_dispatch_i0(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.finish_push_dispatch_i0(uuid,text,boolean) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_push_dispatch_i0(uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.register_push_device_v1(uuid,text,text,text),
 public.disable_push_device_v1(uuid,text),public._push_read_identity_i0(uuid,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.push_dispatch_page_i0(uuid,uuid),
 public.claim_push_dispatch_i0(uuid,uuid),public.begin_push_dispatch_i0(uuid),
 public.finish_push_dispatch_i0(uuid,text,boolean),public.read_push_dispatch_i0(uuid,uuid,uuid,text) TO service_role;

-- Narrow server metadata lookup: do not grant table SELECT or expose chat copy.
CREATE FUNCTION public.read_push_notification_development_v1(p_notification_id uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $metadata$
 SELECT jsonb_build_object('id',n.id,'user_id',n.user_id,'type',n.type,'created_at',n.created_at)
 FROM public.notifications n WHERE n.id=p_notification_id
$metadata$;
REVOKE ALL ON FUNCTION public.read_push_notification_development_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.read_push_notification_development_v1(uuid) TO service_role;
COMMIT;
