//! The authored Cyclops Sound Check: the entire original lab track 504.
//! Eight Arp/FX timbres, 175 BPM as written, ten beats each. Names and drift do not retune
//! the score. Token effects use the standard Check tempo, articulation and velocity rules;
//! Mega retains the eight Arp/FX programs rather than replacing their identity. One fixed nine-note
//! phrase is reused for all eight programs; storing its delta-encoded bytes avoids adding another
//! general MIDI writer to the near-limit composer. The independent original-file fixture checks
//! every byte.
use midi::smf::smf_bytes;
use crate::inputs::SoundCheckInputs;

pub const CYCLOPS_SPECIES: u8 = 64;
pub const CYCLOPS_CHECK_TEMPO_US: u32 = 342857;
pub const CYCLOPS_CHECK_LENGTH: u32 = 38400;
// Four quarters C4/E4/G4/C5 (440-tick gates), held G4 (1100), then four 58-tick blips.
// Note-off velocity64. Deltas include the spaces between notes, starting at tick0.
#[cairofmt::skip]
const PHRASE: [u8; 81] = [0, 144, 60, 100, 131, 56, 128, 60, 64, 40, 144, 64, 100, 131, 56, 128, 64, 64, 40, 144, 67, 100, 131, 56, 128, 67, 64, 40, 144, 72, 100, 131, 56, 128, 72, 64, 40, 144, 67, 100, 136, 76, 128, 67, 64, 130, 84, 144, 60, 100, 58, 128, 60, 64, 129, 54, 144, 64, 100, 58, 128, 64, 64, 129, 54, 144, 67, 100, 58, 128, 67, 64, 129, 54, 144, 72, 100, 58, 128, 72, 64];
// Gate variants use the same min(original, max(60, shortened)) rule as other Checks.
#[cairofmt::skip]
const PORTATO: [u8; 85] = [0, 144, 60, 100, 130, 74, 128, 60, 64, 129, 22, 144, 64, 100, 130, 74, 128, 64, 64, 129, 22, 144, 67, 100, 130, 74, 128, 67, 64, 129, 22, 144, 72, 100, 130, 74, 128, 72, 64, 129, 22, 144, 67, 100, 134, 57, 128, 67, 64, 132, 103, 144, 60, 100, 58, 128, 60, 64, 129, 54, 144, 64, 100, 58, 128, 64, 64, 129, 54, 144, 67, 100, 58, 128, 67, 64, 129, 54, 144, 72, 100, 58, 128, 72, 64];
#[cairofmt::skip]
const STACCATO: [u8; 85] = [0, 144, 60, 100, 129, 92, 128, 60, 64, 130, 4, 144, 64, 100, 129, 92, 128, 64, 64, 130, 4, 144, 67, 100, 129, 92, 128, 67, 64, 130, 4, 144, 72, 100, 129, 92, 128, 72, 64, 130, 4, 144, 67, 100, 132, 38, 128, 67, 64, 134, 122, 144, 60, 100, 58, 128, 60, 64, 129, 54, 144, 64, 100, 58, 128, 64, 64, 129, 54, 144, 67, 100, 58, 128, 67, 64, 129, 54, 144, 72, 100, 58, 128, 72, 64];

pub fn cyclops_sound_check_smf_bytes() -> Array<u8> {
    let x = crate::composition::sound_check::sound_check_inputs(
        crate::composition::beast_v3_sound::PackableBeastV3 {
            id: 64,
            prefix: 0,
            suffix: 0,
            level: 1,
            health: 100,
            shiny: 0,
            animated: 0,
            tier: 3,
            beast_type: 2,
        },
    );
    smf_bytes(1, 480, cyclops_sound_check_tracks(x).span())
}

/// The same authored score as track bodies for the shared packed-SMF composition path.
pub fn cyclops_sound_check_tracks(x: SoundCheckInputs) -> Array<Array<u8>> {
    // Program34, volume100, centeredpan64. Later blocks change only the program.
    let mut lead: Array<u8> = array![0, 192, 34, 0, 176, 7, 100, 0, 176, 10, 64];
    for i in 0_u32..8 {
        if i != 0 {
            // 662 ticks from the previous block's final note-off to the next program.
            lead.append_span(array![133, 22, 192, (34 + i).try_into().unwrap()].span());
        }
        let phrase = if x.articulation_profile == 5 {
            PORTATO.span()
        } else if x.articulation_profile == 1 {
            STACCATO.span()
        } else {
            PHRASE.span()
        };
        let mut k: u32 = 0;
        for original in phrase {
            let mut value = *original;
            if value == 100 {
                let accented = x.articulation_profile == 3
                    && if i % 2 == 0 {
                        k == 3 || k == 39 || k == 67
                    } else {
                        k == 21
                    };
                value = if accented {
                    108
                } else {
                    100
                };
                if value > x.velocity_ceiling {
                    value = x.velocity_ceiling;
                }
            }
            lead.append(value);
            k += 1;
        }
    }
    // End after the final ten-beat block, with the same662-tick closing rest.
    lead.append_span(array![133, 22, 255, 47, 0].span());
    // Tempo342857us and End-of-Track at38400ticks (VLQ82ac00).
    let tempo: Array<u8> = array![
        0, 255, 81, 3, (x.tempo_us / 0x10000).try_into().unwrap(),
        ((x.tempo_us / 0x100) % 0x100).try_into().unwrap(),
        (x.tempo_us % 0x100).try_into().unwrap(), 130, 172, 0, 255, 47, 0,
    ];
    array![tempo, lead]
}
