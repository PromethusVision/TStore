// LOCAL TEST SUPPORT ONLY. Not imported or sealed by the execution package.
// Reuse reviewed restore logic. Archive/container parameters are the only
// adaptations; execution/security validators remain unchanged repository files.
import {mkdirSync,writeFileSync} from 'node:fs';
import {resolve,relative,isAbsolute,sep,dirname} from 'node:path';
import {pathToFileURL} from 'node:url';
import {check,root,read,hash} from './common.mjs';
export const originalArchive='8d98258430fbb7eeccc8ead4e09efa59189aad84e961bb754fe223f07c3fcbc8';
export const newestArchive='70d85d3da72ef272630d02307ba6362a8ba15daf92a30396d78d3ee759ea65d9';
export async function support({newest=false}={}){
 const path=process.env.W52LB_PROOF_DIR,rel=relative(root,path??root);
 check(isAbsolute(path??'')&&(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel)),'EXTERNAL_PRIVATE_PROOF_DIRECTORY');
 check(['w52kb-lbprepare','w52kb-lbproof'].includes(process.env.W52KB_CONTAINER),'LOCAL_CONTAINER_ALLOWLIST');
 globalThis.fetch=async()=>{throw Error('W52LB_EXTERNAL_NETWORK_FORBIDDEN');};
 const directory=resolve(path,'support');mkdirSync(directory,{recursive:true});
 const base='tool/production_preview_bridge/';
 const files=['local.mjs','restore.mjs','platform-reconstruction.mjs','baseline.mjs','http.mjs'];
 const destinations=new Map(files.map(f=>[resolve(root,base,f),resolve(directory,f)]));
 const once=(source,before,after)=>{check(source.split(before).length===2,'LOCAL_SUPPORT_ANCHOR');return source.replace(before,after);};
 const inventory=[];
 for(const f of files){
  const original=read(base+f);let source=original;
  if(newest&&f==='local.mjs')source=once(source,originalArchive,newestArchive);
  if(newest&&f==='restore.mjs')source=once(source,"toc.includes('TOC Entries: 965') && entries.length === 958","toc.includes('TOC Entries: 1073') && entries.length === 1066");
  if(!newest&&f==='baseline.mjs')source=once(source," WHERE version<>'20260916001200'"," WHERE version NOT IN ('20260916001200','20260919001300')");
  source=source.replace(/(\bfrom\s*|\bimport\s*)['"]([^'"]+)['"]/g,(all,prefix,target)=>{
   if(!target.startsWith('.'))return all;
   const absolute=resolve(dirname(resolve(root,base,f)),target);
   return prefix+JSON.stringify(pathToFileURL(destinations.get(absolute)??absolute).href);
  });
  writeFileSync(destinations.get(resolve(root,base,f)),source);
  inventory.push({source:base+f,source_sha256:hash(original),generated_sha256:hash(source)});
 }
 const local=await import(pathToFileURL(resolve(directory,'local.mjs')));
 const {restore}=await import(pathToFileURL(resolve(directory,'restore.mjs')));
 const {baseline,archiveRows}=await import(pathToFileURL(resolve(directory,'baseline.mjs')));
 const {HttpChecks}=await import(pathToFileURL(resolve(directory,'http.mjs')));
 return {...local,restore,baseline,archiveRows,HttpChecks,inventory,path};
}
