# Source audit for the Sound Check replacement plan

Research date: 2026-10-31. This is local source/data analysis, not an audio listening verdict or a live-chain audit. The browser retrieval tool could not load the supplied live URLs. Their behavior below is traced from the checked-out builders. No RPC configuration, secrets, transactions, deployments or remote writes were used.

## Isolated source snapshots

| Repository | Source HEAD | Dedicated detached worktree |
| --- | --- | --- |
| midi_fun_contract | `cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1` | `/tmp/beast-sound-scale-plan/midi` |
| beasts-v3 | `a7d13c676eafe84866795a8fa52d32c9fcc29e94` | `/tmp/beast-sound-scale-plan/beasts-v3` |
| beast-sound-check | `eb0cfefd27f68dd3a1778524f55eb932d40a4426` | `/tmp/beast-sound-scale-plan/sampler` |

Read `/workspace/AGENTS.md`, each contract repository's `AGENTS.md`, and the user's session instructions. Source checkouts were inspected but left untouched: midi was clean; beasts-v3 had unrelated untracked work; sampler had the restored `original-lab/` and a README change. Planning artifacts live only in the dedicated midi worktree. No commits were created.

## The user's original lab, not Casey's lab

The exact historical sampler is available through sampler Git objects:

- `439b264:index.html`: first release, generated 2026-10-05 17:04 UTC; page/player version 0.3.0; SHA-256 `25795a7df3ae1f5d7bb39854ab245ebb041c1e1e70863273ea89bfa5f65aa8c1`.
- `433f826:index.html`: animated release, generated 2026-10-05 18:30 UTC; page/player version 0.3.0; SHA-256 `fd64b55b9883925ff3916182ad1822164ac57586b2f18caaafa1d0e4f69450c7`.

The restored `/workspace/beast-sound-check/original-lab/{first-release,sound-check}.html` match these SHA-256 values. The original art accompanying a track is test allocation, not a canonical Beast-to-sound assignment. For example #406 happens to show Chupacabra; this is not evidence that Chupacabra already owns that music.

`audit-original-lab.py` reads both exact Git objects and decodes their MIDI (including running status). Its reproducible output, `original-presets.json`, includes all 20 preset programs/tempos and complete representative note/CC traces for #201 and #406.

Section 2, tracks 201–220, has programs `[0,1,2,3,4,5,6,7,8,9,12,13,14,15,16,17,18,19,50,65]`. Every preset demo has 49 notes and 15,360 ticks at PPQ480: 32 quarter-note beats. Its parts are an up/down C-major octave in eighths (15 notes), two held notes, an A-minor broken chord (16 notes), and a staccato phrase (16 notes). Programs14/15/16/18 use C3; the others C4. The first release uses 120BPM throughout; the animated version rotates 90/100/120/127.66/131.87/150/175BPM. Its ticks retain the same musical duration while the brief staccato gate adjusts to keep approximately40ms.

Current generator references: sampler `tools/gen_tracks.mjs:289` (tempo rotation), `:318` (`presetPhrase`), `:344` (20-preset loop). The historical Git objects, rather than a potentially changing generator, are the reference bytes.

Track406 is a different test, “Pan sweep ·120BPM”, using custom plain Triangle settings (`TRI`), not preset0's stepped Triangle Lead with delayed vibrato. At0–4s, eight quarter notes alternate C5/G5 with hard left/right pan; at4–12s,32 eighth notes repeat G4/A4/B4/C#5 while CC10 sweeps left→right→left; the16s loop leaves roughly4s of space. The whole-step tetrachord is not automatically the mode of a Beast's Species Song. Borrow its phrasing, pacing and stereo idea separately from its literal pitches and custom oscillator. Generator reference: sampler `tools/gen_tracks.mjs:566`–585; full trace in the audit JSON.

## Current Sound Check

midi source references:

- `offchain/beast-sound/src/lab.js:898`–943: JS reference and documentation.
- `beasts/beast_composer/src/composition/sound_check.cairo:44`–75: authored typed inputs.
- Same file`:81`–191: performed MIDI generation; `:193`–239: degree mapping and articulation.
- `beasts/beast_composer/inputs/src/lib.cairo:109`–118: `SoundCheckInputs`; `:231`–239: validation.

Current facts:

1. Three11-note blocks: four quarters, one held note, six sixteenths. Each next block enters at3960ticks and a degree higher. Three pitched channels on the same preset overlap briefly; eight kit notes close the check. The16,680tick score is17.375s at120BPM.
2. Unnamed key uses the species' canonical spread name. Mode overrides include Nue33→Phrygian and the six actual named scales. Named checks instead use the special name's key/mode/register.
3. Base preset uses `(species-1)%6` into that family's leads+plucks. A special name shifts it deterministically; mega selects50 or65 by that same index's parity.
4. Sound Check does not drift. `pure_composer.cairo:46`–79 applies drift only to Songs; the manager likewise treats checks as non-drifting in `packages/sound_manager/src/staff_audio.cairo:17`–23.
5. Sound effects are applied to a written check: effects1/3 choose a mega preset; tempo offsets are−25,000/−30,000/−45,000μs per quarter for1/2/3; effects2 use portato and3 accents. Echo and octave doubling belong to songs/editions, not the check. See `composition/performance.cairo:1`–60 and `pure_composer.cairo:63`–79.
6. Existing check `note()` floors shortened duration at60ticks. A new40tick note would be lengthened by portato unless the new check writer handles that boundary deliberately. Sampler `tools/production-composer.js` has a matching `performCheck` operation and must agree.

## What “matches the Species Song” means

- `lab.js:743`–789 and `:883`–895 define the written Species Song: species theme, spread key, rarity channels, balanced mix, weak ties and top-lead promotion; names do not change this shared song.
- `composition/genesis.cairo:53`–103 defines chosen themes,39↔40 swap, Nue override, and the true scales. Mode IDs4/5/6/7/8/26 are Dorian/Phrygian/Locrian/Aeolian/harmonic minor/Dorian#4. Never replace them all with a major or natural-minor interval table.
- `composition/full_midi.cairo:491`–605 defines the three six-preset families and mega lead selection. The theme voice's family lead is species-modulo3, while the highest-mean-pitch voice may play a different lead due to top-lead promotion. `:855`–914 is the actual topline resolution. Pairing artifacts record both roles.
- Harpy39 and Pegasus40 play each other's Species Song; current checks do not apply that swap. Their current check/song keys differ. The proposed shared check must take the published song's mode/tonic explicitly while retaining its own species pairing.
- All75 current lab written Song modes/tonics were compared with V3's committed shared Song recipe fields: zero key differences. The V3 fixture itself notes legacy whole-MIDI differences for1/2/3/37/73; do not infer byte-identical songs from the key comparison.
- Names53/70 are Asag/Metsavana in the V3 catalogue, with engine aliases Balrog/Ent. Prefer canonical V3 display names in review material; the ID remains authoritative.
- Species Songs can drift to a different key and phrasing over time. A fixed check can warm up the written palette; it cannot always predict a Live or replayed day without introducing temporal behavior. The exact drift-lab URL's `track=song` ignores edition/purchase controls`e` and`p`. Builder `offchain/beast-sound/onchain/drift-lab-demo.mjs:132`–155 invokes `genesisMidi` with layered drift and stand-in dayAnchor hashes.
- Yeti68 is a special175BPM arrangement with extra ornaments/avalanche. The supplied day20 demo retains G harmonic minor, tonic79(G5), dry Square5, but plays173BPM. This is the builder's deterministic demo context, not a chain block-hash claim. See child artifact`yeti-reference-analysis.json`.

## Release and launch boundaries

V3's `fixtures/sound-manager/manifest.json` pins midi release`v1.0.1`, revision`8d1d96e664bd35d468e66830324ef25a42fd58bd`, composer-input codec5/generation2, composer CASM80,645felts. Musical Sound Check/genesis/lab/pure-composer files do not differ between that pin and current midi`cdcad0a`. The sampler production manifest uses`e9b0f66c67c5d6ba1755753ad712d3a20f95ee00`, before the low-tonic composer fix; refreshing its production worker is part of qualifying the eventual release.

V3 `fixtures/sound-manager/shared-tracks.json` currently publishes75 **Songs**, including39↔40 swap. `scripts/deploy-sound.mjs:1`–38 installs those, and`--replace` deploys another manager; it never upgrades an installed manager in place. Distinguish changing engine check output from publishing/selecting a new check catalogue. Shared tracks are append-only (`originals.cairo:280`–312); their stored inputs cannot be rewritten. `set_engine_configuration` can retarget the composer before authority is renounced (`:638`–677). Retargeting alters all resolved tracks using that composer and needs song/edition regression evidence. Publishing another shared check preserves existing references; switch the species selection deliberately.

The general Sound Check phraser/table can retain input-layout, NFT-layout, storage and drift-epoch; no new network service is required. The separately requested exact Satori Song needs explicit authored-score representation and codec/packing review, as its dedicated feasibility report explains. Retain broader valid/future species behavior with a table fallback instead of restricting the protocol to75 IDs. Exact CASM size must be measured after implementation: the pinned pure composer has only1,275felts headroom below81,920.
