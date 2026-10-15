-- D: additive, local-authorized trust projections. No money or organic rank.
BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '120s';
DO $preflight$ BEGIN
  IF to_regclass('public.review_revisions') IS NULL
    OR to_regprocedure('public._qr_auth_session_b()') IS NULL
    OR to_regprocedure('public.read_service_scores_v2(uuid)') IS NULL THEN
    RAISE EXCEPTION '0020 requires integrated A/B/C and managed Auth';
  END IF;
END $preflight$;

CREATE TABLE public.badge_protocol_config (
  singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
  enabled boolean NOT NULL DEFAULT false
);
INSERT INTO public.badge_protocol_config(singleton) VALUES(true);
CREATE TABLE public.badge_rule_versions (
  version integer PRIMARY KEY,
  rules jsonb NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
INSERT INTO public.badge_rule_versions VALUES(1,
  '{"friendliness":4.70,"communication":4.80,"cleanliness":4.80,"products":4.80,"customers":20,"window_days":90,"top_fraction":0.10,"milestones":[10,50,100,250]}',clock_timestamp());
CREATE TABLE public.badge_subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_kind text NOT NULL CHECK(subject_kind IN ('customer','merchant')),
  user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
  shop_id uuid UNIQUE REFERENCES public.shops(id) ON DELETE RESTRICT,
  CHECK((subject_kind='merchant' AND shop_id IS NOT NULL AND user_id IS NULL)
    OR (subject_kind='customer' AND shop_id IS NULL))
);
CREATE TABLE public.badge_current_state (
  subject_id uuid NOT NULL REFERENCES public.badge_subjects(id) ON DELETE RESTRICT,
  badge_code text NOT NULL,
  rule_version integer NOT NULL REFERENCES public.badge_rule_versions(version),
  eligible boolean NOT NULL,
  details jsonb NOT NULL,
  checked_at timestamptz NOT NULL,
  next_check_at timestamptz,
  PRIMARY KEY(subject_id,badge_code)
);
CREATE INDEX badge_state_due ON public.badge_current_state(next_check_at) WHERE next_check_at IS NOT NULL;
CREATE TABLE public.badge_award_events (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subject_id uuid NOT NULL REFERENCES public.badge_subjects(id) ON DELETE RESTRICT,
  badge_code text NOT NULL,
  rule_version integer NOT NULL REFERENCES public.badge_rule_versions(version),
  event_kind text NOT NULL CHECK(event_kind IN ('awarded','revoked')),
  reason text NOT NULL,
  qualification jsonb NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX badge_awards_subject ON public.badge_award_events(subject_id,id DESC);
-- Operational work queue, not award history. Appends never lock business rows.
CREATE TABLE public.badge_refresh_events (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subject_kind text NOT NULL CHECK(subject_kind IN ('customer','merchant')),
  target_id uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX badge_refresh_targets ON public.badge_refresh_events(subject_kind,target_id,id);

-- Empty until a separately reviewed dataset is loaded. No address-text guessing.
CREATE TABLE public.badge_area_versions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  dataset_name text NOT NULL CHECK(length(dataset_name) BETWEEN 1 AND 160),
  source_reference text NOT NULL CHECK(length(source_reference) BETWEEN 1 AND 1000),
  dataset_sha256 text NOT NULL CHECK(dataset_sha256 ~ '^[a-f0-9]{64}$'),
  approved boolean NOT NULL DEFAULT false,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE public.badge_local_areas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  version_id uuid NOT NULL REFERENCES public.badge_area_versions(id) ON DELETE RESTRICT,
  official_code text NOT NULL,
  label text NOT NULL CHECK(length(label) BETWEEN 1 AND 160),
  geometry jsonb NOT NULL CHECK(geometry->>'type' IN ('Polygon','MultiPolygon')),
  UNIQUE(version_id,official_code)
);
CREATE TABLE public.badge_area_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.shops(id) ON DELETE RESTRICT,
  area_id uuid NOT NULL REFERENCES public.badge_local_areas(id) ON DELETE RESTRICT,
  latitude numeric NOT NULL,
  longitude numeric NOT NULL,
  actor_subject uuid NOT NULL,
  reason text NOT NULL CHECK(length(reason) BETWEEN 1 AND 500),
  request_id uuid NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE(actor_subject,request_id)
);
CREATE TABLE public.badge_shop_areas (
  shop_id uuid PRIMARY KEY REFERENCES public.shops(id) ON DELETE CASCADE,
  assignment_id uuid NOT NULL REFERENCES public.badge_area_assignments(id) ON DELETE RESTRICT
);
CREATE INDEX badge_revision_origin ON public.review_revisions(shop_id,subject_id,product_id,recorded_at DESC,id DESC);

CREATE FUNCTION public._badge_enabled_d() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  SELECT enabled AND public._review_enabled_c() FROM public.badge_protocol_config WHERE singleton
$badge$;
-- Version 1 is immutable; a future rule version requires a reviewed migration.
CREATE FUNCTION public._badge_rules_d() RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  SELECT rules FROM public.badge_rule_versions WHERE version=1
$badge$;
CREATE FUNCTION public.badge_capabilities_v1() RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  SELECT jsonb_build_object('version',1,'enabled',public._badge_enabled_d(),'rule_version',1)
$badge$;

-- Polygon coordinates are GeoJSON longitude/latitude, not user search radius.
-- 0 outside, 1 inside, 2 boundary; malformed rings fail closed.
CREATE FUNCTION public._badge_geometry_valid_d(p_geometry jsonb) RETURNS boolean
LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $badge$
DECLARE polys jsonb; poly jsonb; ring jsonb; point jsonb; n integer; BEGIN
  polys:=CASE p_geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(p_geometry->'coordinates')
    WHEN 'MultiPolygon' THEN p_geometry->'coordinates' END;
  IF jsonb_typeof(polys) IS DISTINCT FROM 'array' THEN RETURN false; END IF;
  IF jsonb_array_length(polys) NOT BETWEEN 1 AND 1000 THEN RETURN false; END IF;
  FOR poly IN SELECT value FROM jsonb_array_elements(polys) LOOP
    IF jsonb_typeof(poly) IS DISTINCT FROM 'array' THEN RETURN false; END IF;
    IF jsonb_array_length(poly) NOT BETWEEN 1 AND 1000 THEN RETURN false; END IF;
    FOR ring IN SELECT value FROM jsonb_array_elements(poly) LOOP
      IF jsonb_typeof(ring) IS DISTINCT FROM 'array' THEN RETURN false; END IF;
      n:=jsonb_array_length(ring);
      IF n NOT BETWEEN 4 AND 10000 OR ring->0 IS DISTINCT FROM ring->(n-1) THEN RETURN false; END IF;
      FOR point IN SELECT value FROM jsonb_array_elements(ring) LOOP
        IF jsonb_typeof(point) IS DISTINCT FROM 'array' THEN RETURN false; END IF;
        IF jsonb_array_length(point)<>2 OR jsonb_typeof(point->0) IS DISTINCT FROM 'number'
          OR jsonb_typeof(point->1) IS DISTINCT FROM 'number' THEN RETURN false; END IF;
        IF (point->>0)::numeric NOT BETWEEN -180 AND 180 OR (point->>1)::numeric NOT BETWEEN -90 AND 90 THEN RETURN false; END IF;
      END LOOP;
    END LOOP;
  END LOOP;
  RETURN true;
EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN RETURN false;
END $badge$;
ALTER TABLE public.badge_local_areas ADD CONSTRAINT badge_area_geometry_valid CHECK(public._badge_geometry_valid_d(geometry));
CREATE FUNCTION public._badge_ring_d(p_ring jsonb,p_x numeric,p_y numeric) RETURNS integer
LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $badge$
DECLARE n integer; i integer; a jsonb; b jsonb; ax numeric; ay numeric; bx numeric; byy numeric; inside boolean:=false;
BEGIN
  IF p_x IS NULL OR p_y IS NULL OR jsonb_typeof(p_ring)<>'array' THEN RETURN 0; END IF;
  n:=jsonb_array_length(p_ring);
  IF n<4 OR n>10000 OR p_ring->0 IS DISTINCT FROM p_ring->(n-1) THEN RETURN 0; END IF;
  FOR i IN 0..n-2 LOOP
    a:=p_ring->i; b:=p_ring->(i+1);
    IF jsonb_typeof(a)<>'array' OR jsonb_typeof(b)<>'array' OR jsonb_array_length(a)<2 OR jsonb_array_length(b)<2 THEN RETURN 0; END IF;
    ax:=(a->>0)::numeric; ay:=(a->>1)::numeric; bx:=(b->>0)::numeric; byy:=(b->>1)::numeric;
    IF ax IS NULL OR ay IS NULL OR bx IS NULL OR byy IS NULL OR ax NOT BETWEEN -180 AND 180 OR bx NOT BETWEEN -180 AND 180
      OR ay NOT BETWEEN -90 AND 90 OR byy NOT BETWEEN -90 AND 90 THEN RETURN 0; END IF;
    IF (p_x-ax)*(byy-ay)=(p_y-ay)*(bx-ax) AND p_x BETWEEN least(ax,bx) AND greatest(ax,bx)
      AND p_y BETWEEN least(ay,byy) AND greatest(ay,byy) THEN RETURN 2; END IF;
    IF (ay>p_y)<>(byy>p_y) AND p_x<(bx-ax)*(p_y-ay)/(byy-ay)+ax THEN inside:=NOT inside; END IF;
  END LOOP;
  RETURN CASE WHEN inside THEN 1 ELSE 0 END;
EXCEPTION WHEN invalid_text_representation OR numeric_value_out_of_range THEN RETURN 0;
END $badge$;
CREATE FUNCTION public._badge_area_covers_d(p_geometry jsonb,p_lon numeric,p_lat numeric) RETURNS boolean
LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $badge$
DECLARE polys jsonb; poly jsonb; i integer; hole boolean; BEGIN
  IF NOT public._badge_geometry_valid_d(p_geometry) OR p_lon IS NULL OR p_lat IS NULL THEN RETURN false; END IF;
  polys:=CASE p_geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(p_geometry->'coordinates')
    WHEN 'MultiPolygon' THEN p_geometry->'coordinates' END;
  IF polys IS NULL OR jsonb_typeof(polys)<>'array' OR jsonb_array_length(polys)>1000 THEN RETURN false; END IF;
  FOR poly IN SELECT value FROM jsonb_array_elements(polys) LOOP
    IF jsonb_typeof(poly)<>'array' OR jsonb_array_length(poly)=0 THEN RETURN false; END IF;
    IF public._badge_ring_d(poly->0,p_lon,p_lat)>0 THEN
      hole:=false;
      FOR i IN 1..jsonb_array_length(poly)-1 LOOP
        IF public._badge_ring_d(poly->i,p_lon,p_lat)>0 THEN hole:=true; EXIT; END IF;
      END LOOP;
      IF NOT hole THEN RETURN true; END IF;
    END IF;
  END LOOP;
  RETURN false;
END $badge$;
CREATE FUNCTION public._badge_trusted_area_d(p_shop uuid) RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  SELECT a.area_id FROM public.badge_shop_areas current
  JOIN public.badge_area_assignments a ON a.id=current.assignment_id
  JOIN public.badge_local_areas area ON area.id=a.area_id
  JOIN public.badge_area_versions v ON v.id=area.version_id AND v.approved
  JOIN public.shops s ON s.id=current.shop_id
  WHERE s.id=p_shop AND s.latitude=a.latitude AND s.longitude=a.longitude
    AND public._badge_area_covers_d(area.geometry,s.longitude,s.latitude)
$badge$;

-- Valid historical evidence is separate from current public text visibility.
CREATE FUNCTION public._badge_product_evidence_d() RETURNS TABLE(
  review_id uuid,user_id uuid,product_id uuid,shop_id uuid,purchase_id uuid,rating integer,recorded_at timestamptz,revision_id uuid)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  SELECT r.review_id,k.user_id,r.product_id,r.shop_id,r.purchase_id,r.rating::integer,r.recorded_at,r.id
  FROM public.review_revisions r JOIN public.review_lifecycle l ON l.review_id=r.review_id
  JOIN public.review_subject_keys k ON k.subject_id=r.subject_id
  JOIN public.profiles p ON p.id=k.user_id
  WHERE NOT l.account_deleted AND NOT l.abuse_flagged AND public._review_purchase_valid_c(r.purchase_id)
  UNION ALL
  SELECT r.id,r.user_id,r.product_id,t.shop_id,t.id,r.rating,r.updated_at,r.id
  FROM public.reviews r JOIN public.verified_transaction_items i ON i.id=r.verified_transaction_item_id
  JOIN public.verified_transactions t ON t.id=i.verified_transaction_id AND t.customer_user_id=r.user_id AND i.product_id=r.product_id
  JOIN public.profiles p ON p.id=r.user_id
  WHERE r.is_verified_purchase AND public._review_purchase_valid_c(t.id)
    AND NOT EXISTS(SELECT 1 FROM public.review_lifecycle s WHERE s.review_id=r.id)
$badge$;
CREATE FUNCTION public._badge_neighborhood_d(p_shop uuid,p_at timestamptz) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  WITH area AS (SELECT public._badge_trusted_area_d(p_shop) id),
  counts AS (
    SELECT s.id,count(DISTINCT t.customer_user_id) n
    FROM public.shops s JOIN public.profiles owner ON owner.id=s.owner_user_id AND owner.role='merchant'
    JOIN public.verified_transactions t ON t.shop_id=s.id AND t.confirmed_at>p_at-make_interval(days=>(public._badge_rules_d()->>'window_days')::integer) AND t.confirmed_at<=p_at
    JOIN public.profiles customer ON customer.id=t.customer_user_id
    WHERE s.is_active AND public._badge_trusted_area_d(s.id)=(SELECT id FROM area)
      AND public._review_purchase_valid_c(t.id) GROUP BY s.id
  ), ranked AS(SELECT *,row_number() OVER(ORDER BY n DESC,id) rank,count(*) OVER() cohort FROM counts)
  SELECT jsonb_build_object('pending',(SELECT id FROM area) IS NULL,
    'customers',coalesce((SELECT n FROM ranked WHERE id=p_shop),0),
    'rank',(SELECT rank FROM ranked WHERE id=p_shop),'cohort',coalesce((SELECT max(cohort) FROM ranked),0),
    'eligible',coalesce((SELECT rank<=ceil(cohort*(public._badge_rules_d()->>'top_fraction')::numeric) FROM ranked WHERE id=p_shop),false),
    'next_check_at',(SELECT min(t.confirmed_at+make_interval(days=>(public._badge_rules_d()->>'window_days')::integer)) FROM public.verified_transactions t
      JOIN public.shops s ON s.id=t.shop_id WHERE public._badge_trusted_area_d(s.id)=(SELECT id FROM area)
      AND t.confirmed_at>p_at-make_interval(days=>(public._badge_rules_d()->>'window_days')::integer) AND t.confirmed_at<=p_at AND public._review_purchase_valid_c(t.id)))
$badge$;
CREATE FUNCTION public._badge_shop_details_d(p_shop uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $badge$
DECLARE scores jsonb; neighborhood jsonb; average_product numeric; customers integer; active boolean;
BEGIN
  SELECT s.is_active AND p.role='merchant' INTO active FROM public.shops s LEFT JOIN public.profiles p ON p.id=s.owner_user_id WHERE s.id=p_shop;
  scores:=public.read_service_scores_v2(p_shop);
  WITH latest AS(SELECT DISTINCT ON(user_id,product_id) * FROM public._badge_product_evidence_d()
    WHERE shop_id=p_shop ORDER BY user_id,product_id,recorded_at DESC,revision_id DESC)
  SELECT avg(rating),count(DISTINCT user_id)::integer INTO average_product,customers FROM latest;
  neighborhood:=public._badge_neighborhood_d(p_shop,clock_timestamp());
  RETURN jsonb_build_object('active',coalesce(active,false),'scores',scores,'product_average',average_product,
    'product_customers',customers,'neighborhood',neighborhood);
END $badge$;
CREATE FUNCTION public._badge_customer_details_d(p_user uuid) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $badge$
  SELECT jsonb_build_object('active',EXISTS(SELECT 1 FROM public.profiles WHERE id=p_user AND role='customer'),
    'purchases',(SELECT count(*) FROM public.verified_transactions t WHERE t.customer_user_id=p_user AND public._review_purchase_valid_c(t.id)),
    'reviews',(SELECT count(DISTINCT review_id) FROM public._badge_product_evidence_d() WHERE user_id=p_user))
$badge$;
CREATE FUNCTION public._badge_rows_d(p_kind text,p_target uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $badge$
DECLARE details jsonb; active boolean; result jsonb:='[]'; code text; title text; value numeric; count_value integer;
  threshold numeric; pending boolean; eligible boolean; level integer; family text; goal integer;
  rules jsonb:=public._badge_rules_d(); minimum_customers integer:=(public._badge_rules_d()->>'customers')::integer;
BEGIN
  details:=CASE p_kind WHEN 'merchant' THEN public._badge_shop_details_d(p_target) ELSE public._badge_customer_details_d(p_target) END;
  active:=coalesce((details->>'active')::boolean,false);
  IF p_kind='merchant' THEN
    FOR code,title,threshold IN SELECT * FROM (VALUES
      ('friendliness','Güleryüzlü Esnaf',4.70::numeric),('products','Ürünleri Sevilen Esnaf',4.80::numeric),
      ('neighborhood','Mahallenin Yıldızı',0::numeric),('communication','İletişimi İyi',4.80::numeric),('cleanliness','Tertemiz Esnaf',4.80::numeric)) v LOOP
      threshold:=coalesce((rules->>code)::numeric,0);
      pending:=false;
      IF code='products' THEN value:=(details->>'product_average')::numeric; count_value:=(details->>'product_customers')::integer;
      ELSIF code='neighborhood' THEN value:=NULL; count_value:=(details->'neighborhood'->>'customers')::integer; pending:=(details->'neighborhood'->>'pending')::boolean;
      ELSE value:=(details->'scores'->>code)::numeric; count_value:=(details->'scores'->>'sample_count')::integer; END IF;
      eligible:=active AND CASE WHEN code='neighborhood' THEN (details->'neighborhood'->>'eligible')::boolean ELSE count_value>=minimum_customers AND coalesce(value>=threshold,false) END;
      result:=result||jsonb_build_array(jsonb_build_object('code',code,'family',code,'level',1,'title',title,'eligible',eligible,
        'pending',pending,'value',value,'required_value',CASE WHEN threshold>0 THEN threshold END,'count',count_value,
        'required_count',CASE WHEN code<>'neighborhood' THEN minimum_customers END,'explanation',CASE WHEN code='neighborhood'
          THEN 'Son 90 günde, doğrulanmış farklı müşteri sayısıyla onaylı mahallesindeki ilk %10. Bölge eşleşmesi yoksa beklemededir.'
          WHEN code='products' THEN 'Bu mağazadaki alışverişlerden gelen son geçerli ürün puanları: en az 20 farklı müşteri ve 4,80 ortalama.'
          ELSE 'En az 20 farklı doğrulanmış müşterinin son geçerli hizmet değerlendirmesi; ortalama en az '||replace(threshold::text,'.',',')||'.' END,
        'next_check_at',CASE WHEN code='neighborhood' THEN details->'neighborhood'->'next_check_at' END));
    END LOOP;
  ELSE
    FOREACH family IN ARRAY ARRAY['purchases','reviews'] LOOP
      count_value:=(details->>family)::integer; level:=0;
      FOR goal IN SELECT item.value::integer FROM jsonb_array_elements_text(rules->'milestones') item LOOP
        level:=level+1;
        title:=CASE WHEN family='purchases' THEN CASE WHEN goal=250 THEN 'EsnaftaVar''ın Yıldızı' ELSE goal||' Alışveriş' END
          ELSE (ARRAY['Aktif Yorumcu','Deneyimli Yorumcu','Uzman Yorumcu','Mahalle Rehberi'])[level] END;
        result:=result||jsonb_build_array(jsonb_build_object('code',family||'_'||goal,'family',family,'level',level,'title',title,
          'eligible',active AND count_value>=goal,'pending',false,'count',count_value,'required_count',goal,
          'explanation',goal||CASE WHEN family='purchases' THEN ' farklı doğrulanmış alışveriş.' ELSE ' geçerli doğrulanmış ürün değerlendirmesi. Düzenlemeler ek değerlendirme sayılmaz.' END));
      END LOOP;
    END LOOP;
  END IF;
  RETURN result;
END $badge$;

CREATE FUNCTION public._badge_subject_d(p_kind text,p_target uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE sid uuid; BEGIN
  SELECT id INTO sid FROM public.badge_subjects WHERE subject_kind=p_kind
    AND CASE p_kind WHEN 'customer' THEN user_id=p_target ELSE shop_id=p_target END;
  IF sid IS NOT NULL THEN RETURN sid; END IF;
  IF p_kind='customer' THEN
    IF NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=p_target AND role='customer') THEN RETURN NULL; END IF;
    INSERT INTO public.badge_subjects(subject_kind,user_id) VALUES(p_kind,p_target) ON CONFLICT(user_id) DO NOTHING;
  ELSIF p_kind='merchant' THEN
    IF NOT EXISTS(SELECT 1 FROM public.shops WHERE id=p_target) THEN RETURN NULL; END IF;
    INSERT INTO public.badge_subjects(subject_kind,shop_id) VALUES(p_kind,p_target) ON CONFLICT(shop_id) DO NOTHING;
  ELSE RAISE EXCEPTION '[BADGE_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  SELECT id INTO sid FROM public.badge_subjects WHERE subject_kind=p_kind
    AND CASE p_kind WHEN 'customer' THEN user_id=p_target ELSE shop_id=p_target END;
  RETURN sid;
EXCEPTION WHEN foreign_key_violation THEN
  IF p_kind='customer' AND NOT EXISTS(SELECT 1 FROM auth.users WHERE id=p_target) THEN RETURN NULL; END IF;
  RAISE;
END $badge$;
CREATE FUNCTION public._badge_recompute_d(p_kind text,p_target uuid) RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE sid uuid; row_data jsonb; previous boolean; is_eligible boolean; transitions integer:=0; BEGIN
  IF NOT public._badge_enabled_d() THEN RETURN 0; END IF;
  sid:=public._badge_subject_d(p_kind,p_target);
  IF sid IS NULL THEN RETURN 0; END IF;
  PERFORM id FROM public.badge_subjects WHERE id=sid FOR UPDATE;
  FOR row_data IN SELECT value FROM jsonb_array_elements(public._badge_rows_d(p_kind,p_target)) LOOP
    is_eligible:=(row_data->>'eligible')::boolean;
    SELECT eligible INTO previous FROM public.badge_current_state WHERE subject_id=sid AND badge_code=row_data->>'code';
    IF (previous IS NULL AND is_eligible) OR (previous IS NOT NULL AND previous<>is_eligible) THEN
      INSERT INTO public.badge_award_events(subject_id,badge_code,rule_version,event_kind,reason,qualification)
        VALUES(sid,row_data->>'code',1,CASE WHEN is_eligible THEN 'awarded' ELSE 'revoked' END,'qualification_changed',row_data-'next_check_at');
      transitions:=transitions+1;
    END IF;
    INSERT INTO public.badge_current_state(subject_id,badge_code,rule_version,eligible,details,checked_at,next_check_at)
      VALUES(sid,row_data->>'code',1,is_eligible,row_data,clock_timestamp(),(row_data->>'next_check_at')::timestamptz)
      ON CONFLICT(subject_id,badge_code) DO UPDATE SET eligible=excluded.eligible,details=excluded.details,
        checked_at=excluded.checked_at,next_check_at=excluded.next_check_at,rule_version=excluded.rule_version;
  END LOOP;
  RETURN transitions;
END $badge$;
CREATE FUNCTION public.read_badges_v1(p_shop_ids uuid[]) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $badge$
DECLARE result jsonb; BEGIN
  IF p_shop_ids IS NULL OR cardinality(p_shop_ids)>50 OR array_position(p_shop_ids,NULL) IS NOT NULL THEN
    RAISE EXCEPTION '[BADGE_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  IF NOT public._badge_enabled_d() THEN RETURN jsonb_build_object('enabled',false,'shops','[]'::jsonb); END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('shop_id',target,'badges',
    (SELECT coalesce(jsonb_agg(row_data-'value'-'count'-'next_check_at' ORDER BY row_data->>'code'),'[]')
     FROM jsonb_array_elements(public._badge_rows_d('merchant',target)) row_data WHERE (row_data->>'eligible')::boolean)) ORDER BY target),'[]') INTO result
    FROM(SELECT DISTINCT unnest(p_shop_ids) target) ids;
  RETURN jsonb_build_object('enabled',true,'shops',result);
END $badge$;
CREATE FUNCTION public.read_my_trust_v1(p_shop_id uuid DEFAULT NULL,p_limit integer DEFAULT 30,p_before bigint DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE kind text; target uuid; sid uuid; history jsonb; next_id bigint; BEGIN
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 100 OR p_before<1 THEN RAISE EXCEPTION '[BADGE_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  IF p_shop_id IS NULL THEN PERFORM public._review_customer_c(); kind:='customer'; target:=auth.uid();
  ELSE PERFORM public._review_merchant_c(p_shop_id); kind:='merchant'; target:=p_shop_id; END IF;
  IF NOT public._badge_enabled_d() THEN RETURN jsonb_build_object('enabled',false,'badges','[]'::jsonb,'history','[]'::jsonb); END IF;
  PERFORM public._badge_recompute_d(kind,target);
  sid:=public._badge_subject_d(kind,target);
  SELECT coalesce(jsonb_agg(jsonb_build_object('id',id,'code',badge_code,'event',event_kind,'reason',reason,'qualification',qualification,'recorded_at',recorded_at) ORDER BY id DESC),'[]'),
    CASE WHEN count(*)=p_limit THEN min(id) END INTO history,next_id
    FROM(SELECT * FROM public.badge_award_events WHERE subject_id=sid AND (p_before IS NULL OR id<p_before) ORDER BY id DESC LIMIT p_limit) page;
  RETURN jsonb_build_object('enabled',true,'kind',kind,'badges',public._badge_rows_d(kind,target),'history',history,'next_before',next_id);
END $badge$;

CREATE FUNCTION public._badge_enqueue_d(p_kind text,p_target uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$ BEGIN
  IF p_kind='customer' AND NOT EXISTS(SELECT 1 FROM auth.users WHERE id=p_target) THEN RETURN; END IF;
  IF p_target IS NOT NULL THEN INSERT INTO public.badge_refresh_events(subject_kind,target_id) VALUES(p_kind,p_target); END IF;
END $badge$;
CREATE FUNCTION public._badge_enqueue_area_d(p_area uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$ BEGIN
  INSERT INTO public.badge_refresh_events(subject_kind,target_id)
    SELECT 'merchant',a.shop_id FROM public.badge_shop_areas current
    JOIN public.badge_area_assignments a ON a.id=current.assignment_id WHERE a.area_id=p_area;
END $badge$;
CREATE FUNCTION public._badge_enqueue_shop_d(p_shop uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$ BEGIN
  PERFORM public._badge_enqueue_d('merchant',p_shop);
  PERFORM public._badge_enqueue_area_d(public._badge_trusted_area_d(p_shop));
END $badge$;
CREATE FUNCTION public._badge_source_changed_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE customer uuid; shop uuid; root uuid; BEGIN
  IF TG_TABLE_NAME='verified_transactions' THEN customer:=NEW.customer_user_id; shop:=NEW.shop_id;
  ELSIF TG_TABLE_NAME='purchase_invalidations' THEN
    SELECT customer_user_id,shop_id INTO customer,shop FROM public.verified_transactions WHERE id=NEW.purchase_id;
  ELSIF TG_TABLE_NAME='service_evaluations' THEN
    SELECT user_id INTO customer FROM public.review_subject_keys WHERE subject_id=NEW.subject_id; shop:=NEW.shop_id;
  ELSE
    SELECT user_id INTO customer FROM public.review_subject_keys WHERE subject_id=NEW.subject_id;
    root:=NEW.review_id;
    FOR shop IN SELECT DISTINCT shop_id FROM public.review_revisions WHERE review_id=root AND shop_id IS NOT NULL LOOP
      PERFORM public._badge_enqueue_shop_d(shop);
    END LOOP;
    shop:=NEW.shop_id;
  END IF;
  PERFORM public._badge_enqueue_d('customer',customer);
  PERFORM public._badge_enqueue_shop_d(shop);
  RETURN NEW;
END $badge$;
CREATE TRIGGER badge_purchase_changed AFTER INSERT ON public.verified_transactions FOR EACH ROW EXECUTE FUNCTION public._badge_source_changed_d();
CREATE TRIGGER badge_invalidation_changed AFTER INSERT ON public.purchase_invalidations FOR EACH ROW EXECUTE FUNCTION public._badge_source_changed_d();
CREATE TRIGGER badge_service_changed AFTER INSERT ON public.service_evaluations FOR EACH ROW EXECUTE FUNCTION public._badge_source_changed_d();
CREATE TRIGGER badge_revision_changed AFTER INSERT ON public.review_revisions FOR EACH ROW EXECUTE FUNCTION public._badge_source_changed_d();
CREATE TRIGGER badge_lifecycle_changed AFTER INSERT OR UPDATE ON public.review_lifecycle FOR EACH ROW EXECUTE FUNCTION public._badge_source_changed_d();

-- C OFF still permits supported legacy reviews. Their edits/withdrawals must
-- wake the same worker without requiring any mobile app to open its badge page.
CREATE FUNCTION public._badge_legacy_review_changed_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE item uuid; target_user uuid; shop uuid; BEGIN
  IF TG_OP='DELETE' THEN item:=OLD.verified_transaction_item_id; target_user:=OLD.user_id;
  ELSE item:=NEW.verified_transaction_item_id; target_user:=NEW.user_id; END IF;
  SELECT t.shop_id INTO shop FROM public.verified_transaction_items i
    JOIN public.verified_transactions t ON t.id=i.verified_transaction_id WHERE i.id=item;
  PERFORM public._badge_enqueue_d('customer',target_user); PERFORM public._badge_enqueue_shop_d(shop);
  IF TG_OP='UPDATE' AND OLD.verified_transaction_item_id IS DISTINCT FROM NEW.verified_transaction_item_id THEN
    SELECT t.shop_id INTO shop FROM public.verified_transaction_items i
      JOIN public.verified_transactions t ON t.id=i.verified_transaction_id WHERE i.id=OLD.verified_transaction_item_id;
    PERFORM public._badge_enqueue_shop_d(shop);
  END IF;
  RETURN NULL;
END $badge$;
CREATE TRIGGER badge_legacy_review_changed AFTER INSERT OR UPDATE OR DELETE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public._badge_legacy_review_changed_d();

CREATE FUNCTION public._badge_shop_changed_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE old_area uuid; BEGIN
  IF TG_OP='UPDATE' AND (NEW.latitude IS DISTINCT FROM OLD.latitude OR NEW.longitude IS DISTINCT FROM OLD.longitude) THEN
    SELECT a.area_id INTO old_area FROM public.badge_shop_areas current JOIN public.badge_area_assignments a ON a.id=current.assignment_id WHERE current.shop_id=NEW.id;
    DELETE FROM public.badge_shop_areas WHERE shop_id=NEW.id;
    PERFORM public._badge_enqueue_area_d(old_area);
  END IF;
  PERFORM public._badge_enqueue_shop_d(NEW.id);
  RETURN NEW;
END $badge$;
CREATE TRIGGER badge_shop_changed AFTER INSERT OR UPDATE OF latitude,longitude,is_active,owner_user_id ON public.shops
  FOR EACH ROW EXECUTE FUNCTION public._badge_shop_changed_d();
CREATE FUNCTION public._badge_profile_changed_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE shop uuid; BEGIN
  PERFORM public._badge_enqueue_d('customer',NEW.id);
  FOR shop IN SELECT shop_id FROM public.verified_transactions WHERE customer_user_id=NEW.id
    UNION SELECT id FROM public.shops WHERE owner_user_id=NEW.id LOOP PERFORM public._badge_enqueue_shop_d(shop); END LOOP;
  RETURN NEW;
END $badge$;
CREATE TRIGGER badge_profile_changed AFTER UPDATE OF role ON public.profiles FOR EACH ROW EXECUTE FUNCTION public._badge_profile_changed_d();
CREATE FUNCTION public._badge_erase_account_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE sid uuid; shop uuid; BEGIN
  SELECT id INTO sid FROM public.badge_subjects WHERE user_id=OLD.id FOR UPDATE;
  IF sid IS NOT NULL THEN
    INSERT INTO public.badge_award_events(subject_id,badge_code,rule_version,event_kind,reason,qualification)
      SELECT sid,badge_code,rule_version,'revoked','account_removed',details-'next_check_at'||jsonb_build_object('eligible',false)
        FROM public.badge_current_state WHERE subject_id=sid AND eligible;
    UPDATE public.badge_current_state SET eligible=false,details='{}',next_check_at=NULL,checked_at=clock_timestamp() WHERE subject_id=sid;
  END IF;
  DELETE FROM public.badge_refresh_events WHERE subject_kind='customer' AND target_id=OLD.id;
  FOR shop IN SELECT shop_id FROM public.verified_transactions WHERE customer_user_id=OLD.id
    UNION SELECT id FROM public.shops WHERE owner_user_id=OLD.id LOOP PERFORM public._badge_enqueue_shop_d(shop); END LOOP;
  RETURN OLD;
END $badge$;
CREATE TRIGGER badge_erase_account BEFORE DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION public._badge_erase_account_d();
CREATE FUNCTION public._badge_erase_queue_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$ BEGIN
  DELETE FROM public.badge_refresh_events WHERE subject_kind='customer' AND target_id=OLD.id;
  RETURN OLD;
END $badge$;
CREATE TRIGGER badge_erase_queue AFTER DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION public._badge_erase_queue_d();

CREATE FUNCTION public.review_shop_area_assignment_v1(p_shop_id uuid,p_area_id uuid,p_reason text,p_request_id uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE actor uuid; s public.shops; area public.badge_local_areas; prior public.badge_area_assignments; assignment uuid; old_area uuid;
BEGIN
  PERFORM id FROM public.profiles WHERE id=auth.uid() AND role='admin' FOR SHARE;
  IF NOT FOUND THEN RAISE EXCEPTION '[BADGE_ADMIN_REQUIRED]' USING ERRCODE='42501'; END IF;
  PERFORM public._qr_auth_session_b(); actor:=public._review_subject_c(auth.uid());
  IF p_shop_id IS NULL OR p_area_id IS NULL OR p_request_id IS NULL OR p_reason IS NULL OR length(btrim(p_reason)) NOT BETWEEN 1 AND 500 THEN RAISE EXCEPTION '[BADGE_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  PERFORM subject_id FROM public.review_subject_keys WHERE subject_id=actor FOR UPDATE;
  SELECT * INTO s FROM public.shops WHERE id=p_shop_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION '[BADGE_SHOP_NOT_FOUND]' USING ERRCODE='P0002'; END IF;
  SELECT * INTO prior FROM public.badge_area_assignments WHERE actor_subject=actor AND request_id=p_request_id;
  IF FOUND THEN
    IF prior.shop_id<>p_shop_id OR prior.area_id<>p_area_id OR prior.reason<>btrim(p_reason) THEN RAISE EXCEPTION '[BADGE_REQUEST_CONFLICT]' USING ERRCODE='22023'; END IF;
    RETURN prior.id;
  END IF;
  SELECT a.* INTO area FROM public.badge_local_areas a JOIN public.badge_area_versions v ON v.id=a.version_id AND v.approved WHERE a.id=p_area_id;
  IF NOT FOUND OR NOT public._badge_area_covers_d(area.geometry,s.longitude,s.latitude) THEN RAISE EXCEPTION '[BADGE_AREA_UNVERIFIED]' USING ERRCODE='42501'; END IF;
  old_area:=public._badge_trusted_area_d(s.id);
  INSERT INTO public.badge_area_assignments(shop_id,area_id,latitude,longitude,actor_subject,reason,request_id)
    VALUES(s.id,area.id,s.latitude,s.longitude,actor,btrim(p_reason),p_request_id) RETURNING id INTO assignment;
  INSERT INTO public.badge_shop_areas VALUES(s.id,assignment) ON CONFLICT(shop_id) DO UPDATE SET assignment_id=excluded.assignment_id;
  PERFORM public._badge_enqueue_area_d(old_area); PERFORM public._badge_enqueue_shop_d(s.id);
  RETURN assignment;
END $badge$;

-- Trusted server worker only. Exact captured queue IDs prevent deleting an event
-- committed after the computation's snapshot. Unprocessed/late events survive.
CREATE FUNCTION public.process_badge_refresh_v1(p_limit integer DEFAULT 50) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE captured bigint[]; target record; count_targets integer:=0; changes integer:=0; BEGIN
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION '[BADGE_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  IF NOT public._badge_enabled_d() THEN RETURN jsonb_build_object('enabled',false,'processed',0); END IF;
  IF NOT pg_catalog.pg_try_advisory_xact_lock(pg_catalog.hashtextextended('esnaftavar.badge-worker.v1',0)) THEN
    RETURN jsonb_build_object('enabled',true,'busy',true,'processed',0); END IF;
  -- The advisory lock serializes workers. Do not hold queue row locks while
  -- taking subject/Auth FK locks: account erasure also removes pending events.
  SELECT array_agg(id) INTO captured FROM(SELECT id FROM public.badge_refresh_events ORDER BY id LIMIT 2000) batch;
  FOR target IN
    WITH candidates AS (
      SELECT s.subject_kind,CASE s.subject_kind WHEN 'customer' THEN s.user_id ELSE s.shop_id END target_id,0 priority
      FROM public.badge_current_state st JOIN public.badge_subjects s ON s.id=st.subject_id
      WHERE st.next_check_at<=clock_timestamp()
      UNION ALL SELECT subject_kind,target_id,1 FROM public.badge_refresh_events WHERE id=ANY(captured)
    ) SELECT subject_kind,target_id,min(priority) priority FROM candidates WHERE target_id IS NOT NULL
      GROUP BY subject_kind,target_id ORDER BY min(priority),subject_kind,target_id LIMIT p_limit
  LOOP
    changes:=changes+public._badge_recompute_d(target.subject_kind,target.target_id); count_targets:=count_targets+1;
    DELETE FROM public.badge_refresh_events WHERE id=ANY(captured) AND subject_kind=target.subject_kind AND target_id=target.target_id;
  END LOOP;
  RETURN jsonb_build_object('enabled',true,'processed',count_targets,'transitions',changes,
    'pending_events',(SELECT count(*) FROM public.badge_refresh_events),'checked_at',clock_timestamp());
END $badge$;
CREATE FUNCTION public.enqueue_badge_backfill_v1(p_after uuid DEFAULT NULL,p_limit integer DEFAULT 200) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE row_data record; last_id uuid; amount integer:=0; BEGIN
  IF p_limit IS NULL OR p_limit NOT BETWEEN 1 AND 500 THEN RAISE EXCEPTION '[BADGE_INVALID_ARGUMENT]' USING ERRCODE='22023'; END IF;
  FOR row_data IN SELECT id FROM(SELECT id FROM public.profiles WHERE role='customer' UNION SELECT id FROM public.shops) ids
    WHERE p_after IS NULL OR id>p_after ORDER BY id LIMIT p_limit LOOP
    IF EXISTS(SELECT 1 FROM public.profiles WHERE id=row_data.id AND role='customer') THEN PERFORM public._badge_enqueue_d('customer',row_data.id); END IF;
    IF EXISTS(SELECT 1 FROM public.shops WHERE id=row_data.id) THEN PERFORM public._badge_enqueue_d('merchant',row_data.id); END IF;
    amount:=amount+1; last_id:=row_data.id;
  END LOOP;
  RETURN jsonb_build_object('enqueued_targets',amount,'next_after',CASE WHEN amount=p_limit THEN last_id END);
END $badge$;

-- Dataset approval is an operator action, with history and refresh propagation.
CREATE TABLE public.badge_area_approval_events (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  version_id uuid NOT NULL REFERENCES public.badge_area_versions(id),
  approved boolean NOT NULL,
  recorded_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE FUNCTION public._badge_area_version_changed_d() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $badge$
DECLARE area uuid; BEGIN
  IF TG_OP='UPDATE' AND (NEW.dataset_name IS DISTINCT FROM OLD.dataset_name
    OR NEW.source_reference IS DISTINCT FROM OLD.source_reference OR NEW.dataset_sha256 IS DISTINCT FROM OLD.dataset_sha256
    OR NEW.recorded_at IS DISTINCT FROM OLD.recorded_at OR NEW.id IS DISTINCT FROM OLD.id) THEN
    RAISE EXCEPTION 'Dataset identity is immutable';
  END IF;
  INSERT INTO public.badge_area_approval_events(version_id,approved) VALUES(NEW.id,NEW.approved);
  FOR area IN SELECT id FROM public.badge_local_areas WHERE version_id=NEW.id LOOP
    PERFORM public._badge_enqueue_area_d(area);
  END LOOP;
  RETURN NEW;
END $badge$;
CREATE TRIGGER badge_area_version_changed AFTER INSERT OR UPDATE ON public.badge_area_versions
  FOR EACH ROW EXECUTE FUNCTION public._badge_area_version_changed_d();

ALTER TABLE public.badge_protocol_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_rule_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_current_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_award_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_refresh_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_area_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_local_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_area_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_shop_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badge_area_approval_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.badge_protocol_config FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_rule_versions FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_subjects FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_current_state FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_award_events FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_refresh_events FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_area_versions FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_local_areas FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_area_assignments FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_shop_areas FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON public.badge_area_approval_events FROM PUBLIC,anon,authenticated,service_role;
CREATE TRIGGER badge_rules_immutable BEFORE UPDATE OR DELETE ON public.badge_rule_versions FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER badge_awards_immutable BEFORE UPDATE OR DELETE ON public.badge_award_events FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER badge_areas_immutable BEFORE UPDATE OR DELETE ON public.badge_local_areas FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER badge_assignments_immutable BEFORE UPDATE OR DELETE ON public.badge_area_assignments FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
CREATE TRIGGER badge_approvals_immutable BEFORE UPDATE OR DELETE ON public.badge_area_approval_events FOR EACH ROW EXECUTE FUNCTION public._commerce_immutable_b();
REVOKE ALL ON FUNCTION public._badge_enabled_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_rules_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.badge_capabilities_v1() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_geometry_valid_d(jsonb) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_ring_d(jsonb,numeric,numeric) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_area_covers_d(jsonb,numeric,numeric) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_trusted_area_d(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_product_evidence_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_neighborhood_d(uuid,timestamptz) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_shop_details_d(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_customer_details_d(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_rows_d(text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_subject_d(text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_recompute_d(text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_badges_v1(uuid[]) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.read_my_trust_v1(uuid,integer,bigint) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_enqueue_d(text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_enqueue_area_d(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_enqueue_shop_d(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_source_changed_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_legacy_review_changed_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_shop_changed_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_profile_changed_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_erase_account_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_erase_queue_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public._badge_area_version_changed_d() FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.review_shop_area_assignment_v1(uuid,uuid,text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.process_badge_refresh_v1(integer) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.enqueue_badge_backfill_v1(uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.badge_capabilities_v1(),public.read_badges_v1(uuid[]) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.read_my_trust_v1(uuid,integer,bigint),public.review_shop_area_assignment_v1(uuid,uuid,text,uuid) TO authenticated;
-- Worker/backfill execution deliberately stays with the trusted database operator.
COMMIT;
