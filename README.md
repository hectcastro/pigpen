# PIGPEN!!!

A single-page web app for encoding and decoding text using the classic pigpen cipher, with optional passphrase-based alphabet scrambling for shared-secret use.

## Features

- **Encode mode** — type plaintext and see pigpen glyphs rendered in real time
- **Decode mode** — tap a visual glyph keyboard to reconstruct the original message
- **Keyed scrambling** — supply a shared passphrase to shuffle the letter-to-symbol mapping; the same passphrase always produces the same scramble
- **Symbol reference** — collapsible chart of all 26 glyphs, updated to reflect the active key
- All glyphs are inline SVG; no images or icon libraries

## Getting Started

```bash
npm install
npm run dev
```

Then open `http://localhost:5173` in your browser.

```bash
npm test          # run tests once
npm run test:watch  # re-run on save
npm run build     # production build
```

## How Keyed Scrambling Works

Without a passphrase the app uses the standard pigpen alphabet (A maps to the first grid slot, B to the second, and so on). When you enter a passphrase:

1. The passphrase is hashed to a `uint32` seed using a simple character-accumulation hash.
2. That seed drives an xorshift PRNG.
3. Fisher-Yates shuffles the 26-letter alphabet with that PRNG, producing a deterministic permutation.
4. The encode map routes each plaintext letter to the symbol slot its shuffled counterpart occupies; the decode map reverses this.

Both the sender and recipient enter the same passphrase to share the mapping. This is obfuscation, not cryptography — the keyspace is 26! and the PRNG is xorshift.
