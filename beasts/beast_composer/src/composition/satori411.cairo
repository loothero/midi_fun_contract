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
    x.arrangement.identity.source_species_id == 44
        && x.theme.motif_seed == THEME_MARKER
        && x.treatment.rhythm_seed == RHYTHM_MARKER
}

/// Explicitly select the authored score. Existing recipes without both markers keep their music.
pub fn from_base(_base: SongInputs, name: u16) -> SongInputs {
    SongInputs {
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
    }
}

/// Future edition-zero purchases retain the authored form, varied in key and tempo by their seed.
/// Historical purchases retain their snapshotted unmarked base.
pub fn purchased(mut x: SongInputs, seed: felt252) -> SongInputs {
    let n: u256 = seed.into();
    x.score.tonic_keynum = (55 + n % 5).try_into().unwrap();
    x.score.tempo_us = (480000 + (n / 5 % 5) * 10000).try_into().unwrap();
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
    let key: i32 = key.into() + tonic.into() - 57;
    let duration = match profile {
        1 => duration / 2,
        3 | 5 => duration * 3 / 4,
        _ => duration,
    };
    let velocity = if velocity > ceiling {
        ceiling
    } else {
        velocity
    };
    t.note_on(time, channel, key.try_into().unwrap(), velocity);
    t.note_off(time + duration, channel, key.try_into().unwrap(), 64);
}

/// Exact original arrangement at the written controls; effects alter tempo/gates/velocity only.
/// Its defining triangle/pluck/harp palette is retained instead of mega/echo substitution.
#[inline(never)]
pub fn tracks(x: SongInputs) -> Array<Array<u8>> {
    let expression = (x.score.tonic_keynum, x.score.articulation_profile, x.score.velocity_ceiling);
    let mut tempo = TrackWriterTrait::new();
    tempo.tempo(0, x.score.tempo_us);
    let (
        mut bar, mut lead, mut bass, mut harp, mut drums,
    ): (u32, TrackWriter, TrackWriter, TrackWriter, TrackWriter) =
        opaque(
        (0, setup(0, 0, 50), setup(1, 15, 40), setup(2, 17, 80), setup(9, 0, 64)),
    );
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
        let mut i: u32 = opaque(0);
        while i < 8 {
            note(
                ref bass,
                1,
                at + i * 240,
                root + if i % 4 == 2 {
                    7
                } else {
                    0
                },
                200,
                100,
                expression,
            );
            i += 1;
        }
        if bar >= 1 {
            let mut i: u32 = opaque(0);
            while i < 16 {
                let key = *chord.at(i % 3) + if i % 6 > 2 {
                    24
                } else {
                    12
                };
                note(ref harp, 2, at + i * 120, key, 100, 70, expression);
                i += 1;
            }
        }
        if bar >= 4 && !rest {
            note(ref lead, 0, at, b + 24, 920, 100, expression);
            note(ref lead, 0, at + 960, c + 24, 440, 100, expression);
            note(ref lead, 0, at + 1440, b + 24, 220, 100, expression);
            note(ref lead, 0, at + 1680, a + 24, 220, 100, expression);
        }
        if bar >= 8 {
            let mut i: u32 = opaque(0);
            while i < 8 {
                drums.note_on(at + i * 240, 9, 42, if i % 2 == 1 {
                    50
                } else {
                    76
                });
                if !rest {
                    if i == 0 || i == 4 {
                        drums
                            .note_on(
                                at + i * 240,
                                9,
                                36,
                                if x.score.velocity_ceiling < 110 {
                                    x.score.velocity_ceiling
                                } else {
                                    110
                                },
                            );
                    }
                    if i == 2 || i == 6 {
                        drums
                            .note_on(
                                at + i * 240,
                                9,
                                38,
                                if x.score.velocity_ceiling < 100 {
                                    x.score.velocity_ceiling
                                } else {
                                    100
                                },
                            );
                    }
                }
                if bar == 16 && i == 0 {
                    drums.note_on(at, 9, 49, capped(100, x.score.velocity_ceiling));
                }
                i += 1;
            }
        }
        // Crash at bar16 must precede later hits, but follows hat/kick at the same tick in source.
        // It is the final event at that tick; writing it after the entire bar would go backwards.
        if bar == 0 {
            drums.note_on(0, 9, 49, capped(100, x.score.velocity_ceiling));
        }
        bar += 1;
    }
    array![
        tempo.finish_at(END), lead.finish_at(END), bass.finish_at(END), harp.finish_at(END),
        drums.finish_at(END)
    ]
}

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
    use midi::smf::smf_bytes;
    use crate::composition::beast_v3_sound::PackableBeastV3;
    use crate::composition::genesis::{beast_song_inputs, purchase_song_inputs};
    use crate::inputs::{ComposerInputs, decode_inputs, encode_inputs};
    use super::{RHYTHM_MARKER, THEME_MARKER, is_satori411, tracks};

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
    fn test_satori411_agony_bane_and_reserved_marker_roundtrip() {
        let x = beast_song_inputs(beast(), 1, 1);
        assert(is_satori411(x), 'name base');
        assert(x.arrangement.identity.name_variant_id == 1, 'Agony Bane');
        let wire = encode_inputs(ComposerInputs::Song(x));
        assert(decode_inputs(wire.span()) == ComposerInputs::Song(x), 'canonical roundtrip');
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
        assert(a.score.tonic_keynum != b.score.tonic_keynum, 'purchase key variation');
    }
}
