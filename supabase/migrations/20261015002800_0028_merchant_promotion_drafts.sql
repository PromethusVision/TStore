-- G preparation only. No package, funding, publication, ranking or push authority.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';
DO $preflight$ BEGIN
 IF to_regclass('public.merchant_statement_config') IS NULL
 OR to_regprocedure('public._campaign_json_f(uuid,boolean)') IS NULL
 OR to_regprocedure('public._qr_auth_session_b()') IS NULL
 OR to_regprocedure('public._review_subject_c(uuid)') IS NULL THEN
   RAISE EXCEPTION '0028 requires integrated catalog, F, H0/E and H1 read contracts';
 END IF;
END $preflight$;
CREATE TABLE public.merchant_promotion_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.merchant_promotion_config DEFAULT VALUES;
CREATE TABLE public.merchant_promotion_drafts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.shops(id) ON DELETE RESTRICT,
  current_revision_id uuid,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX merchant_promotion_shop ON public.merchant_promotion_drafts(shop_id,created_at DESC,id DESC);
CREATE TABLE public.merchant_promotion_revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  draft_id uuid NOT NULL REFERENCES public.merchant_promotion_drafts(id) ON DELETE RESTRICT,
  actor_subject uuid NOT NULL,
  action text NOT NULL CHECK(action IN ('save','archive')),
  selection jsonb NOT NULL,
  snapshot jsonb NOT NULL,
  fingerprint text NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(draft_id,id)
);
ALTER TABLE public.merchant_promotion_drafts ADD CONSTRAINT promotion_current_revision
 FOREIGN KEY(id,current_revision_id) REFERENCES public.merchant_promotion_revisions(draft_id,id);
CREATE INDEX merchant_promotion_history ON public.merchant_promotion_revisions(draft_id,recorded_at DESC,id DESC);
CREATE TABLE public.merchant_promotion_requests (
 actor_subject uuid NOT NULL, request_id uuid NOT NULL, payload_hash bytea NOT NULL,
 receipt jsonb NOT NULL, recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 PRIMARY KEY(actor_subject,request_id)
);
CREATE FUNCTION public._promotion_owner_g(p_shop uuid,p_write boolean DEFAULT false) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
BEGIN
 PERFORM public._qr_auth_session_b();
 PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='merchant' FOR SHARE;
 IF NOT FOUND THEN RAISE EXCEPTION '[PROMOTION_FORBIDDEN]' USING ERRCODE='42501'; END IF;
 IF p_write THEN
   PERFORM id FROM public.shops WHERE id=p_shop AND owner_user_id=auth.uid() AND is_active FOR UPDATE;
 ELSE
   PERFORM id FROM public.shops WHERE id=p_shop AND owner_user_id=auth.uid() AND is_active FOR SHARE;
 END IF;
 IF NOT FOUND THEN RAISE EXCEPTION '[PROMOTION_FORBIDDEN]' USING ERRCODE='42501'; END IF;
END $g$;
CREATE FUNCTION public._promotion_preview_g(p_shop uuid,p_selection jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' SET timezone='UTC' AS $g$
DECLARE family text; variant integer; listing uuid; campaign uuid; photo uuid; shop_name text;
 item_name text; amount text; cr public.campaign_revisions; media jsonb; selected jsonb;
 snapshot jsonb; headline text; body_text text; source_data jsonb;
BEGIN
 IF p_selection IS NULL OR jsonb_typeof(p_selection)<>'object'
 OR NOT (p_selection ?& ARRAY['family','variant','listing_id','campaign_id','image_id'])
 OR EXISTS(SELECT 1 FROM jsonb_object_keys(p_selection) k WHERE k<>ALL(ARRAY['family','variant','listing_id','campaign_id','image_id']))
 OR jsonb_typeof(p_selection->'family')<>'string' OR p_selection->>'family' NOT IN ('store','product','offer','invitation')
 OR p_selection->'variant' NOT IN ('0'::jsonb,'1'::jsonb) THEN
 RAISE EXCEPTION '[PROMOTION_SELECTION_INVALID]' USING ERRCODE='22023'; END IF;
 BEGIN
 family:=p_selection->>'family'; variant:=(p_selection->>'variant')::integer;
 listing:=(p_selection->>'listing_id')::uuid; campaign:=(p_selection->>'campaign_id')::uuid;
 photo:=(p_selection->>'image_id')::uuid;
 EXCEPTION WHEN invalid_text_representation THEN RAISE EXCEPTION '[PROMOTION_SELECTION_INVALID]' USING ERRCODE='22023'; END;
 IF (family='product' AND listing IS NULL) OR (family='offer' AND campaign IS NULL)
 OR (family<>'offer' AND campaign IS NOT NULL) OR (photo IS NOT NULL AND listing IS NULL) THEN
 RAISE EXCEPTION '[PROMOTION_SELECTION_INVALID]' USING ERRCODE='22023'; END IF;
 SELECT name INTO shop_name FROM public.shops WHERE id=p_shop;
 source_data:=jsonb_build_object('template_version',1,'shop_name',shop_name,'selection',p_selection);
 IF listing IS NOT NULL THEN
   SELECT p.name,(sp.price*100)::bigint::text INTO item_name,amount
   FROM public.shop_products sp JOIN public.products p ON p.id=sp.product_id
   WHERE sp.id=listing AND sp.shop_id=p_shop AND public._listing_public_v1(sp.id) FOR SHARE OF sp,p;
   IF NOT FOUND THEN RETURN jsonb_build_object('ready',false,'reason','source_unavailable','images','[]'::jsonb); END IF;
   source_data:=source_data||jsonb_build_object('product_name',item_name,'price_minor',amount);
 END IF;
 IF campaign IS NOT NULL THEN
   SELECT r.* INTO cr FROM public.merchant_campaigns c JOIN public.campaign_revisions r ON r.id=c.current_revision_id
   WHERE c.id=campaign AND c.shop_id=p_shop FOR SHARE OF c;
   IF NOT FOUND OR NOT cr.active OR cr.starts_at>statement_timestamp() OR cr.ends_at<=statement_timestamp()
     OR public._campaign_block_reason_f(cr) IS NOT NULL
     OR (listing IS NOT NULL AND cr.scope<>'all' AND NOT listing=ANY(cr.listing_ids)) THEN
     RETURN jsonb_build_object('ready',false,'reason','source_unavailable','images','[]'::jsonb); END IF;
   source_data:=source_data||jsonb_build_object('campaign_revision',cr.id,'type',cr.offer_type,'scope',cr.scope,
     'price_minor',cr.price_minor::text,'percentage_basis_points',cr.percentage_basis_points,
     'starts_at',cr.starts_at,'ends_at',cr.ends_at);
   IF cr.scope<>'all' THEN
     PERFORM sp.id FROM public.shop_products sp JOIN public.products p ON p.id=sp.product_id
       WHERE sp.id=ANY(cr.listing_ids) AND sp.shop_id=p_shop FOR SHARE OF sp,p;
     source_data:=source_data||jsonb_build_object('products',(SELECT jsonb_agg(jsonb_build_object('id',sp.id,'name',p.name) ORDER BY sp.id)
       FROM public.shop_products sp JOIN public.products p ON p.id=sp.product_id WHERE sp.id=ANY(cr.listing_ids) AND sp.shop_id=p_shop));
   END IF;
 END IF;
 -- Existing validated images only. No upload, external URL or new media policy.
 PERFORM i.id FROM public.listing_images i JOIN storage.objects o ON o.bucket_id=i.bucket_id AND o.name=i.object_path
 WHERE i.listing_id=listing AND i.publication_state='published' FOR SHARE OF i,o;
 SELECT coalesce(jsonb_agg(jsonb_build_object('id',i.id,'listing_id',i.listing_id,'bucket_id',i.bucket_id,
   'object_path',i.object_path) ORDER BY i.sort_order,i.id),'[]'::jsonb) INTO media
 FROM public.listing_images i JOIN storage.objects o ON o.bucket_id=i.bucket_id AND o.name=i.object_path
 WHERE i.listing_id=listing AND i.publication_state='published'
 AND public._catalog_photo_metadata_v1(o.metadata,i.mime_type,i.byte_size)
 AND (campaign IS NULL OR i.id=ANY(cr.image_ids));
 IF photo IS NOT NULL THEN
   SELECT e INTO selected FROM jsonb_array_elements(media) e WHERE e->>'id'=photo::text;
   IF selected IS NULL THEN RETURN jsonb_build_object('ready',false,'reason','source_unavailable','images',media); END IF;
 END IF;
 headline:=CASE family WHEN 'store' THEN shop_name WHEN 'product' THEN item_name
   WHEN 'offer' THEN shop_name||' · Kampanya' ELSE shop_name||' · Davet' END;
 body_text:=CASE family
   WHEN 'store' THEN CASE variant WHEN 0 THEN 'Mağazamızı ve ürünlerimizi EsnaftaVar’da inceleyin.' ELSE 'Mağazamızın güncel ürünlerine göz atın.' END
   WHEN 'invitation' THEN CASE variant WHEN 0 THEN 'Mağazamızı keşfetmek için EsnaftaVar’a davetlisiniz.' ELSE 'EsnaftaVar’da mağazamızı inceleyin.' END
   WHEN 'product' THEN CASE variant WHEN 0 THEN 'Güncel ürün fiyatı: ' ELSE 'Mağazamızdaki fiyatı: ' END
     ||replace((amount::numeric/100)::numeric(14,2)::text,'.',',')||' TL.'
   ELSE CASE cr.offer_type WHEN 'price' THEN 'Kampanya fiyatı: '||replace((cr.price_minor::numeric/100)::numeric(14,2)::text,'.',',')||' TL.'
     WHEN 'percentage' THEN '%'||replace(trim(trailing '.' FROM trim(trailing '0' FROM (cr.percentage_basis_points::numeric/100)::numeric(6,2)::text)),'.',',')||' indirim.'
     ELSE 'Mağaza duyurusunu inceleyin.' END
     ||CASE cr.scope WHEN 'all' THEN ' Güncel uygun mağaza ürünlerinde.' ELSE ' Seçili ürünlerde.' END
     ||CASE variant WHEN 0 THEN ' Kampanya koşullarını inceleyin.' ELSE ' Kampanya ayrıntılarına göz atın.' END END;
 snapshot:=jsonb_build_object('title',headline,'body',body_text,'image',selected,'facts',source_data);
 RETURN jsonb_build_object('ready',true,'snapshot',snapshot,'images',media,
   'fingerprint',encode(extensions.digest(snapshot::text,'sha256'),'hex'));
END $g$;
CREATE FUNCTION public.preview_merchant_promotion_v1(p_shop_id uuid,p_selection jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
BEGIN
 PERFORM public._promotion_owner_g(p_shop_id);
 IF NOT EXISTS(SELECT 1 FROM public.merchant_promotion_config WHERE enabled) THEN
 RETURN jsonb_build_object('enabled',false,'ready',false,'images','[]'::jsonb); END IF;
 RETURN public._promotion_preview_g(p_shop_id,p_selection)||jsonb_build_object('enabled',true);
END $g$;
CREATE FUNCTION public._promotion_json_g(p_id uuid,p_fresh boolean DEFAULT true) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
DECLARE d public.merchant_promotion_drafts; r public.merchant_promotion_revisions; fresh jsonb; state_text text;
BEGIN
 SELECT * INTO d FROM public.merchant_promotion_drafts WHERE id=p_id;
 SELECT * INTO r FROM public.merchant_promotion_revisions WHERE id=d.current_revision_id;
 state_text:='archived';
 IF r.action='save' THEN
   state_text:='draft';
   IF p_fresh THEN
     fresh:=public._promotion_preview_g(d.shop_id,r.selection);
     IF fresh->>'fingerprint' IS DISTINCT FROM r.fingerprint THEN state_text:='needs_update'; END IF;
   END IF;
 END IF;
 RETURN jsonb_build_object('id',d.id,'revision_id',r.id,'shop_id',d.shop_id,'status',state_text,
   'selection',r.selection,'snapshot',r.snapshot,'recorded_at',r.recorded_at);
END $g$;
CREATE FUNCTION public.read_merchant_promotions_v1(p_shop_id uuid,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
DECLARE ids uuid[]; items jsonb:='[]'; item uuid; total integer;
BEGIN
 PERFORM public._promotion_owner_g(p_shop_id);
 IF p_offset IS NULL OR p_offset<0 OR p_offset>500 THEN RAISE EXCEPTION '[PROMOTION_PAGE_INVALID]' USING ERRCODE='22023'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.merchant_promotion_config WHERE enabled) THEN
 RETURN jsonb_build_object('enabled',false,'shop_id',p_shop_id,'items',items,'has_more',false,'limit',500); END IF;
 SELECT count(*) INTO total FROM public.merchant_promotion_drafts WHERE shop_id=p_shop_id;
 -- Oldest-first append-only root order: edits/archives/new roots never shift earlier pages.
 SELECT array_agg(id ORDER BY created_at,id) INTO ids FROM
 (SELECT id,created_at FROM public.merchant_promotion_drafts WHERE shop_id=p_shop_id ORDER BY created_at,id LIMIT 20 OFFSET p_offset) d;
 FOREACH item IN ARRAY coalesce(ids,'{}'::uuid[]) LOOP items:=items||jsonb_build_array(public._promotion_json_g(item)); END LOOP;
 RETURN jsonb_build_object('enabled',true,'shop_id',p_shop_id,'items',items,'has_more',total>p_offset+20,'limit',500);
END $g$;
CREATE FUNCTION public.read_promotion_sources_v1(p_shop_id uuid,p_kind text,p_query text DEFAULT '',p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
DECLARE items jsonb;
BEGIN
 PERFORM public._promotion_owner_g(p_shop_id);
 IF p_kind IS NULL OR p_kind NOT IN ('listing','campaign') OR p_query IS NULL OR length(p_query)>120
 OR p_offset IS NULL OR p_offset<0 OR p_offset>10000 THEN RAISE EXCEPTION '[PROMOTION_PAGE_INVALID]' USING ERRCODE='22023'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.merchant_promotion_config WHERE enabled) THEN RETURN jsonb_build_object('enabled',false,'items','[]'::jsonb); END IF;
 IF p_kind='listing' THEN
 SELECT coalesce(jsonb_agg(jsonb_build_object('id',id,'label',name) ORDER BY name,id),'[]') INTO items FROM (
 SELECT sp.id,p.name FROM public.shop_products sp JOIN public.products p ON p.id=sp.product_id
 WHERE sp.shop_id=p_shop_id AND public._listing_public_v1(sp.id) AND strpos(lower(p.name),lower(trim(p_query)))>0
 ORDER BY p.name,sp.id LIMIT 20 OFFSET p_offset) x;
 ELSE
 SELECT coalesce(jsonb_agg(jsonb_build_object('id',id,'label',title) ORDER BY title,id),'[]') INTO items FROM (
 SELECT c.id,r.title FROM public.merchant_campaigns c JOIN public.campaign_revisions r ON r.id=c.current_revision_id
 WHERE c.shop_id=p_shop_id AND public._campaign_json_f(c.id) IS NOT NULL AND strpos(lower(r.title),lower(trim(p_query)))>0
 ORDER BY r.title,c.id LIMIT 20 OFFSET p_offset) x;
 END IF;
 RETURN jsonb_build_object('enabled',true,'items',items);
END $g$;
CREATE FUNCTION public.mutate_merchant_promotion_v1(p_shop_id uuid,p_draft_id uuid,p_expected_revision uuid,
 p_request_id uuid,p_action text,p_selection jsonb DEFAULT NULL,p_fingerprint text DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
DECLARE actor uuid; prior public.merchant_promotion_requests; d public.merchant_promotion_drafts;
 old public.merchant_promotion_revisions; rev uuid; payload bytea; preview jsonb; receipt jsonb;
BEGIN
 PERFORM public._promotion_owner_g(p_shop_id,true);
 actor:=public._review_subject_c(auth.uid());
 PERFORM subject_id FROM public.review_subject_keys WHERE subject_id=actor FOR UPDATE;
 IF p_request_id IS NULL OR p_action IS NULL OR p_action NOT IN ('save','archive') THEN RAISE EXCEPTION '[PROMOTION_ACTION_INVALID]' USING ERRCODE='22023'; END IF;
 payload:=extensions.digest(jsonb_build_array(p_shop_id,p_draft_id,p_expected_revision,p_action,p_selection,p_fingerprint)::text,'sha256');
 SELECT * INTO prior FROM public.merchant_promotion_requests WHERE actor_subject=actor AND request_id=p_request_id;
 IF FOUND THEN
   IF payload<>prior.payload_hash THEN RAISE EXCEPTION '[PROMOTION_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
   RETURN prior.receipt;
 END IF;
 PERFORM singleton FROM public.merchant_promotion_config WHERE enabled FOR SHARE;
 IF NOT FOUND THEN RAISE EXCEPTION '[PROMOTION_DISABLED]' USING ERRCODE='55000'; END IF;
 IF p_draft_id IS NOT NULL THEN
   SELECT * INTO d FROM public.merchant_promotion_drafts WHERE id=p_draft_id AND shop_id=p_shop_id FOR UPDATE;
   IF NOT FOUND THEN RAISE EXCEPTION '[PROMOTION_FORBIDDEN]' USING ERRCODE='42501'; END IF;
   IF d.current_revision_id IS DISTINCT FROM p_expected_revision THEN RAISE EXCEPTION '[PROMOTION_CHANGED]' USING ERRCODE='40001'; END IF;
 ELSE
   IF p_action<>'save' OR p_expected_revision IS NOT NULL THEN RAISE EXCEPTION '[PROMOTION_INVALID]' USING ERRCODE='22023'; END IF;
   IF (SELECT count(*) FROM public.merchant_promotion_drafts WHERE shop_id=p_shop_id)>=500 THEN RAISE EXCEPTION '[PROMOTION_LIMIT]' USING ERRCODE='54000'; END IF;
 END IF;
 IF p_action='save' THEN
   preview:=public._promotion_preview_g(p_shop_id,p_selection);
   IF NOT coalesce((preview->>'ready')::boolean,false) OR p_fingerprint IS NULL OR p_fingerprint IS DISTINCT FROM preview->>'fingerprint' THEN
     RAISE EXCEPTION '[PROMOTION_SOURCE_CHANGED]' USING ERRCODE='40001'; END IF;
 ELSE
   IF p_selection IS NOT NULL OR p_fingerprint IS NOT NULL THEN RAISE EXCEPTION '[PROMOTION_INVALID]' USING ERRCODE='22023'; END IF;
   SELECT * INTO old FROM public.merchant_promotion_revisions WHERE id=d.current_revision_id;
   p_selection:=old.selection; preview:=jsonb_build_object('snapshot',old.snapshot,'fingerprint',old.fingerprint);
 END IF;
 IF d.id IS NULL THEN INSERT INTO public.merchant_promotion_drafts(shop_id) VALUES(p_shop_id) RETURNING * INTO d; END IF;
 INSERT INTO public.merchant_promotion_revisions(draft_id,actor_subject,action,selection,snapshot,fingerprint)
 VALUES(d.id,actor,p_action,p_selection,preview->'snapshot',preview->>'fingerprint') RETURNING id INTO rev;
 UPDATE public.merchant_promotion_drafts SET current_revision_id=rev WHERE id=d.id;
 -- Receipt describes committed revision, never claims current freshness/publication.
 receipt:=jsonb_build_object('id',d.id,'revision_id',rev,'action',p_action);
 INSERT INTO public.merchant_promotion_requests(actor_subject,request_id,payload_hash,receipt) VALUES(actor,p_request_id,payload,receipt);
 RETURN receipt;
END $g$;
CREATE FUNCTION public.read_promotion_history_v1(p_shop_id uuid,p_draft_id uuid,p_offset integer DEFAULT 0) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $g$
DECLARE items jsonb;
BEGIN
 PERFORM public._promotion_owner_g(p_shop_id);
 IF p_offset IS NULL OR p_offset<0 OR p_offset>10000 THEN RAISE EXCEPTION '[PROMOTION_PAGE_INVALID]' USING ERRCODE='22023'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.merchant_promotion_drafts WHERE id=p_draft_id AND shop_id=p_shop_id) THEN
 RAISE EXCEPTION '[PROMOTION_FORBIDDEN]' USING ERRCODE='42501'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.merchant_promotion_config WHERE enabled) THEN RETURN jsonb_build_object('enabled',false,'items','[]'::jsonb); END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object('revision_id',id,'action',action,'snapshot',snapshot,'recorded_at',recorded_at)
 ORDER BY recorded_at,id),'[]') INTO items FROM (SELECT * FROM public.merchant_promotion_revisions WHERE draft_id=p_draft_id
 ORDER BY recorded_at,id LIMIT 20 OFFSET p_offset) r;
 RETURN jsonb_build_object('enabled',true,'items',items);
END $g$;
ALTER TABLE public.merchant_promotion_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_promotion_drafts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_promotion_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_promotion_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.merchant_promotion_config,public.merchant_promotion_drafts,public.merchant_promotion_revisions,public.merchant_promotion_requests FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER promotion_revisions_immutable BEFORE UPDATE OR DELETE ON public.merchant_promotion_revisions FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER promotion_requests_immutable BEFORE UPDATE OR DELETE ON public.merchant_promotion_requests FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
REVOKE ALL ON FUNCTION public._promotion_owner_g(uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._promotion_preview_g(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._promotion_json_g(uuid,boolean) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.preview_merchant_promotion_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_merchant_promotions_v1(uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_promotion_sources_v1(uuid,text,text,integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.mutate_merchant_promotion_v1(uuid,uuid,uuid,uuid,text,jsonb,text) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_promotion_history_v1(uuid,uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.preview_merchant_promotion_v1(uuid,jsonb),public.read_merchant_promotions_v1(uuid,integer),
 public.read_promotion_sources_v1(uuid,text,text,integer),public.mutate_merchant_promotion_v1(uuid,uuid,uuid,uuid,text,jsonb,text),
 public.read_promotion_history_v1(uuid,uuid,integer) TO authenticated;
COMMIT;
