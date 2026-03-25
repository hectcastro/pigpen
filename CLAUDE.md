# Pigpen Cipher — Project Guide

Single-page React app that encodes/decodes text using the pigpen cipher, with optional passphrase-based alphabet scrambling for shared-secret use.

## File Structure

```
index.html                      ← Vite entry point; global CSS reset, font vars, keyframes
vite.config.js                  ← Vite + React plugin; reads VITE_BASE_PATH env var for deployment
package.json
.github/workflows/deploy.yml    ← CI/CD: test → build → deploy to GitHub Pages
src/
  cipher.js                     ← Pure JS: cipher data constants + buildMaps(); no React
  cipher.test.js                ← Vitest tests for cipher.js
  Glyphs.jsx                    ← SVG glyph components (GridGlyph, XGlyph, PigpenChar)
  App.jsx                       ← UI components (Pill, OutputCard) + main App component
  App.module.css                ← All styles as CSS Modules; no inline styles
  main.jsx                      ← React root mount
```

## Architecture

### Cipher logic (`cipher.js`)
- `GRID` — letters A–R: which of 4 sides (t/r/b/l) are drawn + dot flag
- `XMAP` — letters S–Z: diagonal direction (u/r/d/l) + dot flag
- `ALPHA` — the 26-letter array used as the standard slot ordering
- `buildMaps(passphrase)` — returns `encodeMap` (plaintext → symbol slot) and `decodeMap` (symbol slot → plaintext)
- Keyed scrambling internals (unexported): `seedFromPhrase` → `seededRng` → `shuffleAlphabet`
- Same passphrase always yields the same mapping; empty/whitespace = standard pigpen

### Glyph rendering (`Glyphs.jsx`)
- `GridGlyph` / `XGlyph` — internal SVG renderers; not exported
- `PigpenChar` — default export; dispatches to the correct renderer by letter

### UI (`App.jsx` + `App.module.css`)
- `Pill` — nav toggle button; `.pill` / `.pill--active` CSS modifier classes
- `OutputCard` — labelled card wrapper for encode/decode output
- `App` — main component; three modes: Encode, Decode, Reference
- All styling via CSS Modules with BEM-style modifier classes (e.g. `passphraseBox--keyed`)
- Hover/focus states handled by CSS pseudo-selectors, not JS event handlers
- Font stacks defined as `--font-sans` / `--font-mono` CSS custom properties in `index.html`

### Deployment
- GitHub Actions workflow: `test` → `build` → `deploy` (each job gates the next)
- `VITE_BASE_PATH` env var sets the Vite base URL at build time (defaults to `/`)

## Known Limitations
- Scrambling is obfuscation, not cryptographic (xorshift PRNG, 26! keyspace)
- No clipboard copy for encoded output
- No image export of glyph output
- No persistence — state resets on reload
- No support for numbers or punctuation in cipher output
