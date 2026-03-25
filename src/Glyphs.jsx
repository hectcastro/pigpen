import { GRID, XMAP, X_LINES, X_DOT } from "./cipher.js";

const SK = 3.5, PD = 4, VB = 40;

function GridGlyph({ cfg, size = 40, color = "currentColor" }) {
  return (
    <svg width={size} height={size} viewBox={`0 0 ${VB} ${VB}`} fill="none">
      {cfg.t ? <line x1={PD} y1={PD} x2={VB-PD} y2={PD} stroke={color} strokeWidth={SK} strokeLinecap="round"/> : null}
      {cfg.r ? <line x1={VB-PD} y1={PD} x2={VB-PD} y2={VB-PD} stroke={color} strokeWidth={SK} strokeLinecap="round"/> : null}
      {cfg.b ? <line x1={PD} y1={VB-PD} x2={VB-PD} y2={VB-PD} stroke={color} strokeWidth={SK} strokeLinecap="round"/> : null}
      {cfg.l ? <line x1={PD} y1={PD} x2={PD} y2={VB-PD} stroke={color} strokeWidth={SK} strokeLinecap="round"/> : null}
      {cfg.d ? <circle cx={VB/2} cy={VB/2} r={3} fill={color}/> : null}
    </svg>
  );
}

function XGlyph({ cfg, size = 40, color = "currentColor" }) {
  const lines = X_LINES[cfg.dir];
  const dot = X_DOT[cfg.dir];
  return (
    <svg width={size} height={size} viewBox={`0 0 ${VB} ${VB}`} fill="none">
      {lines.map((l, i) => (
        <line key={i} x1={l.x1} y1={l.y1} x2={l.x2} y2={l.y2} stroke={color} strokeWidth={SK} strokeLinecap="round"/>
      ))}
      {cfg.d ? <circle cx={dot.cx} cy={dot.cy} r={3} fill={color}/> : null}
    </svg>
  );
}

export default function PigpenChar({ letter, size = 40, color = "currentColor" }) {
  const u = letter.toUpperCase();
  if (GRID[u]) return <GridGlyph cfg={GRID[u]} size={size} color={color}/>;
  if (XMAP[u]) return <XGlyph cfg={XMAP[u]} size={size} color={color}/>;
  return null;
}
