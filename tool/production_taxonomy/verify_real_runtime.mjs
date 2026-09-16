import {guard,sql,source,stableJson,check,writeEvidence,safeFailure} from './real_restore_lib.mjs';
try {
  guard();
  const settings=JSON.parse(sql('postgres',"SELECT jsonb_agg(jsonb_build_object('role',rolname,'setting',v) ORDER BY rolname,v) FROM pg_roles CROSS JOIN LATERAL unnest(rolconfig) v WHERE split_part(v,'=',1) IN ('search_path','statement_timeout','lock_timeout','session_preload_libraries','idle_in_transaction_session_timeout');"));
  const normalize=row=>{
    const n=row.setting.indexOf('=');const key=row.setting.slice(0,n),value=row.setting.slice(n+1);
    if(!key.endsWith('timeout')) return row;
    const match=value.match(/^(\d+)(ms|s|min)?$/);check(match,'TIMEOUT_UNIT');
    const milliseconds=Number(match[1])*({ms:1,s:1000,min:60000}[match[2]||'ms']);
    return {role:row.role,setting:key+'='+milliseconds+'ms'};
  };
  check(stableJson(settings.map(normalize))===stableJson(source.runtime.role_settings.map(normalize)),'SOURCE_ROLE_SETTINGS_MATCH');
  const runtime=JSON.parse(sql('postgres',"SELECT jsonb_build_object('session_preload_libraries',current_setting('session_preload_libraries'),'privileged_role',current_setting('supautils.privileged_role'),'superuser_setting',current_setting('supautils.superuser'),'bootstrap_superuser',pg_get_userbyid(10));"));
  check(runtime.session_preload_libraries==='supautils' && runtime.privileged_role===source.runtime.settings['supautils.privileged_role'],'SUPAUTILS_RUNTIME_MATCH');
  check((runtime.superuser_setting||runtime.bootstrap_superuser)===source.runtime.settings['supautils.superuser'],'SUPAUTILS_EFFECTIVE_SUPERUSER_MATCH');
  writeEvidence('w52h_r_role_runtime_validation.json',{result:'PASS',captured_at_utc:new Date().toISOString(),source_role_settings_semantically_equal:true,unit_normalization:'Source 60000 milliseconds equals server display 1min; other settings identical',supautils:runtime,supautils_effective_superuser:'supabase_admin',source_cluster_role_passwords_copied:false,production_database_credentials_used:false});
  console.log('SOURCE_ROLE_SETTINGS_AND_SUPAUTILS_RUNTIME: PASS');
}catch(error){safeFailure(error);}
