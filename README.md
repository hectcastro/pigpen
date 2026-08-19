# PIGPEN!!!

A single-page web app for encoding and decoding text using the classic pigpen cipher.

## Features

- **Encode mode** — type plaintext and see pigpen glyphs rendered in real time
- **Decode mode** — tap a visual glyph keyboard to reconstruct the original message
- **Symbol reference** — chart of all 26 glyphs
- **Dark/light theme** — remembered across visits
- All glyphs are inline SVG; no images or icon libraries

## Getting Started

Requires [mise](https://mise.jdx.dev/) to manage the toolchain (Elm, Node, elm-test).

```bash
mise install
mise run dev
```

Then open the URL `elm reactor` prints (typically `http://localhost:8000`) and navigate to `src/Main.elm`.

```bash
mise run test    # run the elm-test suite once
mise run format  # apply elm-format to src/ and tests/
mise run build   # production build into dist/
```

## Credits

Display type is [Departure Mono](https://departuremono.com/) by Helena Zhang, licensed under the
SIL Open Font License (see `src/fonts/LICENSE-OFL.txt`).
