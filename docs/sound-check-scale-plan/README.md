# Beast Sound launch review

This branch stages review material, not musical implementation. Consolidation is deferred by user decision; launch music work continues in the existing Composer/Manager repository split. The baseline is upstream `caseywescott/midi_fun_contract` main at `cdcad0a` (2026-10-31).

- [Implementation plan](PLAN.md) and [source audit](source-audit.md).
- Deferred research only: [consolidation](CONSOLIDATION.md). User decided not to proceed; excluded from launch and from the active music work.
- [75-species pairing sheet](pairings.csv), [structured pairings](pairings.json), and [rationale](pairing-rationale.md). These are audition proposals; explicit user choices override heuristic rows.
- [Satori Species Song / Agony Bane assessment](satori-411/ASSESSMENT.md), with exact original MIDI/settings and reproduction evidence.
- [Cyclops whole-sequence preset assessment](cyclops-504/assessment.json).
- [Recorded review preferences](review-notes.json).

The source reference is the user's original Beast Sound Check, `Provable-Games/beast-sound-check` revision `433f826`, not Casey's lab. Pinned inputs from Beasts V3 and the sampler generator are in `references/`; they are review evidence, not production fixtures. Source-specific temporary paths in historical reports/JSON identify the original audit locations; use the links above for the consolidated evidence.

## Reproduce the audits

Install the existing Beast Sound dependencies with `npm ci --prefix offchain/beast-sound`, then run from the repository root:

```sh
node docs/sound-check-scale-plan/audit-pairings.mjs
node docs/sound-check-scale-plan/satori-411/reproduce-411.mjs
OMP=/path/to/onchain-midi-player node docs/sound-check-scale-plan/satori-411/compare-settings.mjs
SAMPLER=/path/to/beast-sound-check python3 docs/sound-check-scale-plan/audit-original-lab.py
```

The pairing audit uses this checkout's engine plus pinned local reference inputs. The last audit requires sampler Git history containing revisions `439b264` and `433f826`. To re-extract original Satori assets, set `ORIGINAL_LAB` to the restored `433f826:index.html` page and run `satori-411/extract-411.py`. No contract build or chain access is required for these review-only audits.
