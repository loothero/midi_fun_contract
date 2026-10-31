import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {expectedSatori} from './reference/satori-full-effects-oracle.mjs';
import {satori411PerformanceMidi} from '../src/satori411.js';
import {satori411SynthSettings} from '../onchain/tinychip/synth_settings.mjs';
for(const name of [0,1])for(let fx=0;fx<4;fx++)test(`Satori name${name} effects${fx} equals independent original-score/Casey-arranger oracle`,()=>{
  assert.deepEqual(satori411PerformanceMidi(name,fx),expectedSatori(name,fx));
});
test('normal original Satori settings stay byte-for-byte equivalent; effect palettes contain actual selected timbres',()=>{
  assert.deepEqual(satori411SynthSettings(),JSON.parse(fs.readFileSync(new URL('../../../docs/sound-check-scale-plan/satori-411/track-411.settings.json',import.meta.url))));
  for(let fx=0;fx<4;fx++){
    const s=satori411SynthSettings(fx===1||fx===3,fx>=2), slots=s.timbres.filter(x=>!x.drum).map(x=>x.slot);
    for(const p of [0,15,17,...(fx>=2?[12]:[]),...(fx%2?[50,65]:[])])assert.ok(slots.includes(p));
    assert.equal(slots.includes(50),!!(fx%2));assert.equal(slots.includes(12),fx>=2);
  }
});
