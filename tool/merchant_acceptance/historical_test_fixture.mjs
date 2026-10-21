// Test fixture material only, never application acceptance. Historic positive
// cases must use the exact sources recorded in their proof; current sources are
// independently tested for rejection and qualified by the new profile.
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {dirname,resolve} from 'node:path';
import {execFile} from 'node:child_process';
import {promisify} from 'node:util';
import {digest} from './pilot_preparation_contract.mjs';
import {lf} from './pilot_publication_contract.mjs';
const exec=promisify(execFile);
export async function restoreHistoricalTestSources(repo,fixture,proofPath,commit,overrides={}){
  assert.notEqual(resolve(repo),resolve(fixture),'Test fixture must be separate');
  assert(/^[a-f0-9]{40}$/.test(commit));
  const proof=JSON.parse(await readFile(resolve(repo,proofPath),'utf8'));
  for(const source of proof.sources){
    assert(/^(lib|tool|supabase|docs)\/[a-zA-Z0-9_./-]+$/.test(source.path)&&!source.path.split('/').includes('..'));
    const {stdout}=await exec('git',['show',commit+':'+source.path],{cwd:repo,windowsHide:true,maxBuffer:4e6});
    assert.equal(digest(lf(stdout)),overrides[source.path]??source.sha256_lf,'Historical test input does not match pinned proof: '+source.path);
    await mkdir(dirname(resolve(fixture,source.path)),{recursive:true});
    await writeFile(resolve(fixture,source.path),stdout);
  }
}
