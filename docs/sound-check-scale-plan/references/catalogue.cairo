// Original 75-species catalogue for Loot Survivor.

use beasts_core::traits::{
    TIER_1, TIER_2, TIER_3, TIER_4, TIER_5, TYPE_CODE_BRUTE, TYPE_CODE_HUNTER, TYPE_CODE_MAGIC,
    type_name,
};

// Magical T1s (1-5)
pub const WARLOCK: u8 = 1;
pub const TYPHON: u8 = 2;
pub const JIANGSHI: u8 = 3;
pub const ANANSI: u8 = 4;
pub const BASILISK: u8 = 5;

// Magical T2s (6-10)
pub const GORGON: u8 = 6;
pub const KITSUNE: u8 = 7;
pub const LICH: u8 = 8;
pub const CHIMERA: u8 = 9;
pub const WENDIGO: u8 = 10;

// Magical T3s (11-15)
pub const RAKSHASA: u8 = 11;
pub const WEREWOLF: u8 = 12;
pub const BANSHEE: u8 = 13;
pub const DRAUGR: u8 = 14;
pub const VAMPIRE: u8 = 15;

// Magical T4s (16-20)
pub const GOBLIN: u8 = 16;
pub const GHOUL: u8 = 17;
pub const WRAITH: u8 = 18;
pub const SPRITE: u8 = 19;
pub const KAPPA: u8 = 20;

// Magical T5s (21-25)
pub const FAIRY: u8 = 21;
pub const LEPRECHAUN: u8 = 22;
pub const KELPIE: u8 = 23;
pub const PIXIE: u8 = 24;
pub const GNOME: u8 = 25;

// Hunter T1s (26-30)
pub const GRIFFIN: u8 = 26;
pub const MANTICORE: u8 = 27;
pub const PHOENIX: u8 = 28;
pub const DRAGON: u8 = 29;
pub const MINOTAUR: u8 = 30;

// Hunter T2s (31-35)
pub const QILIN: u8 = 31;
pub const AMMIT: u8 = 32;
pub const NUE: u8 = 33;
pub const SKINWALKER: u8 = 34;
pub const CHUPACABRA: u8 = 35;

// Hunter T3s (36-40)
pub const WERETIGER: u8 = 36;
pub const WYVERN: u8 = 37;
pub const ROC: u8 = 38;
pub const HARPY: u8 = 39;
pub const PEGASUS: u8 = 40;

// Hunter T4s (41-45)
pub const HIPPOGRIFF: u8 = 41;
pub const FENRIR: u8 = 42;
pub const JAGUAR: u8 = 43;
pub const SATORI: u8 = 44;
pub const DIREWOLF: u8 = 45;

// Hunter T5s (46-50)
pub const BEAR: u8 = 46;
pub const WOLF: u8 = 47;
pub const MANTIS: u8 = 48;
pub const SPIDER: u8 = 49;
pub const RAT: u8 = 50;

// Brute T1s (51-55)
pub const KRAKEN: u8 = 51;
pub const COLOSSUS: u8 = 52;
pub const ASAG: u8 = 53;
pub const LEVIATHAN: u8 = 54;
pub const TARRASQUE: u8 = 55;

// Brute T2s (56-60)
pub const TITAN: u8 = 56;
pub const NEPHILIM: u8 = 57;
pub const BEHEMOTH: u8 = 58;
pub const HYDRA: u8 = 59;
pub const JUGGERNAUT: u8 = 60;

// Brute T3s (61-65)
pub const ONI: u8 = 61;
pub const JOTUNN: u8 = 62;
pub const ETTIN: u8 = 63;
pub const CYCLOPS: u8 = 64;
pub const GIANT: u8 = 65;

// Brute T4s (66-70)
pub const NEMEANLION: u8 = 66;
pub const BERSERKER: u8 = 67;
pub const YETI: u8 = 68;
pub const GOLEM: u8 = 69;
pub const METSAVANA: u8 = 70;

// Brute T5s (71-75)
pub const TROLL: u8 = 71;
pub const BIGFOOT: u8 = 72;
pub const OGRE: u8 = 73;
pub const ORC: u8 = 74;
pub const SKELETON: u8 = 75;


pub fn get_beast_name(beast: u8) -> felt252 {
    if beast == WARLOCK {
        'Warlock'
    } else if beast == TYPHON {
        'Typhon'
    } else if beast == JIANGSHI {
        'Jiangshi'
    } else if beast == ANANSI {
        'Anansi'
    } else if beast == BASILISK {
        'Basilisk'
    } else if beast == GORGON {
        'Gorgon'
    } else if beast == KITSUNE {
        'Kitsune'
    } else if beast == LICH {
        'Lich'
    } else if beast == CHIMERA {
        'Chimera'
    } else if beast == WENDIGO {
        'Wendigo'
    } else if beast == RAKSHASA {
        'Rakshasa'
    } else if beast == WEREWOLF {
        'Werewolf'
    } else if beast == BANSHEE {
        'Banshee'
    } else if beast == DRAUGR {
        'Draugr'
    } else if beast == VAMPIRE {
        'Vampire'
    } else if beast == GOBLIN {
        'Goblin'
    } else if beast == GHOUL {
        'Ghoul'
    } else if beast == WRAITH {
        'Wraith'
    } else if beast == SPRITE {
        'Sprite'
    } else if beast == KAPPA {
        'Kappa'
    } else if beast == FAIRY {
        'Fairy'
    } else if beast == LEPRECHAUN {
        'Leprechaun'
    } else if beast == KELPIE {
        'Kelpie'
    } else if beast == PIXIE {
        'Pixie'
    } else if beast == GNOME {
        'Gnome'
    } else if beast == GRIFFIN {
        'Griffin'
    } else if beast == MANTICORE {
        'Manticore'
    } else if beast == PHOENIX {
        'Phoenix'
    } else if beast == DRAGON {
        'Dragon'
    } else if beast == MINOTAUR {
        'Minotaur'
    } else if beast == QILIN {
        'Qilin'
    } else if beast == AMMIT {
        'Ammit'
    } else if beast == NUE {
        'Nue'
    } else if beast == SKINWALKER {
        'Skinwalker'
    } else if beast == CHUPACABRA {
        'Chupacabra'
    } else if beast == WERETIGER {
        'Weretiger'
    } else if beast == WYVERN {
        'Wyvern'
    } else if beast == ROC {
        'Roc'
    } else if beast == HARPY {
        'Harpy'
    } else if beast == PEGASUS {
        'Pegasus'
    } else if beast == HIPPOGRIFF {
        'Hippogriff'
    } else if beast == FENRIR {
        'Fenrir'
    } else if beast == JAGUAR {
        'Jaguar'
    } else if beast == SATORI {
        'Satori'
    } else if beast == DIREWOLF {
        'Direwolf'
    } else if beast == BEAR {
        'Bear'
    } else if beast == WOLF {
        'Wolf'
    } else if beast == MANTIS {
        'Mantis'
    } else if beast == SPIDER {
        'Spider'
    } else if beast == RAT {
        'Rat'
    } else if beast == KRAKEN {
        'Kraken'
    } else if beast == COLOSSUS {
        'Colossus'
    } else if beast == ASAG {
        'Asag'
    } else if beast == LEVIATHAN {
        'Leviathan'
    } else if beast == TARRASQUE {
        'Tarrasque'
    } else if beast == TITAN {
        'Titan'
    } else if beast == NEPHILIM {
        'Nephilim'
    } else if beast == BEHEMOTH {
        'Behemoth'
    } else if beast == HYDRA {
        'Hydra'
    } else if beast == JUGGERNAUT {
        'Juggernaut'
    } else if beast == ONI {
        'Oni'
    } else if beast == JOTUNN {
        'Jotunn'
    } else if beast == ETTIN {
        'Ettin'
    } else if beast == CYCLOPS {
        'Cyclops'
    } else if beast == GIANT {
        'Giant'
    } else if beast == NEMEANLION {
        'Nemean Lion'
    } else if beast == BERSERKER {
        'Berserker'
    } else if beast == YETI {
        'Yeti'
    } else if beast == GOLEM {
        'Golem'
    } else if beast == METSAVANA {
        'Metsavana'
    } else if beast == TROLL {
        'Troll'
    } else if beast == BIGFOOT {
        'Bigfoot'
    } else if beast == OGRE {
        'Ogre'
    } else if beast == ORC {
        'Orc'
    } else if beast == SKELETON {
        'Skeleton'
    } else {
        'Unknown'
    }
}

pub fn get_tier(beast: u8) -> u8 {
    if ((beast != 0 && beast <= 5)
        || (beast >= 26 && beast <= 30)
        || (beast >= 51 && beast <= 55)) {
        TIER_1
    } else if ((beast >= 6 && beast <= 10)
        || (beast >= 31 && beast <= 35)
        || (beast >= 56 && beast <= 60)) {
        TIER_2
    } else if ((beast >= 11 && beast <= 15)
        || (beast >= 36 && beast <= 40)
        || (beast >= 61 && beast <= 65)) {
        TIER_3
    } else if ((beast >= 16 && beast <= 20)
        || (beast >= 41 && beast <= 45)
        || (beast >= 66 && beast <= 70)) {
        TIER_4
    } else if ((beast >= 21 && beast <= 25)
        || (beast >= 46 && beast <= 50)
        || (beast >= 71 && beast <= 75)) {
        TIER_5
    } else {
        panic!("Invalid beast")
    }
}

pub fn get_type(beast: u8) -> felt252 {
    type_name(get_type_code(beast))
}

pub fn get_type_code(beast: u8) -> u8 {
    assert(beast != 0, 'Invalid beast');
    if (beast <= 25) {
        TYPE_CODE_MAGIC
    } else if beast <= 50 {
        TYPE_CODE_HUNTER
    } else if beast <= 75 {
        TYPE_CODE_BRUTE
    } else {
        panic!("Invalid beast")
    }
}
