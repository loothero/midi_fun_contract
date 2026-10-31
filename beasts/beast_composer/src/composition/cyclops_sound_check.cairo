//! The authored Cyclops Sound Check: the entire original lab track 504.
//! Eight Arp/FX timbres, 175 BPM, ten beats each. Names, effects and drift deliberately do not
//! retune, shorten or replace this score. One fixed nine-note phrase is reused for all eight
//! programs; storing its delta-encoded bytes avoids adding another general MIDI writer to the
//! near-limit composer. The independent original-file fixture checks every byte.
use midi::smf::smf_bytes;

pub const CYCLOPS_SPECIES: u8 = 64;
pub const CYCLOPS_CHECK_TEMPO_US: u32 = 342857;
pub const CYCLOPS_CHECK_LENGTH: u32 = 38400;
// Four quarters C4/E4/G4/C5 (440-tick gates), held G4 (1100), then four 58-tick blips.
// Note-off velocity64. Deltas include the spaces between notes, starting at tick0.
#[cairofmt::skip]
const PHRASE: [u8; 81] = [0, 144, 60, 100, 131, 56, 128, 60, 64, 40, 144, 64, 100, 131, 56, 128, 64, 64, 40, 144, 67, 100, 131, 56, 128, 67, 64, 40, 144, 72, 100, 131, 56, 128, 72, 64, 40, 144, 67, 100, 136, 76, 128, 67, 64, 130, 84, 144, 60, 100, 58, 128, 60, 64, 129, 54, 144, 64, 100, 58, 128, 64, 64, 129, 54, 144, 67, 100, 58, 128, 67, 64, 129, 54, 144, 72, 100, 58, 128, 72, 64];

pub fn cyclops_sound_check_smf_bytes() -> Array<u8> {
    // Program34, volume100, centeredpan64. Later blocks change only the program.
    let mut lead: Array<u8> = array![0, 192, 34, 0, 176, 7, 100, 0, 176, 10, 64];
    for i in 0_u32..8 {
        if i != 0 {
            // 662 ticks from the previous block's final note-off to the next program.
            lead.append_span(array![133, 22, 192, (34 + i).try_into().unwrap()].span());
        }
        lead.append_span(PHRASE.span());
    }
    // End after the final ten-beat block, with the same662-tick closing rest.
    lead.append_span(array![133, 22, 255, 47, 0].span());
    // Tempo342857us and End-of-Track at38400ticks (VLQ82ac00).
    let tempo: Array<u8> = array![0, 255, 81, 3, 5, 59, 73, 130, 172, 0, 255, 47, 0];
    smf_bytes(1, 480, array![tempo, lead].span())
}
