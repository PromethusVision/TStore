export {read,hash,json,stable,literal,root,project,version,name,payload,facade,functions,sourcePath,rollbackPath} from '../execution/common.mjs';
export {identifier} from '../../production_taxonomy/execution/common.mjs';
export const directory='tool/production_preview_bridge/live_v2';
export const authority='c978ed774be26eafdb7f60fbeff40fca1b21bad8';
export function check(value,code){if(!value)throw new Error('W52KBY_'+code);}
export const uuid=value=>typeof value==='string'&&/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/.test(value);
export const safeError=error=>error?.message?.match(/W52(?:KBY|JB|KB|H)_[A-Z0-9_]+/)?.[0]??'W52KBY_PRIVATE_ERROR_SUPPRESSED';
// Successful containment of a failed deployment is still a failed deployment.
export const operationSucceeded=(operation,result)=>result==='PASS'||operation==='rollback-bridge'&&result==='ROLLED_BACK';
