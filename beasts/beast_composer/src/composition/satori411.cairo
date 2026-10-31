//! Explicit authored Satori recipe from the original Sound Check lab's track 411.
//! Reserved dual felt markers opt in without reinterpreting ordinary stored Satori inputs.
use midi::smf::{TrackWriter, TrackWriterTrait};
use crate::inputs::{
    ArrangementInputs, ChannelPolicy, MusicIdentity, ScoreInputs, SongInputs, SpecialArrangement,
    ThemeInputs, TreatmentInputs,
};
use crate::opaque::opaque;

pub const THEME_MARKER: felt252 = 'SATORI_LAB_411_V1';
pub const RHYTHM_MARKER: felt252 = 'SATORI_FORM_36_V1';
const END: u32 = 69120;

pub fn is_satori411(x: SongInputs) -> bool {
    marked(x.arrangement.identity.source_species_id, x.theme.motif_seed, x.treatment.rhythm_seed)
}

#[inline(never)]
fn marked(species: u32, theme: felt252, rhythm: felt252) -> bool {
    species == 44 && theme == THEME_MARKER && rhythm == RHYTHM_MARKER
}

/// Explicitly select the authored score. Existing recipes without both markers keep their music.
pub fn from_base(base: SongInputs, name: u16) -> SongInputs {
    let mut x = SongInputs {
        theme: ThemeInputs { motif_seed: THEME_MARKER, tier: 4, register_band: 2 },
        score: ScoreInputs {
            mode_id: 7,
            tonic_keynum: 57,
            tier: 4,
            weakness: 1,
            voice_count: 3,
            section_count: 1,
            stretto_lag: 1,
            use_inversion: false,
            use_countersubject: false,
            ornament_density: 0,
            articulation_profile: 0,
            velocity_ceiling: 127,
            tempo_us: 500000,
        },
        treatment: TreatmentInputs {
            rhythm_seed: RHYTHM_MARKER,
            flip_side: false,
            development: 0,
            direction: 0,
            spacing: 1,
            trill: false,
            prominence: 0,
            section_rhythm: false,
        },
        arrangement: ArrangementInputs {
            family: 1,
            identity: MusicIdentity { source_species_id: 44, name_variant_id: name },
            channel_count: 4,
            channel_policy: ChannelPolicy::Genesis,
            special: SpecialArrangement::None,
            top_lead: true,
            balanced: false,
            weak_ties: true,
        },
    };
    if name == 1 {
        // Casey's named controls on the same species motif, not a new theme seed.
        // The procedural theme keeps its species register; the named register is encoded
        // by Casey's mapped tonic48/60/72 plus pitch class. Select that authored treatment.
        x
            .theme
            .register_band =
                if base.score.tonic_keynum < 60 {
                    0
                } else if base.score.tonic_keynum < 72 {
                    1
                } else {
                    2
                };
        x.score.mode_id = base.score.mode_id;
        x.score.tonic_keynum = base.score.tonic_keynum;
        x.score.ornament_density = base.score.ornament_density;
        x.treatment.trill = base.treatment.trill;
    }
    x
}

/// Future edition-zero purchases retain the authored form, varied in key and tempo by their seed.
/// Historical purchases retain their snapshotted unmarked base.
pub fn purchased(mut x: SongInputs, seed: felt252) -> SongInputs {
    let n: u256 = seed.into();
    let named = x.theme.register_band == 0;
    if !named {
        x.score.tonic_keynum = (55 + n % 5).try_into().unwrap();
    }
    let rate = if named {
        n % 5
    } else {
        n / 5 % 5
    };
    x.score.tempo_us = (480000 + rate * 10000).try_into().unwrap();
    x.arrangement.channel_policy = ChannelPolicy::Seeded(seed);
    x
}

fn setup(channel: u8, program: u8, pan: u8) -> TrackWriter {
    let mut t = TrackWriterTrait::new();
    if channel != 9 {
        t.program(0, channel, program);
    }
    t.control(0, channel, 7, 100);
    t.control(0, channel, 10, pan);
    t
}

#[inline(never)]
fn note(
    ref t: TrackWriter,
    channel: u8,
    time: u32,
    key: u8,
    duration: u32,
    velocity: u8,
    expression: (u8, u8, u8),
) {
    let (tonic, profile, ceiling) = expression;
    // Validated tonic24..96 and authored pitches36..88 keep this in MIDI3..127.
    let key = key + tonic - 57;
    // All authored gates are100..920 ticks, so only the100-tick harp gate hits the60 floor.
    let duration = match profile {
        1 => if duration < 120 {
            60
        } else {
            duration / 2
        },
        5 => duration * 3 / 4,
        _ => duration,
    };
    let velocity = if velocity > ceiling {
        ceiling
    } else {
        velocity
    };
    // This private helper is called only for authored channels0..2.
    t.message(time, 0x90 + channel, key, velocity);
    t.message(time + duration, 0x80 + channel, key, 64);
}

/// Exact original arrangement at the written controls; effects alter tempo/gates/velocity only.
/// Its defining triangle/pluck/harp palette is retained instead of mega/echo substitution.
#[inline(never)]
pub fn tracks(x: SongInputs) -> Array<Array<u8>> {
    let expression = (x.score.tonic_keynum, x.score.articulation_profile, x.score.velocity_ceiling);
    // Casey's low named register selects an earlier answering tone on the same motif.
    let named = x.theme.register_band == 0;
    let mut tempo = TrackWriterTrait::new();
    tempo.tempo(0, x.score.tempo_us);
    let (mut role, mut out): (u8, Array<Array<u8>>) = opaque((0, array![tempo.finish_at(END)]));
    while role < 4 {
        let (channel, program, pan): (u8, u8, u8) = match role {
            0 => (0, 0, 50),
            1 => (1, 15, 40),
            2 => (2, 17, 80),
            _ => (9, 0, 64),
        };
        let (mut bar, mut writer): (u32, TrackWriter) = opaque((0, setup(channel, program, pan)));
        while bar < 36 {
            let at = bar * 1920;
            let (root, a, b, c): (u8, u8, u8, u8) = match bar % 4 {
                0 => (45, 57, 60, 64),
                1 => (41, 53, 57, 60),
                2 => (36, 48, 52, 55),
                _ => (43, 55, 59, 62),
            };
            let chord = array![a, b, c];
            let rest = bar >= 24 && bar < 28;
            if role == 3 {
                if bar >= 8 {
                    let mut i: u32 = opaque(0);
                    while i < 8 {
                        writer
                            .note_on(
                                at + i * 240,
                                9,
                                42,
                                capped(if i % 2 == 1 {
                                    50
                                } else {
                                    76
                                }, x.score.velocity_ceiling),
                            );
                        if !rest {
                            if i == 0 || i == 4 {
                                writer
                                    .note_on(
                                        at + i * 240, 9, 36, capped(110, x.score.velocity_ceiling),
                                    );
                            }
                            if i == 2 || i == 6 {
                                writer
                                    .note_on(
                                        at + i * 240, 9, 38, capped(100, x.score.velocity_ceiling),
                                    );
                            }
                        }
                        if bar == 16 && i == 0 {
                            writer.note_on(at, 9, 49, capped(100, x.score.velocity_ceiling));
                        }
                        i += 1;
                    }
                }
                if bar == 0 {
                    writer.note_on(0, 9, 49, capped(100, x.score.velocity_ceiling));
                }
            } else {
                let count: u32 = if role == 1 {
                    8
                } else if role == 2 && bar >= 1 {
                    16
                } else if role == 0 && bar >= 4 && !rest {
                    4
                } else {
                    0
                };
                let mut i: u32 = opaque(0);
                while i < count {
                    let (offset, key, duration, velocity): (u32, u8, u32, u8) = if role == 1 {
                        (i * 240, root + if i % 4 == 2 {
                            7
                        } else {
                            0
                        }, 200, 100)
                    } else if role == 2 {
                        (i * 120, *chord.at(i % 3) + if i % 6 > 2 {
                            24
                        } else {
                            12
                        }, 100, 70)
                    } else {
                        match i {
                            0 => (0, b + 24, if named {
                                680
                            } else {
                                920
                            }, 100),
                            1 => (
                                if named {
                                    720
                                } else {
                                    960
                                },
                                c + 24,
                                if named {
                                    680
                                } else {
                                    440
                                },
                                100,
                            ),
                            2 => (1440, b + 24, 220, 100),
                            _ => (1680, a + 24, 220, 100),
                        }
                    };
                    note(ref writer, channel, at + offset, key, duration, velocity, expression);
                    i += 1;
                }
            }
            bar += 1;
        }
        out.append(writer.finish_at(END));
        role += 1;
    }
    out
}

#[inline(never)]
fn capped(velocity: u8, ceiling: u8) -> u8 {
    if velocity > ceiling {
        ceiling
    } else {
        velocity
    }
}

#[cfg(test)]
mod tests {
    use core::poseidon::poseidon_hash_span;
    use midi::smf::{TrackWriterTrait, smf_bytes};
    use crate::composition::beast_v3_sound::PackableBeastV3;
    use crate::composition::drift::Drift;
    use crate::composition::genesis::{beast_song_inputs, drifted_song_inputs, purchase_song_inputs};
    use crate::inputs::{ComposerInputs, decode_inputs, encode_inputs};
    use super::{RHYTHM_MARKER, THEME_MARKER, is_satori411, note, tracks};

    fn beast() -> PackableBeastV3 {
        PackableBeastV3 {
            id: 44,
            prefix: 0,
            suffix: 0,
            level: 50,
            health: 200,
            shiny: 0,
            animated: 0,
            tier: 4,
            beast_type: 1,
        }
    }

    #[test]
    fn test_satori411_staccato_floor_matches_casey_song_performance() {
        let mut writer = TrackWriterTrait::new();
        note(ref writer, 0, 0, 60, 100, 100, (57, 1, 127));
        assert(
            writer.finish() == array![0, 144, 60, 100, 60, 128, 60, 64, 0, 255, 47, 0],
            '60tick minimum gate',
        );
    }

    #[test]
    fn test_satori411_exact_reference_midi() {
        let x = beast_song_inputs(beast(), 0, 0);
        assert(is_satori411(x), 'authored base');
        let midi = smf_bytes(1, 480, tracks(x).span());
        assert(midi.len() == 9720, 'reference length');
        let mut values = array![];
        for b in midi.span() {
            values.append((*b).into());
        }
        assert(
            poseidon_hash_span(
                values.span(),
            ) == 0x39a228c2995119595b72ef561bf06664a107d5ff150025cddc14c896fc931d,
            'reference midi',
        );
    }

    #[test]
    fn test_satori411_effects_match_independent_js_reference() {
        let expected = array![
            0x3a4739617e5f179a399de21702ade6db98d14ef1fcd7be8dad21c843ec9fb34,
            0x6627a496c5ec579cbb850a1b987f2a54d091c163070d24e031b4331d37db968,
            0x4283cd922559a5c7ca930214722ff6b60b657ec914d63c63312e381189c3b6,
            0x2df10612091fe82a168300bf837d6e75c040d4932fac5bb4595f0ba5cef2751,
        ];
        let base = beast_song_inputs(beast(), 1, 1);
        let mut fx: u8 = 0;
        while fx < 4 {
            let performed = crate::composition::performance::apply_performance(
                ComposerInputs::Song(base), fx,
            );
            let x = match performed {
                ComposerInputs::Song(x) => x,
                _ => panic!("song expected"),
            };
            let midi = smf_bytes(1, 480, tracks(x).span());
            let mut values = array![];
            for b in midi.span() {
                values.append((*b).into());
            }
            assert(
                poseidon_hash_span(values.span()) == *expected.at(fx.into()), 'effects reference',
            );
            fx += 1;
        }
    }

    #[test]
    fn test_satori411_named_register_and_old_markers_survive_drift() {
        let shared = beast_song_inputs(beast(), 0, 0);
        let named = beast_song_inputs(beast(), 1, 1);
        let d = Drift {
            rhythm: Option::Some(123), rotate: Option::Some(0), day_knob: 0, delta_bpm: 0, day: 40,
        };
        let changed = drifted_song_inputs(named, d);
        assert(is_satori411(changed), 'drift preserves marker');
        assert(changed.theme.register_band == 0, 'named register retained');
        assert(changed.score.ornament_density == 0, 'existing weekly ornament rule');
        assert(changed.score.tonic_keynum == 55, 'existing monthly key rule');
        let shared_changed = drifted_song_inputs(shared, d);
        assert(shared_changed.theme.register_band == 2, 'shared written phrase retained');
        let mut legacy_marked = shared;
        legacy_marked.arrangement.identity.name_variant_id = 1;
        assert(
            smf_bytes(
                1, 480, tracks(legacy_marked).span(),
            ) == smf_bytes(1, 480, tracks(shared).span()),
            'old marked base unchanged',
        );
    }

    #[test]
    fn test_satori411_agony_bane_and_reserved_marker_roundtrip() {
        let x = beast_song_inputs(beast(), 1, 1);
        assert(is_satori411(x), 'name base');
        assert(x.arrangement.identity.name_variant_id == 1, 'Agony Bane');
        assert(x.score.mode_id == 7 && x.score.tonic_keynum == 48, 'Casey named C Aeolian');
        assert(x.theme.register_band == 0 && x.score.ornament_density == 1, 'Casey named profile');
        assert(!x.treatment.trill, 'Casey Bane no trill');
        let wire = encode_inputs(ComposerInputs::Song(x));
        assert(decode_inputs(wire.span()) == ComposerInputs::Song(x), 'canonical roundtrip');
        assert(
            poseidon_hash_span(
                wire.span(),
            ) == 0x22d0f7a38431fcf13f4760282e12a34717294a5e787315f5f10fbe6088f22c9,
            'JS named wire',
        );
        let mut other = x;
        other.treatment.rhythm_seed = 0;
        assert(!is_satori411(other), 'both markers needed');
        other.treatment.rhythm_seed = RHYTHM_MARKER;
        other.theme.motif_seed = 0;
        assert(!is_satori411(other), 'both markers needed');
        other.theme.motif_seed = THEME_MARKER;
        other.arrangement.identity.source_species_id = 43;
        assert(!is_satori411(other), 'species marker');
        assert(!is_satori411(beast_song_inputs(beast(), 1, 2)), 'other named base');
        let a = purchase_song_inputs(x, 0);
        let b = purchase_song_inputs(x, 1);
        assert(is_satori411(a) && is_satori411(b), 'purchase preserves markers');
        assert(
            a.score.tonic_keynum == x.score.tonic_keynum
                && b.score.tonic_keynum == x.score.tonic_keynum,
            'keep named base key',
        );
        assert(a.score.tempo_us != b.score.tempo_us, 'named purchase variation');
    }
}
