# Canonical musical inputs

`beast_composer_inputs` is the shared schema for the pure Beast music library.
It uses only compiler-provided Starknet builtins for `Store` and builds under the
pinned Beasts2.20 and MIDI2.21 toolchains. It imports no NFT, payment, RPC or player
implementation. `beast_composer::inputs` re-exports these exact types.

The authoritative field declarations and validation are in `src/lib.cairo`.
`ComposerInputs` wire version4 is a full scalar CairoSerde stream preceded by4;
its variants are `SoundCheck=0`, `Song=1`. `GenerationInputs` wire version2 is2
followed by the full baseSong, without a recipe discriminator. Unknown versions,
invalid fields, boolean aliases, truncation and trailing data reject. Zero seeds
are ordinary values. The JS codec is `beast-sound/inputs`; literal independent
vectors are checked by both languages.

`GenerationInputs.base_song` is the complete immutable edition template. A fixed
purchase sample derives section count, rhythm seed, side, development, direction,
spacing and channel count/order from the supplied variation identity. An independent
`BEAST_SAMPLE_SHAPE_V1` hash also chooses the entry lag, inversion, ornament
amount/trills, optionally one fewer written canon voice (never below2), and an
optional countersubject only when the base permits one. Channel capacity is
clamped after those written-role choices. Motif, key/mode, tiers, family/program
identity, tempo, articulation and dynamics retain the edition template. These are
musical variations; they do not imply collision-free sampling. Generated inputs also
set explicit `section_rhythm: true`, including for zero variation identity; written
factory/shared bases use false. True derives independent section cell choices from
`BEAST_SECTION_RHYTHM_V1`, the existing rhythm seed and the section index, retaining
the family, density/trill vocabulary and final cadence. False preserves the written
repeated phrase exactly. No seed value or channel policy acts as a hidden mode. `generate_inputs` never fetches a hash. A manager must derive
and pin the purchase identity from its approved provenance.

The edition factory accepts immutable `EditionCompositionConfig`, an edition
index and validated `BeastMusicalIdentity`. Edition clocks/sales are manager policy.
It never swaps paid species39/40. For legacy musical parity, its score/program
identity uses name0 while the actual supplied name still controls key/ornaments.
`normalize_generation_identity` preserves the supplied species/name for a
manager's named drift group; never derive that group from score/program name0.
An initial shared Species Song39/40 source swap is authored once outside playback.

The split pure classes are `BeastPureGenerator` (factory+fixed sample) and
`BeastPureComposer` (complete matching MIDI+TinySynthSettings):

```text
get_generation_inputs(config, edition_id, identity) -> GenerationInputs
generate_inputs(base, variation_identity) -> ComposerInputs
compose(inputs, sound_effects) -> TinySynthSound
```

`compose` consumes authored fields directly. It does not reconstruct a token or
replace values with Genesis defaults. Song tonics24..96 are realized with audible
notes bounded to24..108 before scoring (cadence candidates have the same bounds);
mega octave copies therefore fit MIDI. SoundCheck has no unused tier knob; it accepts tonic0..103 because its
highest note is tonic+24, and does not octave-double. Theme register0 uses the
narrow walk;1/2 share the wider vocabulary. Normal and tenuto retain authored full
gates; staccato halves and portato quarters them by3/4 with a60tick minimum;
accent adds8 on bar downbeats subject to the ceiling.

Performance is transient and applied once before composition:

| Code | Tempo subtraction (microseconds/quarter) | Velocity lift | Articulation | Mega |
| --- | ---: | ---: | --- | --- |
|0|0|0|authored|no|
|1|25000|12|tenuto|yes|
|2|30000|8|portato|no|
|3|45000|15|accent|yes|

Tempo saturates at1 and velocity at127. `compose` returns the written recipe's
performance rendition without temporal hashes, births or chain state. Existing
legacy Drift remains available through its original entrypoints; this normalized
reference does not silently apply it.

Evolution is an optional, separately reviewed extension to this reference. The
unchanged downstream Beasts integration remains pinned to the full B1 commit
`eebed3a773283d4e103c1042ac372ba4bbf50f61`, including that extension. This split does
not re-pin or change that integration.

Focused offline qualification:

```sh
snforge test -p beast_composer normalized_score_parity --max-n-steps 4294967295 --max-threads 4 > /tmp/inputs-score.log
node scripts/inputs-parity.mjs /tmp/inputs-score.log
snforge test -p beast_contracts test_actual_pure --max-n-steps 4294967295 --max-threads 4
npm test --prefix offchain/beast-sound
```

The ignored `actual_sound_sample_*` tests are explicit offline evidence
captures. Build `scarb build -p beast_contracts` first: they load those actual
production Sierra files through `declare_from_file`, not test-class substitutes.

Different append IDs produce different purchase identities even within one block.
The deterministic generator samples a finite musical vocabulary; it does not
promise collision-free unlimited renditions or scan existing tracks to deduplicate.
Representative same-block repeats and adjacent editions are tested through the
actual generator/composer, beyond checking record IDs or seed inequality.
