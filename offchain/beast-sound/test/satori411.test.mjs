import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import { decodeInputs, encodeInputs, decodeGenerationInputs, encodeGenerationInputs } from '../src/inputs.js';
import { isSatori411Song, satori411Midi, satori411SongInputs, satori411PurchasedInputs, satori411PerformanceMidi } from '../src/satori411.js';
import { satori411SynthSettings } from '../onchain/tinychip/synth_settings.mjs';
const refs = new URL('../../../docs/sound-check-scale-plan/satori-411/', import.meta.url);
test('authored Satori reproduces the exact reviewed MIDI and original untrimmed settings', () => {
  assert.deepEqual(Buffer.from(satori411Midi()), fs.readFileSync(new URL('track-411.mid', refs)));
  assert.deepEqual(satori411SynthSettings(), JSON.parse(fs.readFileSync(new URL('track-411.settings.json', refs))));
});
test('Agony Bane base shares the authored score without replacing other saved Satori recipes', () => {
  const named = satori411SongInputs(1);
  assert.equal(named.arrangement.identity.name_variant_id, 1);
  assert.deepEqual(satori411Midi(named), satori411Midi());
  const old = decodeInputs([5n, ...JSON.parse(fs.readFileSync(new URL('current-satori-shared-inputs.json', refs))).map(BigInt)]).song;
  assert.equal(isSatori411Song(old), false);
  const partial = structuredClone(named); partial.treatment.rhythm_seed = old.treatment.rhythm_seed;
  assert.equal(isSatori411Song(partial), false);
  const other = structuredClone(named); other.arrangement.identity.source_species_id = 43n;
  assert.equal(isSatori411Song(other), false);
});
test('authored inputs retain current canonical wire versions and roundtrip', () => {
  const x = {kind:'Song', song:satori411SongInputs(1)};
  assert.deepEqual(decodeInputs(encodeInputs(x)), x);
  const base = {base_song:x.song}; assert.deepEqual(decodeGenerationInputs(encodeGenerationInputs(base)), base);
});
test('purchases keep the authored form with deterministic key/tempo variation; effects retain timbre identity', () => {
  const base = satori411SongInputs(1), a = satori411PurchasedInputs(base, 0n), b = satori411PurchasedInputs(base, 1n);
  assert.equal(isSatori411Song(a),true);assert.equal(isSatori411Song(b),true);
  assert.notDeepEqual(satori411Midi(a),satori411Midi(b));
  for(let fx=0;fx<4;fx++)assert.ok(satori411PerformanceMidi(1,fx).length>=9720);
  assert.deepEqual(satori411PerformanceMidi(1,0),satori411Midi());
});
