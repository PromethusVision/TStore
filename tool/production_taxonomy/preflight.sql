-- READ ONLY. Capture immediately before a separately authorized future write.
-- No credentials or personal row values. This is evidence, NOT a database backup.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
SELECT jsonb_build_object(
 'project_ref','mefhfvrgkwciubeajjeb', -- bind connection identity independently
 'captured_at_utc',now(), 'server_version',current_setting('server_version'),
 'migration_ledger',(SELECT jsonb_agg(jsonb_build_object('version',version,'name',name,
  'statements_md5',md5(coalesce(statements::text,''))) ORDER BY version)
  FROM supabase_migrations.schema_migrations),
 'counts',jsonb_build_object(
  'categories',(SELECT count(*) FROM public.categories),
  'roots',(SELECT count(*) FROM public.categories WHERE parent_id IS NULL),
  'children',(SELECT count(*) FROM public.categories WHERE parent_id IS NOT NULL),
  'products',(SELECT count(*) FROM public.products),
  'listings',(SELECT count(*) FROM public.shop_products),
  'shops',(SELECT count(*) FROM public.shops),
  'orphan_products',(SELECT count(*) FROM public.products p LEFT JOIN public.categories c ON c.id=p.category_id WHERE c.id IS NULL),
  'orphan_listings',(SELECT count(*) FROM public.shop_products sp LEFT JOIN public.products p ON p.id=sp.product_id LEFT JOIN public.shops s ON s.id=sp.shop_id WHERE p.id IS NULL OR s.id IS NULL)),
 'categories',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'parent_id',parent_id,'is_active',is_active,'sort_order',sort_order) ORDER BY id) FROM public.categories),
 'product_category_references',(SELECT jsonb_agg(jsonb_build_object('product_id',id,'legacy_category_id',category_id) ORDER BY id) FROM public.products),
 'listing_relation_fingerprint',(SELECT md5(string_agg(id::text||':'||shop_id::text||':'||product_id::text,',' ORDER BY id)) FROM public.shop_products),
 'shop_relation_fingerprint',(SELECT md5(string_agg(s.id::text||':'||coalesce(x.n,0)::text,',' ORDER BY s.id)) FROM public.shops s LEFT JOIN (SELECT shop_id,count(*) n FROM public.shop_products GROUP BY shop_id) x ON x.shop_id=s.id),
 'rls',(SELECT jsonb_agg(jsonb_build_object('table',relname,'enabled',relrowsecurity,'forced',relforcerowsecurity) ORDER BY relname) FROM pg_class WHERE relnamespace='public'::regnamespace AND relkind IN ('r','p')),
 'policies',(SELECT jsonb_agg(jsonb_build_object('table',tablename,'name',policyname,'command',cmd,'roles',roles,'using',qual,'check',with_check) ORDER BY tablename,policyname) FROM pg_policies WHERE schemaname='public'),
 'rpc_inventory',(SELECT jsonb_agg(jsonb_build_object('name',proname,'arguments',pg_get_function_identity_arguments(oid),'returns',pg_get_function_result(oid),'security_definer',prosecdef,'settings',proconfig,'acl',proacl,'body_md5',md5(prosrc)) ORDER BY proname,pg_get_function_identity_arguments(oid)) FROM pg_proc WHERE pronamespace='public'::regnamespace),
 'schema_columns_fingerprint',(SELECT md5(string_agg(table_name||':'||column_name||':'||data_type||':'||is_nullable||':'||coalesce(column_default,''),',' ORDER BY table_name,ordinal_position)) FROM information_schema.columns WHERE table_schema='public'),
 'constraints_fingerprint',(SELECT md5(string_agg(conrelid::regclass::text||':'||conname||':'||pg_get_constraintdef(oid),',' ORDER BY conrelid::regclass::text,conname)) FROM pg_constraint WHERE connamespace='public'::regnamespace),
 'indexes_fingerprint',(SELECT md5(string_agg(tablename||':'||indexname||':'||indexdef,',' ORDER BY tablename,indexname)) FROM pg_indexes WHERE schemaname='public'),
 'triggers_fingerprint',(SELECT md5(string_agg(tgrelid::regclass::text||':'||tgname||':'||pg_get_triggerdef(oid),',' ORDER BY tgrelid::regclass::text,tgname)) FROM pg_trigger WHERE tgrelid IN (SELECT oid FROM pg_class WHERE relnamespace='public'::regnamespace) AND NOT tgisinternal),
 'grants',(SELECT jsonb_agg(jsonb_build_object('table',table_name,'grantee',grantee,'privilege',privilege_type) ORDER BY table_name,grantee,privilege_type) FROM information_schema.role_table_grants WHERE table_schema='public'),
 'extensions',(SELECT jsonb_agg(jsonb_build_object('name',extname,'version',extversion) ORDER BY extname) FROM pg_extension)
) AS preflight_evidence;
COMMIT;
