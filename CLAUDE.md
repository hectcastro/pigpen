# Pigpen Cipher — Project Guide

Single-page Elm app that encodes/decodes text using the pigpen cipher.

## File Structure

```
index.html                      ← Static shell: global CSS reset, font vars, keyframes, theme boot
                                   script, mounts Elm and wires the setTheme port
mise.toml                       ← Toolchain (elm, node, elm-test) + dev/test/build tasks
elm.json                        ← Elm package manifest (elm/browser, elm/svg, elm-explorations/test)
.github/workflows/deploy.yml    ← CI/CD: test → build → deploy to GitHub Pages
src/
  Cipher.elm                    ← Pure data: Glyph/Sides/Dir types + glyph()/alphabet
  Glyphs.elm                    ← elm/svg rendering: Glyph -> Svg msg
  Main.elm                      ← Browser.element app: model, update, view, icons, setTheme port
  app.css                       ← All styles as plain CSS classes (BEM-style modifiers)
  fonts/                        ← Vendored Departure Mono (woff2) + its SIL OFL license text
tests/
  CipherTest.elm                ← elm-test suite for Cipher.elm
```

## Architecture

### Cipher logic (`src/Cipher.elm`)
- `Glyph` — `Grid Sides` (letters A–R: which of 4 sides are drawn + dot flag) or `Cross Dir Bool` (letters S–Z: diagonal direction + dot flag)
- `Sides` — record of `top`/`right`/`bottom`/`left`/`dot` booleans
- `alphabet` — the 26-letter `List Char`, A–Z
- `glyph : Char -> Maybe Glyph` — case-insensitive lookup; `Nothing` for anything outside A–Z (digits/punctuation/whitespace pass through the UI unchanged)
- No scrambling/passphrase support — the mapping is fixed, standard pigpen

### Glyph rendering (`src/Glyphs.elm`)
- `view : Int -> Glyph -> Svg msg` — renders a `Grid` as up to 4 strokes + dot, a `Cross` as 2 diagonal strokes + dot (coordinates/case-expressions mirror the old X_LINES/X_DOT tables)
- `Svg msg` and `Html msg` are the same underlying type in Elm, so glyphs drop directly into `Html` view trees with no wrapping

### UI (`src/Main.elm` + `src/app.css`)
- `Model` — `mode` (Encode/Decode), `text`, `decoded`, `showRef`, `theme`
- `Msg` — `SetMode`, `SetText`, `Append`, `Backspace`, `Clear`, `ToggleRef`, `ToggleTheme`
- Encode mode splits input into whitespace/word runs (`segments`/`groupRuns`) to mirror `text.split(/(\s+)/)` word-spacing behavior
- Decode mode is a tap keyboard: each glyph button `Append`s its own letter to `decoded`
- Reference is an independent overlay (`showRef`), not a third mode — it renders below whichever of Encode/Decode is active
- `port setTheme : String -> Cmd msg` is the only side effect; `index.html`'s boot script persists it to `localStorage` and writes `document.documentElement.dataset.theme` (that attribute lives on `<html>`, outside Elm's mounted node, so it can't be touched from Elm directly)
- All styling via plain CSS classes with BEM-style modifiers (e.g. `pill--active`, `controlBtn--space`)
- Two font tokens, both declared in `index.html`'s `:root`: `--font-sans` (Source Sans 3, Google-hosted) for body copy, inputs, and pills; `--font-pixel` (Departure Mono, self-hosted from `src/fonts/`) for the brand title, headings, small-caps labels/badges, and the two glyph-adjacent mono slots. Departure Mono is a single weight — every rule using it pins `font-weight: 400` — and sized in flat `px` at multiples of 11 per the font's own crispness guidance, not `rem`.

### Toolchain
- [mise](https://mise.jdx.dev/) owns `elm`, `node`, `elm-test` (npm backend), and `elm-format` (github backend, `avh4/elm-format`) — no `package.json`, no `npx`
- `mise run dev` — `elm reactor`
- `mise run test` — `elm-test`
- `mise run format` — `elm-format --yes src tests`
- `mise run build` — `elm make --optimize`, then copies `index.html`, `src/app.css`, and `src/fonts/` into `dist/`

### Deployment
- GitHub Actions workflow: `test` → `build` → `deploy` (each job gates the next), using `jdx/mise-action` to install the toolchain
- Assets in `index.html` use relative paths, so no base-path env var is needed at build time

## Known Limitations
- No clipboard copy for encoded output
- No image export of glyph output
- No persistence — state resets on reload (except theme, via `localStorage`)
- No support for numbers or punctuation in cipher output
