// Draws the HeyMey lamp mark (same geometry as design/stall/build.mjs) into the web app's PWA icons.
// Run from the repo root: node tools/stall/pwa-icons.mjs
// The Android launcher icon is still Flutter's default logo, so it is not a usable source for these icons.
import { writeFileSync } from "node:fs";
import { PNG } from "pngjs";

const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));
const PAPER = hex("#FAF6EE"),
  INK = hex("#111111"),
  RED = hex("#D7261E"),
  YELLOW = hex("#F5C518");

// Signed distance (negative inside) for the three lamp shapes, in lamp units (0..1).
const tri = [
  [0.5, 0],
  [0.68, 0.32],
  [0.32, 0.32],
];
function triDist(x, y) {
  let d = -Infinity;
  for (let i = 0; i < 3; i++) {
    const [ax, ay] = tri[i],
      [bx, by] = tri[(i + 1) % 3];
    const nx = by - ay,
      ny = ax - bx,
      len = Math.hypot(nx, ny);
    d = Math.max(d, ((x - ax) * nx + (y - ay) * ny) / len); // clockwise winding: outward normal
  }
  return d;
}
const circDist = (x, y) => Math.hypot(x - 0.5, y - 0.5) - 0.2;
const rectDist = (x, y) => Math.max(Math.abs(x - 0.5) - 0.3, Math.abs(y - 0.83) - 0.11);
const shapes = [
  [triDist, YELLOW],
  [circDist, RED],
  [rectDist, INK],
];

function colour(x, y, sw) {
  let c = PAPER;
  for (const [dist, fill] of shapes) {
    const d = dist(x, y);
    if (d <= -sw / 2) c = fill;
    else if (d <= sw / 2) c = INK;
  }
  return c;
}

// `scale` is the lamp size as a share of the icon edge; maskable icons keep it inside the 80% safe circle.
function icon(size, scale) {
  const png = new PNG({ width: size, height: size });
  const sw = 0.04,
    ss = 4,
    off = (1 - scale) / 2;
  for (let py = 0; py < size; py++)
    for (let px = 0; px < size; px++) {
      const acc = [0, 0, 0];
      for (let sy = 0; sy < ss; sy++)
        for (let sx = 0; sx < ss; sx++) {
          const u = ((px + (sx + 0.5) / ss) / size - off) / scale;
          const v = ((py + (sy + 0.5) / ss) / size - off) / scale;
          colour(u, v, sw).forEach((ch, i) => (acc[i] += ch));
        }
      const i = (py * size + px) * 4;
      png.data.set([...acc.map((a) => Math.round(a / (ss * ss))), 255], i);
    }
  return PNG.sync.write(png);
}

const out = "apps/mobile/web/icons/";
writeFileSync(out + "Icon-192.png", icon(192, 0.8));
writeFileSync(out + "Icon-512.png", icon(512, 0.8));
writeFileSync(out + "Icon-maskable-192.png", icon(192, 0.56));
writeFileSync(out + "Icon-maskable-512.png", icon(512, 0.56));
console.log("wrote 4 icons to " + out);
