# Agony Bane Satori: a named composition derived from lab411

The shared Satori Species Song remains the exact original lab411 MIDI and untrimmed settings. The user additionally requested a recognizably different Agony Bane composition derived from that base. This is scoped to species44/name1; it does not reseed all names, change Manager architecture, or promise unique themes for every name.

## Written FX0 result for listening review

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

## Full Casey sound-effect behavior

The earlier palette exemption is removed. The authored score now uses the same `beast_v11::shape` phrase dynamics and `full_midi::beast_form_to_full_tracks_arranged` mega/echo arrangement as ordinary Casey Songs. The JS counterpart uses the existing v1.1 shaper and `beastFullMidi`. The contract/codec/storage architecture is unchanged.

| Effect | Actual arrangement |
|---|---|
| 0 | Exact original authored MIDI encoding, pan/channel mix and settings; name1 retains its derived written composition |
| 1 | Casey mega lead50/65, opposite-panned octave double on the other mega lead at75% velocity, full mega drum groove, normal tenuto gates and phrase dynamics |
| 2 | Casey echo on Hunter first pluck12,360ticks later at50% velocity, opposite pan and loop-end clipping; portato gates and phrase dynamics; the authored drum score is retained in Casey's compact running-status encoding |
| 3 | Both mega and echo, including octave double, full mega groove, full written profile3 gates and Casey phrase dynamics |

Mega lead choice is `(species + name) % 2`: shared Satori selects50 with65 as its double, while Agony Bane selects65 with50 as its double. The highest-mean-pitch voice is selected by the existing arranger. Base voices are0–2, the octave double is3, and echo is3 when alone or4 with the double. Effects use the normal Casey three-voice pans9/64/118 and the lead's opposite pan119; normal FX0 retains the reviewed50/40/80 pans and CC7=100 mix. The normal authored note dynamics remain exact at FX0; effects1–3 use Casey's pitch-range phrase arc and alternating bar-downbeat emphasis, rather than the earlier fixed-velocity approximation.

Mega uses the existing full Casey groove, including sixteenth hats and tier fills from the beginning. The authored pitched entrances and lead break remain; the standard mega groove replaces the authored drum intro/break. Echo-only retains the original drum arrangement. These behaviors are explicit uses of the existing arranger, not new effect profiles.

Settings are generated separately for all four combinations. FX0 remains the original exact palette/mix. Mega installs50/65 and the standard existing drum kit, including toms for all accepted tier fills; echo installs12. The original triangle/pluck/harp timbres and untrimmed balance remain available. No new waveform definition, external service or Composer class is introduced.

The named track continues receiving token `sound_effects`. Selection of a fixed global shared-Species-Song effect preset is a separate Manager policy and is not implemented here. The previous81870-felt named-only build does not qualify this expanded implementation; the complete new source must pass the81920-felt check after the parallel bounded size work.

## Verification

- Exact shared411 MIDI9720bytes and original synth settings remain unchanged.
- Node tests compare Casey's actual mapped fields, normalized progression/contour, real note timing, current codecs, old markers, purchased-base key inheritance and gate rules.
- Cairo tests compare all eight shared/named effect MIDI fingerprints, the named canonical wire hash, all four composed settings-bank hashes, drift marker/register preservation and the60tick staccato gate. Existing Casey shape/oracle regressions verify the shared dynamics helper remains unchanged.
- The complete production class is rebuilt to verify the size limit. The parent task must refresh the full Cairo parity record, paired V3 engine pin and preview build for the new immutable source revision; older proof from03083a8 is not reused as proof of changed music.

The independent effect oracle uses the original lab411 generator and an unmodified copy of Casey's `full_midi.js` pinned to `cdcad0a`; its phrase shaping is checked independently against the readable v1.1 policy. Production-renderer output is not used to generate its own expected result. `full-effects-golden.json` records the independently derived bytes, SHA256, tempo, tracks, programs and note counts. Feature tests additionally assert actual octave/pitch/velocity ratios, echo delay/tail clipping, opposite pan, selected settings coverage and sixteenth mega hats.
