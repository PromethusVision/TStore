// LOCAL RESTORE METADATA ONLY. pg_dump omits an explicit owner-only ACL when it
// equals acldefault. The unchanged raw catalog oracle distinguishes it from NULL.
// Reconstruct that representation BEFORE baseline capture, with identical effective
// privileges. No app rows, role powers, client grants or migration payloads change.
import {check} from './classifier.mjs';
import {hash,stable} from '../live/common.mjs';
export function ownerAclPlan(rows){
 const names=['production_preview_private.testers','public.canonical_categories','public.canonical_category_qualification'];
 check(rows.length===3&&stable(rows.map(r=>r.name))===stable(names),'RESTORE_OWNER_ACL_SCOPE');
 for(const row of rows)check(row.owner==='postgres'&&row.rls===true&&row.forced===false&&row.acl===null&&row.effective_acl==='{postgres=arwdDxtm/postgres}','RESTORE_OWNER_ACL_SOURCE');
 return names.map(name=>`GRANT ALL ON TABLE ${name} TO postgres;`).join('\n');
}
export function restoreOwnerAclRepresentation(s){
 s.guard();
 const query=`SELECT coalesce(jsonb_agg(jsonb_build_object('name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'rls',c.relrowsecurity,'forced',c.relforcerowsecurity,'acl',c.relacl::text,'effective_acl',coalesce(c.relacl,acldefault('r',c.relowner))::text) ORDER BY n.nspname,c.relname),'[]') FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE (n.nspname='public' AND c.relname IN ('canonical_categories','canonical_category_qualification')) OR (n.nspname='production_preview_private' AND c.relname='testers')`;
 const before=JSON.parse(s.sql('postgres',query));
 const sql=ownerAclPlan(before);
 s.sql('postgres','BEGIN; '+sql+' COMMIT;');
 const after=JSON.parse(s.sql('postgres',query));
 const effective=rows=>rows.map(({acl,...row})=>row);
 check(stable(effective(before))===stable(effective(after))&&after.every(r=>r.acl===r.effective_acl),'RESTORE_OWNER_ACL_EFFECTIVE_IDENTITY');
 return {result:'PASS',scope:'LOCAL_RESTORE_EXPLICIT_DEFAULT_OWNER_ACL',tables:3,effective_privileges_changed:false,effective_before_sha256:hash(stable(effective(before))),effective_after_sha256:hash(stable(effective(after))),client_grants_added:0};
}
