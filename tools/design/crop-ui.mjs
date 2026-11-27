// Crops mascot poses, illustrations and icons out of the approved UI mock-ups in design/ui/ and writes
// transparent PNGs to dart/hm_design/assets/img/. Run: node tools/design/crop-ui.mjs
// Background removal: flood fill from the crop border through light pixels whose colour changes only gradually,
// so the fill stops at the mascot's dark outline and keeps eye highlights inside it.
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { createRequire } from "node:module";
const require = createRequire(import.meta.url);
const { PNG } = require("pngjs");

const SRC = new URL("../../design/ui/", import.meta.url);
const OUT = new URL("../../dart/hm_design/assets/img/", import.meta.url);
mkdirSync(OUT, { recursive: true });

// Coordinates are measured on the 1438-wide preview; S converts them to the 1536-wide originals.
const S = 1536 / 1438;
// [output name, source file, x0, y0, x1, y1, remove background?, rectangles to erase]
const CROPS = [
  ["mey_splash", "01_LoadingSplash.png", 440, 560, 970, 1375, true],
  ["mey_hold_lamp", "05_Today(home).png", 800, 675, 1152, 1078, true, [[800, 675, 862, 828]]],
  ["mey_peek", "03_Start.png", 1072, 252, 1236, 542, true, [[1072, 480, 1098, 525]]],
  ["mey_think", "04_PlanSetup.png", 998, 1192, 1212, 1522, true],
  ["mey_reading", "07_Lesson(with Listen).png", 512, 472, 922, 812, true],
  ["mey_thumbs", "08_CheckRelightquestion.png", 978, 1648, 1208, 1912, true],
  ["mey_sleepy", "09_Relight list.png", 798, 698, 1148, 1068, true],
  ["mey_pencil", "10_Practice.png", 822, 528, 1152, 922, true],
  ["mey_puzzled", "11_Mistakes.png", 922, 2028, 1168, 2378, true],
  ["mey_small", "12_PYQVault.png", 984, 698, 1172, 922, true],
  ["mey_cheer", "14_Plan.png", 858, 722, 1128, 1112, true],
  ["mey_calendar", "14_Plan.png", 818, 2048, 1172, 2342, true],
  ["mey_proud", "15_Readiness.png", 782, 538, 1162, 1062, true],
  ["mey_celebrate", "17_Reportdetail.png", 993, 312, 1197, 542, true],
  ["mey_wink", "06_StudyMap.png", 852, 1098, 1058, 1388, true],
  ["chest", "12_PYQVault.png", 288, 528, 662, 892, true],
  ["envelope", "16_Sundayreportslist.png", 898, 553, 1147, 832, true],
  ["lamp_lit", "06_StudyMap.png", 412, 1712, 578, 1942, true],
  ["lamp_gold", "06_StudyMap.png", 432, 1398, 612, 1602, true],
  ["lamp_dim", "06_StudyMap.png", 648, 982, 788, 1122, true],
  ["lamp_locked", "06_StudyMap.png", 648, 758, 798, 908, true],
  ["lamp_fading", "09_Relight list.png", 284, 1340, 382, 1466, true],
  ["story_1", "02_StoryOnboarding.png", 255, 435, 1185, 1418, false],
  ["ic_group4", "03_Start.png", 315, 915, 475, 1075, false],
  ["ic_group2", "03_Start.png", 315, 1210, 475, 1370, false],
  ["ic_group1", "03_Start.png", 315, 1505, 475, 1665, false],
  ["ic_polity", "10_Practice.png", 298, 1053, 406, 1162, false],
  ["ic_history", "10_Practice.png", 781, 1053, 890, 1162, false],
  ["ic_geography", "10_Practice.png", 298, 1447, 406, 1556, false],
  ["ic_economy", "10_Practice.png", 781, 1447, 890, 1556, false],
  ["ic_aptitude", "10_Practice.png", 298, 1895, 406, 2004, false],
  ["ic_tamil", "10_Practice.png", 781, 1895, 890, 2004, false],
  ["ic_gavel", "15_Readiness.png", 560, 2230, 665, 2335, true],
  ["ic_pencil_math", "15_Readiness.png", 1040, 2230, 1148, 2335, true],
];

const cache = new Map();
const load = (f) => cache.get(f) ?? cache.set(f, PNG.sync.read(readFileSync(new URL(f, SRC)))).get(f);

function crop(img, x0, y0, x1, y1) {
  const [X0, Y0, X1, Y1] = [x0, y0, x1, y1].map((v) => Math.round(v * S));
  const w = X1 - X0, h = Y1 - Y0;
  const out = new PNG({ width: w, height: h });
  for (let y = 0; y < h; y++) {
    const s = ((Y0 + y) * img.width + X0) * 4;
    img.data.copy(out.data, y * w * 4, s, s + w * 4);
  }
  return out;
}

function removeBackground(p) {
  const { width: w, height: h, data: d } = p;
  const light = (i) => Math.min(d[i], d[i + 1], d[i + 2]) > 150 && d[i] + d[i + 1] + d[i + 2] > 560;
  const near = (a, b) => Math.abs(d[a] - d[b]) + Math.abs(d[a + 1] - d[b + 1]) + Math.abs(d[a + 2] - d[b + 2]) < 24;
  const seen = new Uint8Array(w * h);
  const stack = [];
  for (let x = 0; x < w; x++) stack.push([x, 0], [x, h - 1]);
  for (let y = 0; y < h; y++) stack.push([0, y], [w - 1, y]);
  for (const [x, y] of stack) seen[y * w + x] = 1;
  const bg = [];
  while (stack.length) {
    const [x, y] = stack.pop();
    const i = (y * w + x) * 4;
    if (!light(i)) continue;
    bg.push(y * w + x);
    for (const [nx, ny] of [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]]) {
      if (nx < 0 || ny < 0 || nx >= w || ny >= h || seen[ny * w + nx]) continue;
      if (!near(i, (ny * w + nx) * 4)) continue;
      seen[ny * w + nx] = 1;
      stack.push([nx, ny]);
    }
  }
  const mask = new Uint8Array(w * h);
  for (const k of bg) mask[k] = 1;
  for (const k of bg) d[k * 4 + 3] = 0;
  // Soften the edge: pixels next to removed background get half alpha.
  for (let y = 1; y < h - 1; y++)
    for (let x = 1; x < w - 1; x++) {
      const k = y * w + x;
      if (mask[k]) continue;
      if (mask[k - 1] || mask[k + 1] || mask[k - w] || mask[k + w]) d[k * 4 + 3] = 170;
    }
  return p;
}

// Box-filter downscale so the longest side is at most max px (2x the largest size a screen shows it at).
function shrink(p, max) {
  const f = Math.max(p.width, p.height) / max;
  if (f <= 1) return p;
  const w = Math.round(p.width / f), h = Math.round(p.height / f);
  const out = new PNG({ width: w, height: h });
  for (let y = 0; y < h; y++)
    for (let x = 0; x < w; x++) {
      const sx0 = Math.floor(x * f), sx1 = Math.min(p.width, Math.ceil((x + 1) * f));
      const sy0 = Math.floor(y * f), sy1 = Math.min(p.height, Math.ceil((y + 1) * f));
      const acc = [0, 0, 0, 0];
      let n = 0;
      for (let sy = sy0; sy < sy1; sy++)
        for (let sx = sx0; sx < sx1; sx++) {
          const i = (sy * p.width + sx) * 4, a = p.data[i + 3];
          acc[0] += p.data[i] * a; acc[1] += p.data[i + 1] * a; acc[2] += p.data[i + 2] * a; acc[3] += a; n++;
        }
      const o = (y * w + x) * 4;
      for (let k = 0; k < 3; k++) out.data[o + k] = acc[3] ? Math.round(acc[k] / acc[3]) : 0;
      out.data[o + 3] = Math.round(acc[3] / n);
    }
  return out;
}

for (const [name, file, x0, y0, x1, y1, rm, clear = []] of CROPS) {
  let p = crop(load(file), x0, y0, x1, y1);
  if (rm) p = removeBackground(p);
  // Erase stray bits of mock-up text that fall inside a crop.
  for (const [cx0, cy0, cx1, cy1] of clear)
    for (let y = Math.round((cy0 - y0) * S); y < Math.round((cy1 - y0) * S); y++)
      for (let x = Math.round((cx0 - x0) * S); x < Math.round((cx1 - x0) * S); x++)
        if (x >= 0 && y >= 0 && x < p.width && y < p.height) p.data[(y * p.width + x) * 4 + 3] = 0;
  p = shrink(p, name.startsWith("story") ? 640 : name.startsWith("ic_") ? 128 : 360);
  writeFileSync(new URL(`${name}.png`, OUT), PNG.sync.write(p, { deflateLevel: 9 }));
  console.log(`${name}.png ${p.width}x${p.height}`);
}
