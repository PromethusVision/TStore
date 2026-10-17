BEGIN READ ONLY;
SET LOCAL statement_timeout='15s';
SET LOCAL lock_timeout='2s';
SELECT jsonb_build_object(
 'schema_md5',md5((jsonb_build_object(
 'ledger',(SELECT coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name) ORDER BY version),'[]') FROM supabase_migrations.schema_migrations),
 'tables',(SELECT jsonb_agg(jsonb_build_object('name',n.nspname||'.'||c.relname,'rls',c.relrowsecurity,'force',c.relforcerowsecurity) ORDER BY n.nspname,c.relname) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.relkind='r' AND (n.nspname='public' OR (n.nspname='storage' AND c.relname='objects'))),
 'columns',(SELECT jsonb_agg(to_jsonb(x) ORDER BY table_name,ordinal_position) FROM (SELECT table_name,column_name,ordinal_position,data_type,udt_name,is_nullable,column_default FROM information_schema.columns WHERE table_schema='public') x),
 'functions',(SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'definition_md5',md5(pg_get_functiondef(p.oid)),'definer',p.prosecdef,'settings',p.proconfig,'anon',has_function_privilege('anon',p.oid,'EXECUTE'),'authenticated',has_function_privilege('authenticated',p.oid,'EXECUTE'),'service_role',has_function_privilege('service_role',p.oid,'EXECUTE')) ORDER BY p.oid::regprocedure::text) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend d WHERE d.classid='pg_proc'::regclass AND d.objid=p.oid AND d.deptype='e')),
 'policies',(SELECT jsonb_agg(to_jsonb(x) ORDER BY schemaname,tablename,policyname) FROM (SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check FROM pg_policies WHERE schemaname IN ('public','storage')) x),
 'indexes',(SELECT jsonb_agg(to_jsonb(x) ORDER BY tablename,indexname) FROM (SELECT tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public') x),
 'constraints',(SELECT jsonb_agg(jsonb_build_object('table',c.conrelid::regclass::text,'name',c.conname,'definition',pg_get_constraintdef(c.oid)) ORDER BY c.conrelid::regclass::text,c.conname) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public'),
 'triggers',(SELECT jsonb_agg(jsonb_build_object('table',c.relname,'name',t.tgname,'enabled',t.tgenabled,'definition',pg_get_triggerdef(t.oid)) ORDER BY c.relname,t.tgname) FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND NOT t.tgisinternal),
 'grants',(SELECT jsonb_agg(to_jsonb(x) ORDER BY table_name,column_name,grantee,privilege_type) FROM (SELECT table_name,column_name,grantee,privilege_type,is_grantable FROM information_schema.column_privileges WHERE table_schema='public' AND grantee IN ('PUBLIC','anon','authenticated','service_role')) x),
 'table_privileges',(SELECT jsonb_agg(jsonb_build_object('table',c.relname,'role',r.role,'privilege',v.privilege,'allowed',has_table_privilege(r.role,c.oid,v.privilege)) ORDER BY c.relname,r.role,v.privilege) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace CROSS JOIN (VALUES ('anon'),('authenticated'),('service_role')) r(role) CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),('REFERENCES'),('TRIGGER'),('MAINTAIN')) v(privilege) WHERE n.nspname='public' AND c.relkind='r'),
 'postgres_public_defaults',(SELECT coalesce(jsonb_agg(jsonb_build_object('kind',d.defaclobjtype,'acl',d.defaclacl::text) ORDER BY d.defaclobjtype),'[]') FROM pg_default_acl d JOIN pg_namespace n ON n.oid=d.defaclnamespace WHERE n.nspname='public' AND pg_get_userbyid(d.defaclrole)='postgres'),
 'public_event_triggers',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',e.evtname,'event',e.evtevent,'enabled',e.evtenabled,'function',e.evtfoid::regprocedure::text,'tags',e.evttags) ORDER BY e.evtname),'[]') FROM pg_event_trigger e JOIN pg_proc p ON p.oid=e.evtfoid JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public'),
 'buckets',(SELECT coalesce(jsonb_agg(jsonb_build_object('id',id,'public',public,'file_size_limit',file_size_limit,'allowed_mime_types',allowed_mime_types) ORDER BY id),'[]') FROM storage.buckets)))::text),
 'taxonomy_md5',md5(((SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM
 (SELECT id,parent_id,name,level,is_active,lifecycle_state,is_assignable,policy_class,professional_review_status,taxonomy_version
 FROM public.categories) x))::text),
 'function_authority',(SELECT jsonb_agg(jsonb_build_object(
 'signature',p.oid::regprocedure::text,'oid',p.oid,'owner',pg_get_userbyid(p.proowner),
 'acl',p.proacl::text,'definer',p.prosecdef,'settings',p.proconfig,'language',p.prolang,
 'volatile',p.provolatile,'parallel',p.proparallel,'strict',p.proisstrict,'leakproof',p.proleakproof,
 'return_type',p.prorettype,'cost',p.procost,'rows',p.prorows,'support',p.prosupport)
 ORDER BY p.oid::regprocedure::text) FROM pg_proc p WHERE p.oid IN
 ('public.create_chat_message_notification()'::regprocedure,'public.create_verified_purchase_notification()'::regprocedure)),
 'function_hashes',(SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'md5',md5(pg_get_functiondef(p.oid))) ORDER BY p.oid::regprocedure::text) FROM pg_proc p WHERE p.oid IN ('public.create_chat_message_notification()'::regprocedure,'public.create_verified_purchase_notification()'::regprocedure)),
 'ledger',(SELECT jsonb_agg(jsonb_build_object('version',version,'name',name,'statement_count',cardinality(statements),'source_sha256_lf',encode(sha256(convert_to(replace(array_to_string(statements,''),chr(13)||chr(10),chr(10)),'UTF8')),'hex')) ORDER BY version) FROM supabase_migrations.schema_migrations),
 'notification_count',(SELECT count(*) FROM public.notifications),
 'notification_rows_md5',(SELECT md5(coalesce(jsonb_agg(to_jsonb(n) ORDER BY id),'[]')::text) FROM public.notifications n),
 'public_table_count',(SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r'),
 'public_tables_without_rls',(SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind='r' AND NOT c.relrowsecurity),
 'products',(SELECT count(*) FROM public.products),'identities',(SELECT count(*) FROM public.product_identity),
 'catalog_decisions_enabled',(SELECT decisions_enabled FROM public.catalog_media_config),
 'other_active_ddl',(SELECT count(*) FROM pg_stat_activity WHERE pid<>pg_backend_pid() AND state='active' AND query ~* '\m(create|alter|drop|grant|revoke)\M'),
 'other_advisory_locks',(SELECT count(*) FROM pg_locks WHERE locktype='advisory' AND pid<>pg_backend_pid())
) AS evidence;
ROLLBACK;
