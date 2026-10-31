// Authored Cyclops Sound Check: exact original Beast Sound Check track 504.
// The whole eight-program sequence retains its own notes, timbres and 175 BPM on all effects.
export const CYCLOPS_SOUND_CHECK_PROGRAMS = Object.freeze([34, 35, 36, 37, 38, 39, 40, 41]);
export const CYCLOPS_SOUND_CHECK_TEMPO_US = 342857;
export const CYCLOPS_SOUND_CHECK_LENGTH = 38400;

export function cyclopsSoundCheckMidi() {
  const vlq = (n) => { const bytes = [n & 127]; while ((n >>>= 7)) bytes.unshift((n & 127) | 128); return bytes; };
  const chunk = (tag, bytes) => [...tag].map((c) => c.charCodeAt(0)).concat([bytes.length >>> 24, (bytes.length >>> 16) & 255, (bytes.length >>> 8) & 255, bytes.length & 255], bytes);
  const tempo = [0, 255, 81, 3, 5, 59, 73, ...vlq(CYCLOPS_SOUND_CHECK_LENGTH), 255, 47, 0];
  const data = []; let last = 0;
  const event = (tick, ...bytes) => { data.push(...vlq(tick - last), ...bytes); last = tick; };
  const note = (at, key, duration) => { event(at, 144, key, 100); event(at + duration, 128, key, 64); };
  CYCLOPS_SOUND_CHECK_PROGRAMS.forEach((program, i) => {
    const start = i * 4800;
    event(start, 192, program);
    if (i === 0) { event(0, 176, 7, 100); event(0, 176, 10, 64); }
    [60, 64, 67, 72].forEach((key, k) => note(start + k * 480, key, 440));
    note(start + 1920, 67, 1100);
    [60, 64, 67, 72].forEach((key, k) => note(start + 3360 + k * 240, key, 58));
  });
  event(CYCLOPS_SOUND_CHECK_LENGTH, 255, 47, 0);
  const midi = Uint8Array.from(chunk('MThd', [0, 1, 0, 2, 1, 224]).concat(chunk('MTrk', tempo), chunk('MTrk', data)));
  return { midi, settingsKey: 'cyclops-check', info: { key: 'C major', presets: [...CYCLOPS_SOUND_CHECK_PROGRAMS], tempo: 175, tempo_us: CYCLOPS_SOUND_CHECK_TEMPO_US, authored: true } };
}
