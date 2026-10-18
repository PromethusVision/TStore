import assert from 'node:assert/strict';
import {request} from 'node:http';
import {resolve} from 'node:path';
import {docker,root} from './local.mjs';
import {projectPattern} from './safety.mjs';

// Pinned official test sink. No SMTP relay, external credentials or mail forwarding.
export const mailImage='ghcr.io/axllent/mailpit@sha256:94f6b70c1436defae6799d9ac7ff0eeff9540465b842026d5cdb018f1c0234ea';
export const templateImage='busybox@sha256:5cec3fc171c87218698e85a52af7087de727372aae264a787b8112901a5b0092';
export const callbacks=[
 'com.esnaftavar.app.merchant.pilot://login-callback/',
 'com.esnaftavar.app.merchant.pilot://login-callback/?auth_action=password_recovery',
 'io.supabase.tstore://login-callback/',
 'io.supabase.tstore://login-callback/?auth_action=password_recovery',
];
export const subjects={confirmation:'EsnaftaVar e-posta adresinizi doğrulayın',recovery:'EsnaftaVar şifrenizi yenileyin'};

export function assertOwnedAuth(s,project){
 assert(projectPattern.test(project));
 assert.equal(s.Name,`/supabase_auth_${project}`);
 assert.equal(s.Config.Labels['com.supabase.cli.project'],project);
 assert.equal(s.Config.Image,'public.ecr.aws/supabase/gotrue:v2.197.0');
 assert.equal(s.HostConfig.Privileged,false);
 assert.equal(s.HostConfig.NetworkMode,`${project}-network`);
 assert.equal(s.Mounts.length,0);
 assert.equal(Object.keys(s.HostConfig.PortBindings??{}).length,0);
 assert.equal(Object.keys(s.NetworkSettings.Networks).length,1);
}

// Docker secrets remain in process memory; never put them in argv, logs or proof.
function engine(method,path,data){
 return new Promise((ok,fail)=>{
  const body=data===undefined?undefined:Buffer.from(JSON.stringify(data));
  const req=request({socketPath:process.platform==='win32'?'//./pipe/dockerDesktopLinuxEngine':'/var/run/docker.sock',
   path:'/v1.47'+path,method,headers:body?{'content-type':'application/json','content-length':body.length}:{}},res=>{
    const parts=[];let n=0;res.on('data',b=>{n+=b.length;if(n>2e6)req.destroy(new Error('LOCAL_DOCKER_RESPONSE_TOO_LARGE'));else parts.push(b);});
    res.on('end',()=>res.statusCode<300||(res.statusCode===304&&path.endsWith('/stop?t=2'))?ok(Buffer.concat(parts).toString()):fail(new Error('LOCAL_DOCKER_OPERATION_FAILED')));
   });req.on('error',()=>fail(new Error('LOCAL_DOCKER_UNAVAILABLE')));req.setTimeout(30000,()=>req.destroy());req.end(body);
 });
}
const inspect=async name=>JSON.parse(await docker(['inspect',name]))[0];

export async function installLocalMail(run,db){
 assert.equal((await db.query('SELECT count(*)::int n FROM auth.users')).rows[0].n,0,'Fresh Auth fixture required');
 const auth=await inspect(`supabase_auth_${run.project}`);assertOwnedAuth(auth,run.project);
 const network=`${run.project}-network`,sink=`ev-mail-${run.project}`,templates=`ev-templates-${run.project}`;
 const names=(await docker(['ps','-a','--format','{{.Names}}'])).split(/\r?\n/);
 assert(!names.includes(sink)&&!names.includes(templates),'Do not adopt existing mail fixtures');
 const owned=[];
 async function add(name,spec){
  await engine('POST','/containers/create?name='+encodeURIComponent(name),spec);owned.push(name);
  await engine('POST',`/containers/${name}/start`);
 }
 const label={'esnaftavar.auth-mail':run.project};
 const common={Image:mailImage,Labels:label,HostConfig:{NetworkMode:network,Privileged:false,PublishAllPorts:false,CapDrop:['ALL'],SecurityOpt:['no-new-privileges:true']}};
 try{
  await add(sink,{...common,Env:['MP_DATABASE=/tmp/mail.db','MP_MAX_MESSAGES=100','MP_DISABLE_VERSION_CHECK=true'],
   HostConfig:{...common.HostConfig,ReadonlyRootfs:true,Tmpfs:{'/tmp':'rw,noexec,nosuid,size=32m'},PortBindings:{'8025/tcp':[{HostIp:'127.0.0.1',HostPort:'55434'}]}}});
  await add(templates,{...common,Image:templateImage,Entrypoint:['/bin/busybox'],Cmd:['httpd','-f','-p','8080','-h','/templates'],Healthcheck:{Test:['NONE']},
   HostConfig:{...common.HostConfig,ReadonlyRootfs:true,Mounts:[{Type:'bind',Source:resolve(root,'supabase/templates/pilot'),Target:'/templates',ReadOnly:true}]}});
  const env=new Map(auth.Config.Env.map(v=>{const i=v.indexOf('=');return [v.slice(0,i),v.slice(i+1)];}));
  for(const key of env.keys())if(key.startsWith('GOTRUE_SMTP_')||key.startsWith('GOTRUE_HOOK_'))env.delete(key);
  const settings={GOTRUE_SMTP_HOST:sink,GOTRUE_SMTP_PORT:'1025',GOTRUE_SMTP_ADMIN_EMAIL:'auth@fixture.invalid',GOTRUE_SMTP_SENDER_NAME:'EsnaftaVar',
   GOTRUE_SMTP_MAX_FREQUENCY:'1ms',GOTRUE_MAILER_AUTOCONFIRM:'false',GOTRUE_RATE_LIMIT_EMAIL_SENT:'1000',GOTRUE_RATE_LIMIT_TOKEN_VERIFICATIONS:'1000',
   GOTRUE_URI_ALLOW_LIST:callbacks.join(','),GOTRUE_MAILER_TEMPLATES_CONFIRMATION:`http://${templates}:8080/confirmation.html`,
   GOTRUE_MAILER_TEMPLATES_RECOVERY:`http://${templates}:8080/recovery.html`,GOTRUE_MAILER_SUBJECTS_CONFIRMATION:subjects.confirmation,GOTRUE_MAILER_SUBJECTS_RECOVERY:subjects.recovery};
  for(const [key,value]of Object.entries(settings))env.set(key,value);
  await engine('POST',`/containers/${auth.Id}/stop?t=5`);
  await engine('DELETE',`/containers/${auth.Id}`);
  await engine('POST',`/containers/create?name=supabase_auth_${run.project}`,{...auth.Config,Env:[...env].map(([k,v])=>k+'='+v),
   HostConfig:{NetworkMode:network,Privileged:false,PublishAllPorts:false},
   NetworkingConfig:{EndpointsConfig:{[network]:{Aliases:auth.NetworkSettings.Networks[network].Aliases}}}});
  await engine('POST',`/containers/supabase_auth_${run.project}/start`);
  assertOwnedAuth(await inspect(`supabase_auth_${run.project}`),run.project);
  const mail=await inspect(sink),web=await inspect(templates);
  assert.equal(mail.State.Running,true);assert.equal(web.State.Running,true);
  assert.deepEqual(mail.HostConfig.PortBindings,{'8025/tcp':[{HostIp:'127.0.0.1',HostPort:'55434'}]});
  assert.equal(Object.keys(web.HostConfig.PortBindings??{}).length,0);
  return {evidence:{image:mailImage,image_id:mail.Image,template_image:templateImage,template_image_id:web.Image,mail_api:'127.0.0.1:55434',smtp:'private Docker network only',relay:'DISABLED',
   confirmation:'ENABLED_LOCAL_ONLY',templates:'private HTTP / read-only mount',callbacks},cleanup};
 }catch(e){await cleanup();throw e;}
 async function cleanup(){
  for(const name of owned.reverse()){
   const state=await inspect(name);assert.equal(state.Config.Labels['esnaftavar.auth-mail'],run.project);
   // Only our disposable capture/template containers; no volumes or other fixture data removed.
   await engine('POST',`/containers/${state.Id}/stop?t=2`);await engine('DELETE',`/containers/${state.Id}`);
  }
 }
}
