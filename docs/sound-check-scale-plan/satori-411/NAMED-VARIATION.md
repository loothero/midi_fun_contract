# Agony Bane Satori: a named composition derived from lab411

The shared Satori Species Song remains the exact original lab411 MIDI and untrimmed settings. The user additionally requested a recognizably different Agony Bane composition derived from that base. This is scoped to species44/name1; it does not reseed all names, change Manager architecture, or promise unique themes for every name.

## Result for listening review

| Written property | Shared Satori | Agony Bane Satori |
|---|---|---|
| Mode and mapped home | A Aeolian, tonic57 | C Aeolian, tonic48 |
| Authored register treatment | 2 | 0 (Casey's low named register) |
| Ornament profile | 0 | 1, no trill (Casey's Bane profile) |
| Progression | Am–F–C–G | Cm–Ab–Eb–Bb |
| Lead rhythm per active bar | 4:2:1:1 eighth-note slots | 3:3:1:1 eighth-note slots |
| First held lead gate / next onset | 920ticks /960ticks | 680ticks /720ticks |
| Duration and arrangement | 36bars/72seconds at120BPM | Same entrances, break, progression relationship and form |
| Palette | Triangle Lead0, Triangle Pluck15, Chip Harp17 and original drums | Same palette and original mix |

The named rendition moves all960 pitched notes nine semitones down and brings28 answering lead notes one eighth note earlier. Its melodic interval/order sequence, bass and harp patterns, drums and 48–56second break remain related to #411. Tests compare actual parsed note events, not just recipe metadata or hashes. This is a distinct low-register rhythmic interpretation of the existing motif, rather than a new unrelated theme.

The implementation copies Casey's named mode, tonic, ornament density and trill controls from the existing procedural named base. Casey's procedural `ThemeInputs.register_band` retains the species motif's register; the named register is encoded in its mapped tonic48/60/72 plus pitch class. The authored record selects its register treatment from that named tonic. JS checks the same controls through the unchanged `engine.mapV3` mapping. Relevant source is `genesis.cairo::song_inputs`, especially its species-theme choice and named-key override, and `lab.js::sampleTrackMidi`'s `theme === 'species'` branch. Neither generic mechanism is replaced.

Only new Satori name0/name1 generation defaults select the existing dual authored markers. The schema5/generation2 wire format and storage layout remain unchanged. Old unmarked recipes and other Satori names retain Casey's implementation. Earlier marked name1 bases with the shared register2 still retain their original written note/timing interpretation; low register0 explicitly selects the new phrase treatment. Drift retains this register treatment even when its existing weekly rule changes ornament density. Shared register2 does not silently acquire the named phrase through drift.

New edition-zero purchases from the named base retain its C-minor key and low-register phrase, with deterministic seed-tempo variation. Existing shared-base purchase treatment is retained. Historical purchases use their snapshotted base; edition1+ remains Casey's existing style engine, without a new authored-score edition framework.

## Sound-effect behavior and explicit limits

The named track continues receiving token `sound_effects`. The shared-Species-Song effect policy is a separate Manager change and is not implemented here.

The authored performance uses the existing tempo offsets, ceiling bounds and profile mapping. Profile1 staccato has the same60-tick minimum as the production v1.1 Song path; profile5 is portato; profile3 retains written gates, correcting the earlier authored helper which incorrectly shortened them. The original authored note dynamics and palette stay intact.

**This is not full special-profile parity with an ordinary procedural Casey Song.** The authored score retains its explicit palette exemption: it does not substitute mega programs50/65 or add the generic chip echo on effects2/3, and does not replace the reviewed note dynamics with v1.1's generated phrase-velocity arc. With its original ceiling127, effects primarily change tempo and, for profile5, gates. These limits must be visible during listening review; no new bank or scoring framework is introduced under a claim of complete effect parity.

The final complete Composer measures81,870 of81,920CASM felts with the pinned compiler/profile. Full mega/echo would require a separately considered size/artistic tradeoff. No deployment or class target is changed by this implementation.

## Verification

- Exact shared411 MIDI9720bytes and original synth settings remain unchanged.
- Node tests compare Casey's actual mapped fields, normalized progression/contour, real note timing, current codecs, old markers, purchased-base key inheritance and gate rules.
- Cairo tests compare the shared exact-reference hash, named canonical wire hash, all four named effect MIDI hashes, drift marker/register preservation and the60tick staccato gate.
- The complete production class is rebuilt to verify the size limit. The parent task must refresh the full Cairo parity record, paired V3 engine pin and preview build for the new immutable source revision; older proof from03083a8 is not reused as proof of changed music.
