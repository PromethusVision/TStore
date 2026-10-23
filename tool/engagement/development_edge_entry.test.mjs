import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';

test('actual Edge entry loads all imports and defaults closed without credentials',async()=>{
  const entry=new URL('../../supabase/functions/development-chat-push/index.ts',import.meta.url);
  const source=(await readFile(entry,'utf8')).replace(/from '([^']+)'/g,
    (_,path)=>`from '${new URL(path,entry).href}'`);
  let handler;
  globalThis.Deno={env:{get:()=>undefined},serve:fn=>{handler=fn;}};
  try {
    await import('data:text/javascript;base64,'+Buffer.from(source).toString('base64'));
    const response=await handler(new Request('https://example.invalid/worker',{method:'POST'}));
    assert.equal(response.status,503);
    assert.deepEqual(await response.json(),{status:'pending_configuration'});
  } finally {delete globalThis.Deno;}
});
