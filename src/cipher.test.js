import { describe, it, expect } from "vitest";
import { ALPHA, GRID, XMAP, buildMaps } from "./cipher.js";

/* ───────────────────── ALPHA ───────────────────── */

describe("ALPHA", () => {
  it("contains all 26 letters", () => {
    expect(ALPHA).toHaveLength(26);
  });

  it("is ordered A–Z", () => {
    expect(ALPHA.join("")).toBe("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
  });
});

/* ───────────────────── GRID ───────────────────── */

describe("GRID", () => {
  it("covers letters A–R (18 entries)", () => {
    expect(Object.keys(GRID)).toHaveLength(18);
    expect(Object.keys(GRID)).toEqual("ABCDEFGHIJKLMNOPQR".split(""));
  });

  it("each entry has t, r, b, l, d flags that are 0 or 1", () => {
    for (const [letter, cfg] of Object.entries(GRID)) {
      for (const key of ["t", "r", "b", "l", "d"]) {
        expect(cfg[key], `${letter}.${key}`).toBeOneOf([0, 1]);
      }
    }
  });

  it("A–I have no dot (d: 0)", () => {
    for (const letter of "ABCDEFGHI") {
      expect(GRID[letter].d, letter).toBe(0);
    }
  });

  it("J–R have a dot (d: 1)", () => {
    for (const letter of "JKLMNOPQR") {
      expect(GRID[letter].d, letter).toBe(1);
    }
  });
});

/* ───────────────────── XMAP ───────────────────── */

describe("XMAP", () => {
  it("covers letters S–Z (8 entries)", () => {
    expect(Object.keys(XMAP)).toHaveLength(8);
    expect(Object.keys(XMAP)).toEqual("STUVWXYZ".split(""));
  });

  it("each entry has a valid direction and a dot flag of 0 or 1", () => {
    const validDirs = new Set(["u", "r", "d", "l"]);
    for (const [letter, cfg] of Object.entries(XMAP)) {
      expect(validDirs.has(cfg.dir), `${letter}.dir`).toBe(true);
      expect(cfg.d, `${letter}.d`).toBeOneOf([0, 1]);
    }
  });

  it("S–V have no dot (d: 0)", () => {
    for (const letter of "STUV") {
      expect(XMAP[letter].d, letter).toBe(0);
    }
  });

  it("W–Z have a dot (d: 1)", () => {
    for (const letter of "WXYZ") {
      expect(XMAP[letter].d, letter).toBe(1);
    }
  });
});

/* ───────────────────── buildMaps ───────────────────── */

describe("buildMaps", () => {
  it("encodeMap and decodeMap are identity mappings for all 26 letters", () => {
    const { encodeMap, decodeMap } = buildMaps();
    for (const letter of ALPHA) {
      expect(encodeMap[letter]).toBe(letter);
      expect(decodeMap[letter]).toBe(letter);
    }
  });

  it("both maps contain all 26 letters as keys", () => {
    const { encodeMap, decodeMap } = buildMaps();
    expect(Object.keys(encodeMap)).toHaveLength(26);
    expect(Object.keys(decodeMap)).toHaveLength(26);
  });
});
