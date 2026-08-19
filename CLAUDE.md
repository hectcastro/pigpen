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

### Toolchain
- [mise](https://mise.jdx.dev/) owns `elm`, `node`, and `elm-test` (via mise's npm backend) — no `package.json`, no `npx`
- `mise run dev` — `elm reactor`
- `mise run test` — `elm-test`
- `mise run build` — `elm make --optimize` then copies `index.html` + `src/app.css` into `dist/`

### Deployment
- GitHub Actions workflow: `test` → `build` → `deploy` (each job gates the next), using `jdx/mise-action` to install the toolchain
- Assets in `index.html` use relative paths, so no base-path env var is needed at build time

## Known Limitations
- No clipboard copy for encoded output
- No image export of glyph output
- No persistence — state resets on reload (except theme, via `localStorage`)
- No support for numbers or punctuation in cipher output
