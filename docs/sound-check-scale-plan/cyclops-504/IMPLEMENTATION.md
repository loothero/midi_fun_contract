# Cyclops original 504 implementation

Species 64 uses the entire authored eight-sound sequence: programs 34–41, 342857 microseconds per quarter note (175 BPM), 38400 ticks / 27.42856 seconds. Original notes, velocities, gates, program changes and closing rest are preserved. The complete file is 735 bytes, SHA-256 `03783872ada54c91052ceb70fb80f35b4553702256ee589695c9eb09e6ce2ecb`.

All names, regular/shiny variants, effects 0–3 and drift use this same authored check. In particular, mega does not replace its eight sounds with programs 50/65, and generic tempo/articulation treatments do not alter it. This explicit exception preserves the user's whole-sequence choice. Species Songs, named/purchased songs and other checks retain their separate rules.

The settings generator supplies only eight timbres and the three sampled pulse waves they need. No new synth feature, input codec, storage, network service or family-wide preset expansion is introduced. Existing eight family/Yeti settings hashes remain unchanged. The legacy lab installs the new programs; the production sampler consumes `settingsKey: cyclops-check` and the exported settings helper.

The Cairo helper stores one exact 81-byte delta-encoded phrase and repeats it under the eight programs, avoiding unnecessary writer bytecode. Independent fixtures extracted from original sampler 433f826 verify every MIDI byte and the original settings. The source inputs' other fields remain validated before species dispatch; they intentionally do not retune this authored piece.

Validation in the isolated Cyclops worktree (temporary catalogue-owned dispatch hooks applied for compilation): JS reference tests passed, focused Cairo exact-MIDI/settings/effects tests passed, and `scarb build --package beast_contracts` succeeded. Pure Composer measured 81169 CASM felts with the previous generic checks plus Cyclops, below 81920. Combined catalogue/Satori size and full regression qualification remain integration responsibilities; this isolated measurement is not a deployment claim.

The general-check agent owns the two early-return hooks in `sound_check.cairo` and JS `lab.js`; this implementation commit supplies their helper modules and settings routing. No deployment or public lab publication was performed.
