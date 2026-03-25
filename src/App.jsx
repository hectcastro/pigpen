import { useState, useCallback } from "react";
import styles from "./App.module.css";
import { GRID, XMAP, ALPHA, buildMaps } from "./cipher.js";
import PigpenChar from "./Glyphs.jsx";

function getInitialTheme() {
  const stored = localStorage.getItem("theme");
  if (stored === "dark" || stored === "light") return stored;
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}
document.documentElement.dataset.theme = getInitialTheme();

/* ───────────────────── UI COMPONENTS ───────────────────── */

function Pill({ children, active, onClick }) {
  return (
    <button
      onClick={onClick}
      className={`${styles.pill} ${active ? styles["pill--active"] : ""}`}
    >
      {children}
    </button>
  );
}

function OutputCard({ label, children }) {
  return (
    <div className={styles.outputCard}>
      <div className={styles.outputCardHeader}>
        <span className={styles.outputCardLabel}>{label}</span>
      </div>
      {children}
    </div>
  );
}

/* ───────────────────── MAIN APP ───────────────────── */

const REF_SECTIONS = [
  { label: "Grid", letters: "ABCDEFGHI", tag: "no dot" },
  { label: "Grid + Dot", letters: "JKLMNOPQR", tag: "dot" },
  { label: "X", letters: "STUV", tag: "no dot" },
  { label: "X + Dot", letters: "WXYZ", tag: "dot" },
];

const { encodeMap, decodeMap } = buildMaps();

export default function App() {
  const [mode, setMode] = useState("encode");
  const [text, setText] = useState("");
  const [decoded, setDecoded] = useState("");
  const [showRef, setShowRef] = useState(false);
  const [theme, setTheme] = useState(() => document.documentElement.dataset.theme);

  function toggleTheme() {
    const next = theme === "dark" ? "light" : "dark";
    setTheme(next);
    document.documentElement.dataset.theme = next;
    localStorage.setItem("theme", next);
  }

  const handleDecodeClick = useCallback((slotLetter) => {
    setDecoded((p) => p + (decodeMap[slotLetter] || slotLetter));
  }, [decodeMap]);

  const encodeWords = text.split(/(\s+)/);

  return (
    <div className={styles.root}>

      {/* ── NAV ── */}
      <nav className={styles.nav}>
        <div className={styles.navBrand}>
          <svg width="36" height="36" viewBox="0 0 40 40" fill="none">
            <line x1="4" y1="4" x2="36" y2="4" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/>
            <line x1="36" y1="4" x2="36" y2="36" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/>
            <line x1="4" y1="36" x2="36" y2="36" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/>
            <line x1="4" y1="4" x2="4" y2="36" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/>
            <circle cx="20" cy="20" r="3" fill="currentColor"/>
          </svg>
          <span className={styles.navTitle}>PIGPEN!!!</span>
        </div>
        <div className={styles.navPills}>
          <Pill active={mode === "encode"} onClick={() => setMode("encode")}>Encode</Pill>
          <Pill active={mode === "decode"} onClick={() => setMode("decode")}>Decode</Pill>
          <Pill active={showRef} onClick={() => setShowRef(!showRef)}>Reference</Pill>
          <button onClick={toggleTheme} className={styles.themeToggle} aria-label="Toggle theme">
            {theme === "dark" ? (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="12" cy="12" r="5"/>
                <line x1="12" y1="1" x2="12" y2="3"/>
                <line x1="12" y1="21" x2="12" y2="23"/>
                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                <line x1="1" y1="12" x2="3" y2="12"/>
                <line x1="21" y1="12" x2="23" y2="12"/>
                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
              </svg>
            ) : (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
              </svg>
            )}
          </button>
        </div>
      </nav>

      {/* ── HERO ── */}
      <section className={styles.hero}>
        <h1 className={styles.heroHeading}>
          {mode === "encode" ? "Encode your message" : "Decode cipher symbols"}
        </h1>
        <p className={styles.heroSub}>
          {mode === "encode"
            ? "Type plaintext below to translate it into pigpen cipher symbols."
            : "Tap pigpen glyphs to reconstruct the original message."}
        </p>
      </section>

      {/* ── MAIN ── */}
      <main className={styles.main}>

        {/* ════ ENCODE ════ */}
        {mode === "encode" && (
          <>
            <textarea
              value={text}
              onChange={(e) => setText(e.target.value)}
              placeholder="Type your secret message…"
              rows={4}
              className={styles.textarea}
            />

            {text.length > 0 && (
              <div className={styles.encodeOutput}>
                <OutputCard label="encoded symbols">
                  <div className={styles.glyphRow}>
                    {encodeWords.map((seg, wi) => {
                      if (/^\s+$/.test(seg)) return <div key={`s${wi}`} className={styles.glyphWordSpacer}/>;
                      return (
                        <span key={wi} className={styles.glyphWord}>
                          {seg.split("").map((ch, ci) => {
                            const u = ch.toUpperCase();
                            const symbolLetter = encodeMap[u];
                            if (symbolLetter && (GRID[symbolLetter] || XMAP[symbolLetter])) {
                              return <PigpenChar key={ci} letter={symbolLetter} size={44} color="currentColor"/>;
                            }
                            return <span key={ci} className={styles.glyphPassthrough}>{ch}</span>;
                          })}
                        </span>
                      );
                    })}
                  </div>
                </OutputCard>
                <div className={styles.plaintextHint}>
                  <span className={styles.plaintextHintLabel}>plaintext:</span>{text}
                </div>
              </div>
            )}
          </>
        )}

        {/* ════ DECODE ════ */}
        {mode === "decode" && (
          <>
            <div className={styles.decodeGrid}>
              {ALPHA.map((slotLetter) => {
                const decodedLetter = decodeMap[slotLetter];
                return (
                  <button
                    key={slotLetter}
                    onClick={() => handleDecodeClick(slotLetter)}
                    title={`Decodes to: ${decodedLetter}`}
                    className={styles.decodeBtn}
                  >
                    <PigpenChar letter={slotLetter} size={52} color="currentColor"/>
                    <span className={styles.decodeBtnLabel}>
                      {decodedLetter}
                    </span>
                  </button>
                );
              })}
            </div>

            <div className={styles.controlBtns}>
              {[
                { label: "Space", flex: 3, fn: () => setDecoded((p) => p + " ") },
                { label: "⌫", flex: 1, fn: () => setDecoded((p) => p.slice(0, -1)) },
                { label: "Clear", flex: 1, fn: () => setDecoded("") },
              ].map((btn) => (
                <button
                  key={btn.label}
                  onClick={btn.fn}
                  className={styles.controlBtn}
                  style={{ flex: btn.flex }}
                >
                  {btn.label}
                </button>
              ))}
            </div>

            <OutputCard label="decoded message">
              <div className={styles.decodedOutput}>
                {decoded ? (
                  <>
                    {decoded}
                    <span className={styles.cursor}/>
                  </>
                ) : (
                  <span className={styles.decodedPlaceholder}>Tap symbols above to see your message…</span>
                )}
              </div>
            </OutputCard>
          </>
        )}

        {/* ════ REFERENCE ════ */}
        {showRef && (
          <div className={styles.refSection}>
            <div className={styles.refHeader}>
              <h2 className={styles.refHeading}>Symbol Reference</h2>
            </div>

            {REF_SECTIONS.map((sec) => (
              <div key={sec.label} className={styles.refGroup}>
                <div className={styles.refGroupHeader}>
                  <span className={styles.refGroupLabel}>{sec.label}</span>
                  <span className={`${styles.refTagBadge} ${sec.tag === "dot" ? styles["refTagBadge--dot"] : styles["refTagBadge--nodot"]}`}>
                    {sec.tag}
                  </span>
                </div>
                <div className={styles.refGrid}>
                  {sec.letters.split("").map((slotLetter) => {
                    const plainLetter = decodeMap[slotLetter];
                    return (
                      <div key={slotLetter} className={styles.refCell}>
                        <PigpenChar letter={slotLetter} size={44} color="currentColor"/>
                        <span className={styles.refCellLabel}>
                          {plainLetter}
                        </span>
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        )}


      </main>

      {/* ── FOOTER ── */}
      <footer className={styles.footer}>
        <span>PIGPEN!!!</span>
      </footer>
    </div>
  );
}
