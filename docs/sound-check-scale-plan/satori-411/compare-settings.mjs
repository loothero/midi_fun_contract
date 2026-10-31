import fs from 'node:fs';import vm from 'node:vm';
import {loadBank,bankData,ESSENTIALS} from '../../../offchain/beast-sound/onchain/tinychip/essentials.mjs';
import {pathToFileURL} from 'node:url';
const {decodeSettings}=await import(pathToFileURL((process.env.OMP || '/workspace/onchain-midi-player')+'/player/settings.js'));
let src=fs.readFileSync(new URL('../../../offchain/beast-sound/onchain/tinychip/synth_settings.mjs',import.meta.url),'utf8');src=src.slice(0,src.indexOf('const WAVE_TAGS')).replace(/^import .*$/mg,'').replace(/^export /mg,'');
const ctx={loadBank,bankData,ESSENTIALS};vm.createContext(ctx);vm.runInContext(src+'\nthis.generated=beastSynthSettings(bankData(),[0,15,17],[36,38,42,46,49]);',ctx);
const original=decodeSettings(fs.readFileSync(new URL('./track-411.settings.txt',import.meta.url),'utf8'));
const differences=[];
function diff(a,b,path='') { if(a&&b&&typeof a==='object'&&typeof b==='object'){for(const k of new Set([...Object.keys(a),...Object.keys(b)]))diff(a[k],b[k],path+'/'+k);}else if(a!==b)differences.push({path,original:a,current:b}); }
diff(original,ctx.generated);
fs.writeFileSync(new URL('./track-411.current-settings.json',import.meta.url),JSON.stringify(ctx.generated,null,2));
fs.writeFileSync(new URL('./settings-differences.json',import.meta.url),JSON.stringify(differences,null,2));
const expected=[['/timbres/1/operators/0/volume',8736,6814],['/timbres/2/operators/0/volume',5668,3968],['/timbres/2/operators/1/volume',2551,1785]];
if(JSON.stringify(differences.map(x=>[x.path,x.original,x.current]))!==JSON.stringify(expected))throw Error('Unexpected settings differences');
console.log('Verified exactly three current-vs-original differences: bass volume trim0.78 and two harp operator trims0.7. Preserve original settings for exact411.');
