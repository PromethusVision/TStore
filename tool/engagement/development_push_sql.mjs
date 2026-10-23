import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';

// Review-only renderer, no database driver/remote URL/apply option. Historical
// proposal and migration files are inputs and are never rewritten.
export async function developmentPushSql() {
  const read = async path => (await readFile(new URL(`../../${path}`,import.meta.url),'utf8')).replaceAll('\r\n','\n');
  const foundation = await read('supabase/proposals/0016_engagement_foundation.sql');
  const dispatch = await read('supabase/proposals/0029_push_dispatch_i0.sql');
  const sessionSource = await read('supabase/migrations/20261015001800_0018_qr_claim_purchase_returns.sql');
  const start = foundation.indexOf('CREATE TABLE public.push_devices (');
  const helper = sessionSource.match(/CREATE FUNCTION public\._qr_auth_session_b\(\) RETURNS uuid[\s\S]*?END \$body\$;/)?.[0];
  if (start < 0 || !helper || !foundation.trimEnd().endsWith('COMMIT;') ||
      !dispatch.includes('\nBEGIN;') || !dispatch.trimEnd().endsWith('COMMIT;')) {
    throw new Error('push_source_boundary_changed');
  }
  const name = '_push_auth_session_development_v1';
  const sourceHash = value => createHash('sha256').update(value).digest('hex');
  const bannerlessFoundation = foundation.slice(start).replace(/COMMIT;\s*$/,'');
  const standaloneDispatch = dispatch.slice(dispatch.indexOf('\nBEGIN;')+7)
    .replace(/COMMIT;\s*$/,'').replaceAll('_qr_auth_session_b',name);
  return `-- DEVELOPMENT PUSH TRANSPORT V1 — separate reviewed proposal, NOT applied.
-- Only transport tables/RPCs; no banners, commerce, reward, review or QR activation.
-- Source LF SHA256 0016: ${sourceHash(foundation)}
-- Source LF SHA256 0029: ${sourceHash(dispatch)}
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
${helper.replaceAll('_qr_auth_session_b',name)}
REVOKE ALL ON FUNCTION public.${name}() FROM PUBLIC,anon,authenticated,service_role;
${bannerlessFoundation}
${standaloneDispatch}
-- Narrow server metadata lookup: do not grant table SELECT or expose chat copy.
CREATE FUNCTION public.read_push_notification_development_v1(p_notification_id uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $metadata$
 SELECT jsonb_build_object('id',n.id,'user_id',n.user_id,'type',n.type,'created_at',n.created_at)
 FROM public.notifications n WHERE n.id=p_notification_id
$metadata$;
REVOKE ALL ON FUNCTION public.read_push_notification_development_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.read_push_notification_development_v1(uuid) TO service_role;
COMMIT;
`;
}
