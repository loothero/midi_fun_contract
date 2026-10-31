# Consolidate Beast Music in beasts-v3 — deferred

**User decision, 2026-10-31: do not proceed.** Launch is in two days and the user judges the post-launch benefit insufficient. This proposal is retained only as historical research. It is outside the active launch scope, is not a prerequisite for any music change, and must not be resumed unless the user explicitly reopens it. Continue using midi_fun_contract for the Composer and beasts-v3 for the Sound Manager.

Plan only, assessed on 2026-10-31. No implementation, contract changes, declarations, deployments or chain-state verification are part of this assessment. Updated after review to bound the migration and require explicit MIT preservation in beasts-v3.

## Historical recommendation (superseded by user decision)

Make `Provable-Games/beasts-v3` the source and release owner for all **Beast-specific** music: the Cairo composer, pure generator/composer classes, canonical inputs/codecs, TinyChip settings, JS reference engine, musical fixtures, parity tools and authoring labs. Keep its existing Sound Manager in its own package and contract. Keep the generic Cairo MIDI library and generic player implementation as separately pinned dependencies.

This is a repository/package consolidation, not an onchain contract merger. It removes cross-repository coordination when changing Beast music without coupling every composer change to manager storage, NFT code or player implementation. The existing Cairo design already supports this: `core/` does not depend on `beasts/`, and the upstream move guide describes replacing the workspace's local `midi` dependency with a pinned Git dependency. That guide is useful evidence, but incomplete for today's inputs package and V3 release tooling. [M1]

Start with a behavior-preserving import. Do not combine it with the 75-species music redesign in [PLAN.md](PLAN.md), codec redesign, generator changes, new token decoding, mass formatting or onchain updates. Once the imported release is qualified, that music roadmap can be implemented entirely in beasts-v3 through separate changes.

**Superseded recommendation:** the prior review recommended a bounded source consolidation. The user has rejected proceeding for this launch; the migration phases and gates below are inactive reference material.

The initial migration has four fixed boundaries:

- Preserve music, MIDI/settings output, codecs, public package APIs, manager storage and historical purchase interpretation. Investigate artifact changes independently of musical changes.
- Keep Manager, Generator and Composer as separate contracts/packages, and generic MIDI/player implementations as immutable external dependencies.
- Keep current released engine artifacts and deployment records authoritative until the local build passes qualification. Source consolidation requires no deployment or target update.
- Preserve MIT licensing for the imported Beast music code and its future first-party modifications, with explicit V3 license coverage in the source-import change.

## Verified baseline

Both source repositories were fetched from `origin main` and inspected in new detached worktrees. Existing working copies were not used as authoritative source and their uncommitted work was left untouched.

| Source | Fresh main inspected | Relevant state |
|---|---|---|
| `caseywescott/midi_fun_contract` | `cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1` | Five production workspace packages; JS package `beast-sound`; separate benchmark workspace |
| `Provable-Games/beasts-v3` | `7e9f19df93dccbe06eb8685e0a96fd89d594ce08` | `packages/sound_manager` imports `beast_composer_inputs` at upstream tag `v1.0.1`, locked to `8d1d96e664bd35d468e66830324ef25a42fd58bd` |
| Engine fixtures in beasts-v3 | `v1.0.1` / `8d1d96e…` | Composition codec 5; generation codec 2; manager and composer drift epochs 43,200 blocks; Scarb 2.21.0 / Foundry 0.64.1 |

`git diff 8d1d96e… HEAD -- beasts core Scarb.toml Scarb.lock` is empty in fresh MIDI main. Importing its current Cairo music code therefore need not also be an engine-source upgrade. The newer main includes offchain lab work outside those paths; preserve and review its independent provenance. [M2, V1]

Both repositories now pin Scarb 2.21.0 and Foundry 0.64.1. Their **Cairo editions differ**: MIDI's workspace default is `2025_12`, V3's is `2024_07`; `beast_composer_inputs` explicitly uses `2024_07` and depends only on Starknet. A common compiler does not make an unreviewed edition change safe. Some upstream READMEs still describe older compiler/codec pins; manifests, source constants and the locked fixture manifest establish the current baseline. [M2, M3, V1]

No conclusion about current mainnet/sepolia upgrade authority, ownership renunciation, registry locks or installed classes is made here. Source documents describe a launch patch window and finalization process; they do not establish live authority today. [V2]

## Current dependency and responsibility boundary

```text
onchain-midi-player::tinysynth_interface (canonical sound types/interface)
  ├─ midi_fun_contract::midi (generic SMF, packing, types/interfaces)
  │   ├─ midi_contracts (generic MidiSoundPage + ScaleMidiProvider example)
  │   ├─ beast_composer ── beast_composer_inputs
  │   └─ beast_contracts ── beast_composer
  │        ├─ BeastPureGenerator (storage-free musical generation)
  │        ├─ BeastPureComposer (storage-free MIDI + matching settings)
  │        └─ legacy BeastMidiProvider / BeastSoundComposer
  └─ beasts-v3
      ├─ beasts_core / NFT / renderer
      └─ beasts_sound_manager ── beast_composer_inputs (currently Git-pinned)
           ├─ generation/composition through declared class library dispatchers
           └─ tracks, payment, edition clock, births, modes, hashes and provenance
```

The manager intentionally imports shared typed inputs without importing the whole composer/MIDI/player implementation graph. Keep that boundary after the packages share a repository. The NFT owns no tracks or music storage; its renderer calls the species manager through `beasts_sound_manager_v2` and passes returned sound to the player. [M2–M4, V2, V3]

The pure generator and composer are separate classes deliberately: the generator source explicitly cites keeping composer CASM within the limit. The pinned composer uses 80,645 of 81,920 CASM felts, leaving 1,275. Combining them or compiling their implementations into the manager is a materially different architecture and has no demonstrated need for this task. [M4, V1]

## Migration inventory

| Existing owner/path | Destination/action | Required preservation or boundary |
|---|---|---|
| MIDI `beasts/beast_composer/` | V3 `packages/beast_composer/` | Keep package name `beast_composer`, implementation, tests and `inputs` re-export; explicitly retain edition `2025_12` |
| MIDI `beasts/beast_composer/inputs/` | V3 `packages/beast_composer/inputs/` | Keep package name `beast_composer_inputs`, codec versions/Serde/Store derives, edition `2024_07`, compiler-portable dependency boundary; add as explicit workspace member |
| MIDI `beasts/beast_contracts/` | V3 `packages/beast_contracts/` | Keep package/class/module names initially, pure and legacy contracts, tests and generated synth settings; fix its relative composer path; retain edition `2025_12` |
| MIDI `core/midi/` | Stay in MIDI, pinned Git dependency of V3 workspace | Generic SMF writing, byte packing, shared interfaces/types; do not maintain a second canonical source copy |
| MIDI `core/midi_contracts/` | Stay in MIDI | Generic `MidiSoundPage` and non-Beast `ScaleMidiProvider`; no V3 runtime dependency on these contracts is needed |
| MIDI `offchain/beast-sound/` | V3 `offchain/beast-sound/` initially | Move JS engine, wire codecs/types, CLI, server, labs, TinyChip banks/settings, tests, lockfile and committed generated assets; keep exports/package identity stable |
| MIDI `scripts/*parity*`, Beast-specific `scripts/tinysynth_e2e/` | V3 `scripts/music/` | Move the reference checks with their Cairo test cases, repair relative roots/imports/output paths and documented working directories |
| MIDI `docs/beasts/composition_guide.md`, Beast package guides | V3 `docs/music/` and package READMEs | Preserve authorship, correct stale baseline claims only when verified; point future contributors to the new source owner |
| MIDI `bench/` | Split ownership at its existing package boundary | Keep generic MIDI/page/example measurements in MIDI; migrate Beast benchmark cases/harness/expected data into V3 `tools/music-bench/`; preserve frozen expected outputs rather than regenerate them from the candidate |
| MIDI `.github/workflows/test.yaml`, `TESTING.md` | V3 CI routing + music testing guide | Port three Beast package test responsibilities and JS/generator drift checks; leave generic package jobs in MIDI |
| V3 `packages/sound_manager/` | Stay where it is | Change only canonical input dependency/wiring for import; keep storage, payment, authorization, append IDs, selection/mode and dispatch behavior |
| V3 `fixtures/sound-manager/` and `scripts/sound-manager-fixtures.mjs` | Retain, adapt source/build provenance model | Current script requires a Git tag/branch lock entry and upstream source paths; a local path is not supported by simply editing Scarb.toml |
| V3 `scripts/deploy-sound.mjs`, offline tests and deploy records | Retain, add V3 engine build source support | Build the release's exact engine source; verify expected hashes; continue supporting historical upstream records; do not rewrite old records |
| V3 `assets/player-page/`, `packages/erc721/src/player_page.cairo` | Retain current canonical route and generator | These fragments come from onchain-midi-player, not MIDI's legacy page generator; preserve hashes, adaptation and notices |
| V3 sound metadata/packing fixtures, real-manager integration and lab-contract fixtures | Retain | Current and historical Sierra fixtures are distinct evidence, not disposable duplicate builds |
| External `beast-sound-check` consumer | Adapt separately to new source root | `BEAST`/`BEAST_SONGS`, source hash paths, temporary Cairo parity fixture paths and footer provenance currently assume MIDI's layout |

The import is larger than copying three Scarb packages: the MIDI repository has 501 tracked files, 355 under `offchain/beast-sound/`. Importing that subtree once preserves its working authoring environment; classify generated pages, committed fixtures and server tooling before subsequent cleanup. Do not accidentally import credentials, node_modules, target outputs or deployment state. [M1, M5–M7, V1, V4, C1]

## Proposed beasts-v3 layout

```text
beasts-v3/
  packages/
    sound_manager/                 # existing manager, independent contract
    beast_composer/                # package beast_composer
      inputs/                      # package beast_composer_inputs
      src/composition/             # songs, names, editions, performance, drift
    beast_contracts/               # package beast_contracts; pure/legacy classes
  offchain/beast-sound/             # ESM package beast-sound; engines, codecs,
                                   # CLI/server, musical authoring labs and generators
  scripts/music/                    # Cairo↔JS parity and Beast-specific qualification
  tools/music-bench/                # isolated Beast performance/size harness
  assets/player-page/               # existing reviewed player fragments
  fixtures/sound-manager/           # current release artifacts + manifest
  tools/lab-contracts/fixtures/     # existing historical class fixtures
  docs/music/                      # composition, authoring, release/migration guide
  Scarb.toml                       # existing workspace + three Beast packages
  Scarb.lock
  pnpm-workspace.yaml              # add offchain/beast-sound
```

Retaining `offchain/beast-sound` initially preserves existing JS import/export structure and avoids mixing location changes with packaging redesign. Putting musical labs under that package also avoids confusing them with V3's existing Beast Lab, which manages test tokens, catalogues and chain interactions. A later cosmetic move to a differently named tools directory is optional.

Keep `beast-sound` as a separate workspace package instead of merging its exports into `@provable-games/beasts-sdk`. The SDK currently exports manager interface IDs, metadata/identity utilities and its own generated tables; it does not expose the reference composer as its music API. Preserve `beast-sound`, `beast-sound/engine`, `beast-sound/chain`, `beast-sound/inputs`, TypeScript declarations and CLI command. Do not claim the existing `1.0.0` package is actually published: publication/consumer ownership needs confirmation. Adding a scoped alias or SDK convenience wrapper is optional follow-up work. [M5, V5]

The first move should register `offchain/beast-sound` with pnpm and migrate its dependency lock deliberately, keeping the actual dependency versions unchanged. V3 requires Node >=22 and pins 22.22.3; beast-sound currently allows >=20. Validate on V3's pinned Node version before changing its support statement. Avoid adding empty `typecheck`/build scripts solely to satisfy recursive workspace commands; configure the existing workspace checks deliberately. [M5, V5]

## Import, ownership and history

Use one normal source import commit at the inspected source revision, retaining the upstream MIT license, copyright notices and a file/path mapping. Record the full source SHA and link upstream history in the commit and package NOTICE. This is the default, bounded approach; a filtered history import is optional only if it is straightforward. Neither history rewriting nor permanent subtree synchronization is a prerequisite.

V3 becomes canonical for new Beast music releases. Coordinate a small upstream follow-up marking moved directories and their last supported release; stop dual authoring. Keep `v1.0.0`, `v1.0.1`, historical commits and reproducible upstream archives available. Consumers can transition on their own release schedule. No upstream deletion or archival is required for the V3 import to work.

Do not fork the entire generic MIDI/player system into V3 by default. Adding a pinned `midi` Git dependency is the same build-time relationship already anticipated upstream; it introduces no render-time service or RPC. If generic MIDI development later stalls and changes become necessary, assess a clearly owned vendored/forked library separately. The current task does not demonstrate that maintenance cost is warranted. [M1]

### Required beasts-v3 licensing update

The migration must keep the imported Beast music code MIT, as it is in midi_fun_contract. A NOTICE alone is insufficient for a clear repository policy: update V3's root `LICENSE` in the same change that imports the code. The current root already preserves MIDI Fun/music MIT rights and lists Sound Manager Cairo source as MIT, but does not explicitly list the incoming packages and tools. [M8, V6]

Required changes in beasts-v3:

1. **Expand the root MIT coverage list.** Explicitly cover `packages/beast_composer/` (including `inputs/`), `packages/beast_contracts/`, `offchain/beast-sound/`, `scripts/music/`, `tools/music-bench/` and `docs/music/`, including their tests, first-party fixtures and generated music code/data. Cover any first-party music helpers placed outside those directories by exact path. State that first-party modifications and additions in these music paths remain MIT; they do not acquire the root reserved-code restrictions. Separately licensed embedded components keep their existing terms.
2. **Retain the complete upstream MIT text.** Preserve `licenses/MIDI_FUN_MIT_LICENSE` and `Copyright (c) 2024-2026 Casey Wescott` verbatim. Its current text matches the inspected upstream license; verify that match at import. Record the imported source revision in the relevant NOTICE rather than modifying the upstream license text. Keep upstream file notices; add Provable Games attribution for its contributions without replacing Casey's notice. Use the existing `licenses/MIT_LICENSE` for Provable Games contributions.
3. **Make the license discoverable at each imported package boundary.** Give the two Cairo packages, nested inputs package and JS package a NOTICE pointing to both applicable MIT texts and the import revision/path map. Keep or add `license = "MIT"` / `"license": "MIT"` metadata where supported. Distributable package archives must include the applicable full license texts and notices, not only links to files outside the archive.
4. **Update the existing Sound Manager NOTICE.** Retain its MIT coverage and historical upstream attribution, and document the new local canonical source plus imported baseline. Do not rewrite old release provenance or suggest that all future music is still the old v1.0.0 release.
5. **Preserve embedded third-party terms and generated notices.** TinySynth/player Apache-2.0 components and other third-party material retain their own licenses. Generated lab/download HTML must continue carrying their applicable notices. The root MIT list does not relicense these components, reserved renderer/card implementations or unrelated assets. Imported original music retains its existing MIT terms; unrelated uploaded music retains its own terms.

Suggested root `LICENSE` wording alongside the explicit path list:

> The Beast music packages, tools and documentation listed above, including their first-party modifications and additions, are MIT-licensed. Imported MIDI Fun material retains the copyright and license in licenses/MIDI_FUN_MIT_LICENSE; Provable Games contributions are MIT under licenses/MIT_LICENSE. The reserved-code production, registration and royalty restrictions do not apply to this MIT material. Embedded third-party components retain their separately stated terms.

**License acceptance gate:** review the actual import path map against the root MIT list; compare the upstream license text; inspect package metadata/NOTICES and any distributed package contents; confirm generated outputs retain third-party notices. No imported MIT first-party music path may fall through to the root reserved default. Missing coverage blocks the source import, not merely a later release. This uses the existing license files and notices; no new licensing service or broad compliance framework is needed.


## Scarb wiring and artifact compatibility

Required changes for the first import:

1. Add the three packages to V3's explicit workspace membership. Preserve names and version `0.1.0` initially. Explicitly set imported composer/contracts edition to `2025_12`; do not inherit V3's `2024_07` unintentionally. Keep inputs' explicit `2024_07` and Starknet-only normal dependencies.
2. Add workspace `midi` pointing at an immutable upstream revision, initially the same verified source as the import. The existing direct `tinysynth_interface-v0.1.1` reference should continue to resolve to the same canonical sound types across the graph. Confirm the resulting lock has one intended input package identity and no residual external copy of `beast_composer_inputs`.
3. Point the manager at local `../beast_composer/inputs` and composer at its local `inputs`; point beast_contracts at the moved composer. V3 already has matching access/interfaces/Starknet/Foundry dependencies; add its missing `openzeppelin_upgrades = 4.0.1` workspace entry for the legacy provider. Keep the existing exact constraints where available.
4. Preserve imported package test scripts' bounded parallelism. V3's workspace test command currently has no explicit four-thread bound; do not silently make the heavier music tests inherit unlimited host concurrency. Align formatter settings without applying V3's module-item sorting across imported source in the migration commit.
5. Resolve and review `Scarb.lock` changes, then require subsequent builds/tests to leave it unchanged. Inspect package IDs and built artifacts, not only version numbers.

A local package path and changed workspace context **may** affect emitted artifact metadata or class identity. Preservation is an acceptance test, not an assumption. Before any release cutover, compare old/new Sierra class hashes, ABI, CASM size and meaningful byte output. Full Sierra JSON equality is useful where reproducible; deployed class hash equality is the practical identity criterion. Treat any mismatch as a separate reviewed engine release, not an incidental rename. [M2–M4, V1, V4]

Keep the current pinned Sierra fixtures unchanged during an initial source import if the candidate build has not passed qualification. Those historical artifacts remain the manager's existing test/deployment reference while the local source is being proven.

## The release/build workflow that must change

Today `sound-manager-fixtures.mjs` derives engine repository/tag/commit from the **Git lock entry for inputs**, demands that exact textual dependency in the manager's Scarb.toml, fetches and archives that revision, and builds `beast_contracts` from upstream paths. Its input constants, composer drift constant and artifact paths are hardcoded. `deploy-sound.mjs` similarly fetches or archives the manifest's source revision, builds missing engine classes with that source's toolchain and refuses mismatching class hashes. Merely replacing the dependency with a path would break these safeguards. [V4]

Adapt the existing manifest rather than introduce a second release database:

- Record the canonical source repository, immutable release revision, build manifest/package paths, compiler/profile, input versions, both drift constants, Sierra/class hashes and CASM sizes. For new releases these point to beasts-v3; preserve old upstream manifests/records as historical provenance.
- Validate local source/codec constants and the built artifacts directly; a local input path has no external lock commit from which to infer the engine release. Preserve typed ABI checks and compiled-consumer checks.
- Separate candidate generation from immutable release publication. A build from an uncommitted tree may support local review, but a release/deployment must identify the exact committed source tree used. Avoid a self-referential manifest that tries to store the commit hash of the commit containing itself: build a source commit, then record its immutable SHA and artifacts in the subsequent release/fixture commit, or use an equivalent immutable source-tree binding with a documented procedure.
- Continue rebuilding historical upstream engine classes from their existing exact source when needed. New V3 releases can use the same Git-archive approach against V3 and its new paths. Keep `--midi-repo` compatibility for old releases while adding an explicit new source-checkout option if required.
- Update tests, source/capture hashes, `fixtures:sound`, deployment provenance text, documentation and CI route maps together. Do not automatically overwrite historical deploy records with a new source owner.

This is build/release work. It does not add a network call to a token render, purchase, sponsorship request or transaction hot path. Keep it that way: no remote version-discovery service, fresh per-request installed-class check, new keeper or onchain authorization restriction is needed for repository consolidation.

## Historical music and manager state

Shared tracks are append-only recipes with stable IDs, publication births and stored input-format versions. Paid tracks bind to a stored generator class/version, edition/clock/config and exact generation base; actual purchase hash and manager/token/append identity determine the variation. The composer target is manager configuration, so a new composer can affect existing stored recipes even when the generator binding remains historical. Moving source files must not rewrite these recipes, IDs, bases, names, hash contexts or mode preferences. [V2, V7]

Keep the current generator's old class artifact and decoding behavior available. Replacing a generator for new purchases does not authorize reinterpreting old purchases through the new generator. Keep the manager's compatibility checks instead of deleting them because both packages now share a repository.

The manager compiles its own drift helpers through inputs; the composer has a separate drift implementation. Equal constants do not make the modules interchangeable: they own different responsibilities, and source uses different day/epoch conventions. Do not deduplicate them during the import. A changed manager drift epoch requires a manager implementation change when upgrade authority still permits it; changing the composer target alone cannot change which hashes the manager reads. [V1, V2]

The legacy `BeastMidiProvider` still decodes an older 116-bit token shape, while V3's canonical codec has moved on. Import it as an explicitly legacy compatibility class; do not install it as the current V3 sound route or silently replace its decoder. The current manager consumes explicit musical identity/inputs at the class boundary. A new token bridge is separate functionality. [M4, V3]

If upgraded deployment behavior is requested later, first establish actual chain, installed manager/classes, relevant owner/lock state and historical data to preserve. This plan requires no such operation; the code move itself can complete without changing a deployed address or class.

## Duplicates versus necessary parallel representations

| Apparent duplicate | Treatment |
|---|---|
| Cairo and JS music generation/codec logic | Keep both: JS is the reference/client engine and independent wire/parity checks make differences observable |
| V3 catalogue/naming tables and JS engine tables | Treat `packages/originals` and `packages/core` as V3 identity vocabulary; add/retain cross-checks for the imported tables. Do not make a live metadata/RPC lookup a composition prerequisite |
| JS authored editions data and Cairo `editions_data.cairo` | JS source + deterministic generator are canonical; Cairo is generated output. Move generator and output together |
| JS TinyChip settings/banks and Cairo synth settings | Source + generated output; preserve generator, output and settings-hash parity |
| Typed class interfaces in manager and engine | Small declarations define a deliberate dependency boundary; existing compiled-ABI checks catch divergence. Shared-interface refactoring is optional after import |
| Inputs drift context helpers and composer drift transformation | Keep separate until semantics are explicitly reconciled; shared constants alone do not justify merging |
| MIDI generic page generation and V3 player fragments | Different page pipelines and provenance, not interchangeable copies. Keep V3's existing renderer page authoritative |
| Historical/current Sierra classes and deployment records | Retain immutable historical evidence and reproduction paths |
| Musical authoring labs, V3 Beast Lab and external Sound Check | Different workflows; reuse the same imported engine/package where possible, without merging every UI or host |

`TESTING.md` lists three generated Cairo files, but current source also has `editions_data.cairo` generated by `onchain/editions_cairo.mjs`. Include that fourth output in the migration checklist; do not rely on the older summary alone. [M6]

The one unavoidable generic/Beast tooling seam is the legacy MIDI sound page: `onchain/build.mjs` and `golden.mjs` live inside beast-sound but write `core/midi_contracts/src/page/{page_data,tests}.cairo`. Separate output ownership with an explicit target path or thin MIDI-owned build wrapper. Keep generic page generation reproducible in MIDI; do not leave the moved V3 tool writing across arbitrary sibling checkouts. A wholesale player rewrite is unnecessary. [M6]

## Phases and completion gates

Deliver the migration in two reviewable implementation changes, followed by the consumer cutover. Use separate PRs when each can pass required checks; otherwise keep them as separate commits in one mergeable PR. Do not turn it into a package-renaming or general cleanup project.

| Change | Scope | Required exit gate |
|---|---|---|
| PR 1: source import and MIT coverage | Import/wire packages, move tools/tests, retain APIs/editions and generated data, update V3 root LICENSE/NOTICES; leave released engine fixtures in place | Coherent dependencies; affected package/generator tests pass; MIT coverage complete; baseline comparison recorded |
| PR 2: build/release qualification | Adapt existing manifest/fixture/deployment tooling for local source and historical upstream builds; update affected CI routes | Relevant parity/integration checks pass; MIDI/settings, ABI, class hashes and size compared; historical builds remain supported; no unresolved release-blocking difference |
| Consumer and authoring cutover | Update sampler adapters and source pointers; designate V3 canonical for new Beast music | Qualified package produces expected consumer output; no dual authoring or ordinary sibling-checkout dependency |

PR 1 can land independently only if existing required checks pass with released fixtures still authoritative. The current fixture checker requires the external Git pin, so local dependency wiring may require PR 2's tooling changes in the same mergeable PR. Never merge a knowingly broken intermediate pipeline. Landing the import is not completion of the migration; the cutover requires PR 2's evidence. If identical-source relocation changes a class hash, first investigate compiler/package/profile context; any necessary release identity change must be explicit and reviewed. Do not replace old fixtures merely to obtain green checks. Do not advance the music roadmap until the source migration is qualified.

### 1. Freeze the import baseline

Record exact source SHAs, file/path map, licenses, public package/CLI consumers and generated artifacts. Confirm with maintainers who owns future Beast music releases and whether `beast-sound` has published consumers. Preserve upstream release tags and reproducibility. The V3 baseline already matches current MIDI Cairo source, so no music upgrade is necessary in this phase.

### 2. Import source and wire local packages

Import three Beast Cairo packages and the complete JS authoring package; move Beast-specific scripts/docs. Add explicit editions/dependencies/workspace paths and pnpm entry. Keep all class/package names, codecs, manager logic, generated musical data and committed engine fixtures stable. Repair generator/fixture output roots, benchmark wrappers/symlinks and tool working-directory assumptions. Keep generic MIDI/player implementations external.

Gate: workspace resolution is coherent, no external duplicate inputs package remains, affected package tests/JS tests and generators run from the new paths, generic MIDI consumers still have a supported build path, and the root license/package notices explicitly preserve MIT coverage for every imported first-party music path.

### 3. Qualify release tooling and historical compatibility

Adapt fixture/deployment scripts and their fake-chain tests to V3 source provenance while preserving historical upstream builds. Run exact artifact and compiled ABI comparisons. Exercise old/current generator snapshots, stored purchase packing vectors, append-only track behavior, manager modes/hash contexts and the real NFT/registry/renderer/player capture with no RPC.

Gate: source-only migration has no intended audio/storage/ABI change. Any class-hash difference is explained and reviewed as a separate release concern. Do not repin fixtures or propose an onchain target update merely to make a test pass.

### 4. Switch authors and consumers

Publish the new source/release location through existing package/docs/release channels. Update Sound Check's source-root adapter and hashes, parity injection paths and provenance labels in its own change; rebuild its existing fixtures and show unchanged results. Keep older sampler/player/reference sections pinned when intended. Add upstream migration pointers and stop duplicate Beast edits there.

The external Sound Check currently documents `e9b0f66` / v1.0.0, whereas V3 pins v1.0.1. Do not turn that consumer migration into an implicit music upgrade; label and validate each source. The sampler's prior 1,611-case parity is evidence for its own pin, not proof for this new package layout. [C1]

Gate: one canonical Beast music source, one reviewed build/release process, supported old releases and no hidden sibling-path dependency for normal authoring.

### 5. Implement music roadmap separately

Only after import qualification, implement the species/track authoring and Sound Check redesign in PLAN.md. Preserve the accepted musical targets: Satori 44 Species Song uses the original sampler 411 authored 72-second arrangement, Agony Bane is the named base, and Cyclops 64 Sound Check retains original 504's complete eight-sound client-bank sequence 34–41 at 175 BPM. These are future musical requirements, not migration-equivalence fixtures. Existing shared recipes are append-only; publication/replacement policy needs its own explicit plan.

## Validation proportional to the move

For implementation, use the suites already present and moved with their source. Add only path/release cases needed to verify the changed boundaries.

- Resolve/build all imported Cairo packages and manager with pinned tools; check formatting in affected packages and unchanged lock after test/build. Compare old/new class hashes, ABI and CASM sizes against the baseline manifest. Do not reuse the provider's older documented size as the pure composer's current bound.
- Run canonical inputs rejection/boundary/Store tests and independent JS wire vectors. Run manager real-integration, provenance, storage packing and fake-deployment suites; preserve historical class fixtures.
- Run JS package tests and the established Cairo↔JS parity families: legacy/v11, full MIDI, Genesis, name/seed, low tonic, Yeti, Sound Check, editions/drift, echo and settings hashes. Use the existing matrix/coverage rather than infer parity from a few listening samples. Batch expensive cases under documented memory limits. The existing Cairo parity shell wrappers can kill other snforge processes on memory-limit violation, so run them in an isolated job without unrelated snforge runs.
- Regenerate synth settings and editions data from unchanged sources and require unchanged semantic output. Check generic page/golden generation through its explicit MIDI-owned output target. Preserve independent expected outputs.
- Run `fixtures:engine:check`, compiled consumer ABI checks, `fixtures:sound:check`, `player-page:check` and the actual local renderer/player capture. Keep existing fragment and sound payload hashes stable unless a separate reviewed change is intended.
- Move Beast benchmark evidence with the code. Keep the benchmark wrapper's guarantee that measured classes equal production-built classes; its dependency shims use source symlinks and hardcoded paths that require adjustment. Measure normal and heavy cases once; broader performance work follows only if the move changes output/cost or exposes a failure.
- Extend existing V3 CI dependency/path routing for the new Cairo packages, JS subtree, parity/generator inputs, fixtures and benchmark harness. Music-only changes must trigger music checks; input changes must reach manager/integration checks. Do not run unrelated heavy visual suites solely because a lab JS file moved.

### Checks performed for this assessment

Read-only inspection covered the workspace manifests/locks, source imports, composer/generator contracts, manager storage/provenance, fixture/deploy scripts, CI router, JS exports/generators/labs, notices and known Sound Check paths. Fresh MIDI main's Cairo/Scarb source matches the V3 pinned engine as stated above.

The two committed engine Sierra artifacts' byte lengths and SHA-256 values match their manifest, and their ABI lists the expected pure methods. `node scripts/gen-player-page.mjs --check` passed. A packing-vector check could not run in the clean worktree because its SDK `starknet` dependency was not installed; no install/build was necessary to resolve this planning question. No full test/build, class-hash recomputation, RPC, account access or secret read was performed. Implementation acceptance remains the gates above, not a claim that the proposed move already passes them.

## Risks, cost and fallback

| Decision/risk | Likely impact and maintenance cost | Recommendation/fallback |
|---|---|---|
| Workspace/edition/package identity changes | Plausible compile/artifact drift even with identical source; low ongoing cost once pinned | Preserve names/editions, compare artifacts; keep existing fixture pin until qualified |
| Fixture/deploy assumptions about external inputs Git pin | Certain tooling break if changed naively; moderate one-time script/test work | Adapt existing manifest and historical archive workflow; revert local dependency wiring if qualification fails |
| Near-limit composer size | Any later code expansion can exceed deployability; source move alone has no intended expansion | Keep separate classes, measure actual build, defer architectural merger |
| Dual authoring after import | Likely source drift and release confusion; recurring coordination cost | Designate V3 canonical, leave migration pointers and immutable old releases upstream |
| Remaining generic MIDI/player dependency | Build-time Git availability/pin maintenance; no new hot-path latency | Keep exact pins and existing caches/archive reproduction; fork only for demonstrated maintenance need |
| Breaking direct JS/path consumers | Known Sound Check tooling assumes old paths; moderate bounded adapter work | Keep JS exports stable, migrate explicit consumers, retain old upstream releases |
| Source relocation mistaken for onchain migration | Could cause unnecessary deployment or provenance loss | Complete code consolidation first; chain changes require a separate request and verified state |
| Moving all player/generic code too | More source/license/build ownership and ongoing upstream merges | Leave generic core separate; all Beast-specific code can still live in V3 |

Before an onchain change, rollback is an ordinary revert of the import/wiring/tooling commits, with original external dependency and fixtures intact. Preserve old artifact manifests and exact source archives throughout. After any later onchain change, rollback is **not** guaranteed: manager ownership, target revocation and route/renderer locks can prevent it, and new-format stored purchases may require historical readers. That separate deployment plan must establish authority and compatibility before acting.

Required work is source ownership, package wiring, generator paths, release provenance, consumer adaptation and proportionate validation. Optional cleanup includes renaming packages/exports, merging typed interface declarations, generating all vocabulary from one source, combining labs, changing music, modernizing the legacy provider and rewriting generic page tooling. Do not make those prerequisites for a maintainable consolidation.

## Source references

All references below identify the inspected source, not a floating branch.

- **M1:** [MIDI layout and move guide](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/README.md), [root layout](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/README.md).
- **M2:** [MIDI workspace](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/Scarb.toml), [core library](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/core/midi/src/lib.cairo).
- **M3:** [Inputs manifest](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/beast_composer/inputs/Scarb.toml), [current codecs](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/beast_composer/inputs/src/lib.cairo), [manager-context drift helpers](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/beast_composer/inputs/src/drift.cairo).
- **M4:** [Pure generator](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/beast_contracts/src/pure_generator.cairo), [pure composer](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/beast_contracts/src/pure_composer.cairo), [legacy provider](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/beasts/beast_contracts/src/provider.cairo).
- **M5:** [JS package and exports](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/offchain/beast-sound/package.json), [JS reference entrypoint](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/offchain/beast-sound/src/index.js).
- **M6:** [Generation/testing guide](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/TESTING.md), [legacy generic page generator](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/offchain/beast-sound/onchain/build.mjs), [editions generator](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/offchain/beast-sound/onchain/editions_cairo.mjs), [lab player pin](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/offchain/beast-sound/onchain/lab-build-inputs.mjs).
- **M7:** [Benchmark package/shim design](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/bench/Scarb.toml), [current package CI](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/.github/workflows/test.yaml).
- **M8:** [Upstream MIT license](https://github.com/caseywescott/midi_fun_contract/blob/cdcad0a4b5d6ef4f3ddb6555f3448cbb017766e1/LICENSE).
- **V1:** [V3 input dependency](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/sound_manager/Scarb.toml), [lock](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/Scarb.lock), [fixture manifest](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/fixtures/sound-manager/manifest.json).
- **V2:** [Manager behavior and permanence](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/docs/originals-sound-manager.md), [implementation](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/sound_manager/src/originals.cairo).
- **V3:** [NFT/renderer/player boundary](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/docs/sound-storage.md), [canonical token codec](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/core/src/pack.cairo).
- **V4:** [Engine fixture pipeline](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/scripts/sound-manager-fixtures.mjs), [sound deployment pipeline](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/scripts/deploy-sound.mjs), [CI router](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/scripts/ci/route.py).
- **V5:** [V3 workspace scripts](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/package.json), [SDK exports](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/sdk/src/index.ts).
- **V6:** [V3 license boundaries](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/LICENSE), [sound-manager NOTICE](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/sound_manager/NOTICE), [player-fragment NOTICE](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/assets/player-page/NOTICE).
- **V7:** [Typed provenance records](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/sound_manager/src/records.cairo), [purchase/epoch storage packing](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/sound_manager/src/stored_purchase.cairo), [typed engine boundary](https://github.com/Provable-Games/beasts-v3/blob/7e9f19df93dccbe06eb8685e0a96fd89d594ce08/packages/sound_manager/src/engine.cairo).
- **C1:** The authorized existing Sound Check checkout's [README](https://github.com/Provable-Games/beast-sound-check/blob/eb0cfef/README.md) and `tools/production-source.mjs`, `tools/gen_tracks.mjs`, `tools/species_songs_check.mjs` were inspected read-only for known consumer path assumptions. This is a consumer inventory, not a fresh audit of that repository or its published site.
