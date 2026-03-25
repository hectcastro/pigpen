/* ───────────────────── CIPHER DATA ───────────────────── */

export const GRID = {
  A: { t: 0, r: 1, b: 1, l: 0, d: 0 }, B: { t: 0, r: 1, b: 1, l: 1, d: 0 },
  C: { t: 0, r: 0, b: 1, l: 1, d: 0 }, D: { t: 1, r: 1, b: 1, l: 0, d: 0 },
  E: { t: 1, r: 1, b: 1, l: 1, d: 0 }, F: { t: 1, r: 0, b: 1, l: 1, d: 0 },
  G: { t: 1, r: 1, b: 0, l: 0, d: 0 }, H: { t: 1, r: 1, b: 0, l: 1, d: 0 },
  I: { t: 1, r: 0, b: 0, l: 1, d: 0 },
  J: { t: 0, r: 1, b: 1, l: 0, d: 1 }, K: { t: 0, r: 1, b: 1, l: 1, d: 1 },
  L: { t: 0, r: 0, b: 1, l: 1, d: 1 }, M: { t: 1, r: 1, b: 1, l: 0, d: 1 },
  N: { t: 1, r: 1, b: 1, l: 1, d: 1 }, O: { t: 1, r: 0, b: 1, l: 1, d: 1 },
  P: { t: 1, r: 1, b: 0, l: 0, d: 1 }, Q: { t: 1, r: 1, b: 0, l: 1, d: 1 },
  R: { t: 1, r: 0, b: 0, l: 1, d: 1 },
};

export const XMAP = {
  S: { dir: "u", d: 0 }, T: { dir: "r", d: 0 },
  U: { dir: "d", d: 0 }, V: { dir: "l", d: 0 },
  W: { dir: "u", d: 1 }, X: { dir: "r", d: 1 },
  Y: { dir: "d", d: 1 }, Z: { dir: "l", d: 1 },
};

export const X_LINES = {
  u: [{ x1: 4, y1: 36, x2: 20, y2: 4 }, { x1: 36, y1: 36, x2: 20, y2: 4 }],
  r: [{ x1: 4, y1: 4, x2: 36, y2: 20 }, { x1: 4, y1: 36, x2: 36, y2: 20 }],
  d: [{ x1: 4, y1: 4, x2: 20, y2: 36 }, { x1: 36, y1: 4, x2: 20, y2: 36 }],
  l: [{ x1: 36, y1: 4, x2: 4, y2: 20 }, { x1: 36, y1: 36, x2: 4, y2: 20 }],
};

export const X_DOT = {
  u: { cx: 20, cy: 25 }, r: { cx: 15, cy: 20 },
  d: { cx: 20, cy: 15 }, l: { cx: 25, cy: 20 },
};

export const ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

export function buildMaps() {
  const encodeMap = {};
  const decodeMap = {};
  for (const letter of ALPHA) {
    encodeMap[letter] = letter;
    decodeMap[letter] = letter;
  }
  return { encodeMap, decodeMap };
}
