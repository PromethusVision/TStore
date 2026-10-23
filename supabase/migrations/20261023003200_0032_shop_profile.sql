-- Additive shop profile media. Apply only after separate environment approval.
-- Existing coordinates/hours and all historical migrations remain untouched.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';

DO $preflight$
BEGIN
 IF to_regclass('public.shops') IS NULL OR to_regclass('public.profiles') IS NULL
    OR to_regclass('storage.buckets') IS NULL OR to_regclass('storage.objects') IS NULL
    OR to_regprocedure('auth.uid()') IS NULL OR to_regprocedure('public.set_updated_at()') IS NULL THEN
   RAISE EXCEPTION 'Migration 0032 requires canonical shops/profiles and managed Supabase Storage/Auth'
     USING ERRCODE='42P01';
 END IF;
END $preflight$;

ALTER TABLE public.shops ADD COLUMN photo_path text;
GRANT INSERT (photo_path), UPDATE (photo_path) ON public.shops TO authenticated;

INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
VALUES ('shop-profile-media','shop-profile-media',false,5242880,
 ARRAY['image/jpeg','image/png','image/webp']);

CREATE FUNCTION public._shop_profile_owner_v1(p_path text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
 SELECT CASE WHEN p_path ~ '^shops/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{32}\.(jpg|png|webp)$'
 THEN EXISTS(SELECT 1 FROM public.shops s JOIN public.profiles p ON p.id=s.owner_user_id
   WHERE s.id::text=split_part(p_path,'/',2) AND s.owner_user_id=auth.uid()
     AND s.is_active AND p.role IN ('merchant','admin')) ELSE false END
$fn$;
REVOKE ALL ON FUNCTION public._shop_profile_owner_v1(text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public._shop_profile_owner_v1(text) TO authenticated;

CREATE POLICY shop_profile_owned_upload ON storage.objects FOR INSERT TO authenticated
 WITH CHECK(bucket_id='shop-profile-media' AND public._shop_profile_owner_v1(name));
-- Immutable objects: no client UPDATE/DELETE. Removing/replacing the reference
-- revokes new authorized public reads/signing. App requests use 300-second URL
-- expiry; previously issued URLs and cached/downloaded copies are not recalled.
-- Unpublished/stale objects remain owner-only for separately reviewed cleanup.
CREATE POLICY shop_profile_owned_read ON storage.objects FOR SELECT TO authenticated
 USING(bucket_id='shop-profile-media' AND public._shop_profile_owner_v1(name));
CREATE POLICY shop_profile_published_read ON storage.objects FOR SELECT TO anon,authenticated
 USING(bucket_id='shop-profile-media' AND EXISTS(
   SELECT 1 FROM public.shops s WHERE s.is_active AND s.photo_path=storage.objects.name));

CREATE FUNCTION public._shop_profile_guard_v1() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $fn$
DECLARE changed_location boolean; changed_photo boolean;
BEGIN
 IF TG_OP='INSERT' THEN
   changed_location := true; changed_photo := NEW.photo_path IS NOT NULL;
 ELSE
   changed_location := NEW.latitude IS DISTINCT FROM OLD.latitude OR NEW.longitude IS DISTINCT FROM OLD.longitude;
   changed_photo := NEW.photo_path IS DISTINCT FROM OLD.photo_path;
 END IF;
 -- Preserve historical rows; every newly edited pair must be complete.
 IF changed_location AND ((NEW.latitude IS NULL) <> (NEW.longitude IS NULL)) THEN
   RAISE EXCEPTION 'SHOP_LOCATION_PAIR_REQUIRED' USING ERRCODE='22023';
 END IF;
 IF changed_photo AND NEW.photo_path IS NOT NULL THEN
   IF NEW.photo_path !~ ('^shops/'||NEW.id::text||'/[0-9a-f]{32}\.(jpg|png|webp)$')
      OR NOT EXISTS(SELECT 1 FROM storage.objects o
        WHERE o.bucket_id='shop-profile-media' AND o.name=NEW.photo_path
          AND o.metadata->>'mimetype' IN ('image/jpeg','image/png','image/webp')
          AND CASE WHEN o.metadata->>'size' ~ '^[0-9]{1,10}$'
            THEN (o.metadata->>'size')::bigint BETWEEN 1 AND 5242880 ELSE false END)
   THEN RAISE EXCEPTION 'SHOP_PHOTO_UPLOAD_REQUIRED' USING ERRCODE='22023'; END IF;
 END IF;
 RETURN NEW;
END $fn$;
REVOKE ALL ON FUNCTION public._shop_profile_guard_v1() FROM PUBLIC,anon,authenticated;
CREATE TRIGGER shop_profile_guard BEFORE INSERT OR UPDATE ON public.shops
 FOR EACH ROW EXECUTE FUNCTION public._shop_profile_guard_v1();

NOTIFY pgrst,'reload schema';
COMMIT;
