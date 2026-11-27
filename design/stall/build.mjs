// Generates the stall print SVGs. Run from the repo root: node design/stall/build.mjs
// Topic names come from content/syllabus/tnpsc-group-4.yaml. QR codes use the root devDependency `qrcode`.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import QRCode from "qrcode";

const here = dirname(fileURLToPath(import.meta.url));
const C = { red: "#D7261E", yellow: "#F5C518", blue: "#1F4FA3", ink: "#111111", paper: "#FAF6EE", white: "#FFFFFF" };
const FONT = "Nunito, Arial, sans-serif";

const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const text = (x, y, size, str, o = {}) =>
  `<text x="${x}" y="${y}" font-family="${FONT}" font-weight="${o.w ?? 900}" font-size="${size}" fill="${o.fill ?? C.ink}" text-anchor="${o.anchor ?? "start"}">${esc(str)}</text>`;

// Sizes in mm; 1 SVG unit = 1 mm. The trim box is a hidden guide layer.
function doc(name, w, h, bleed, body) {
  const W = w + 2 * bleed;
  const H = h + 2 * bleed;
  return `<?xml version="1.0" encoding="UTF-8"?>
<!-- ${name}. Trim ${w} x ${h} mm, bleed ${bleed} mm each side, document ${W} x ${H} mm. 1 unit = 1 mm. -->
<svg xmlns="http://www.w3.org/2000/svg" width="${W}mm" height="${H}mm" viewBox="${-bleed} ${-bleed} ${W} ${H}">
<rect x="${-bleed}" y="${-bleed}" width="${W}" height="${H}" fill="${C.paper}"/>
${body}
<g id="trim-guide" display="none"><rect x="0" y="0" width="${w}" height="${h}" fill="none" stroke="#00AEEF" stroke-width="0.5"/></g>
</svg>
`;
}

// Real QR code: error correction Q, 4-module quiet zone inside the box, one path of dark modules.
const TRY = "https://www.heymey.app/try?src=";
function qr(x, y, size, url) {
  const m = QRCode.create(url, { errorCorrectionLevel: "Q" }).modules;
  const u = size / (m.size + 8);
  let d = "";
  for (let r = 0; r < m.size; r++) for (let c = 0; c < m.size; c++) if (m.get(r, c)) d += `M${c + 4} ${r + 4}h1v1h-1z`;
  return `<g id="QR" data-url="${esc(url)}" data-ecc="Q" data-modules="${m.size}">
<rect x="${x}" y="${y}" width="${size}" height="${size}" fill="${C.white}"/>
<path transform="translate(${x} ${y}) scale(${u})" fill="${C.ink}" shape-rendering="crispEdges" d="${d}"/>
</g>`;
}

// Geometric lamp: triangle flame tip, circle flame, square base. Outline only when `empty`.
function lamp(x, y, s, fill, empty, sw) {
  return `<g>
<polygon points="${x + s * 0.5},${y} ${x + s * 0.68},${y + s * 0.32} ${x + s * 0.32},${y + s * 0.32}" fill="${empty ? C.white : C.yellow}" stroke="${C.ink}" stroke-width="${sw}"/>
<circle cx="${x + s * 0.5}" cy="${y + s * 0.5}" r="${s * 0.2}" fill="${empty ? C.white : fill}" stroke="${C.ink}" stroke-width="${sw}"/>
<rect x="${x + s * 0.2}" y="${y + s * 0.72}" width="${s * 0.6}" height="${s * 0.22}" fill="${empty ? C.white : C.ink}" stroke="${C.ink}" stroke-width="${sw}"/>
</g>`;
}

function topics() {
  const yaml = readFileSync(join(here, "../../content/syllabus/tnpsc-group-4.yaml"), "utf8");
  const out = [];
  let subject = null;
  for (const line of yaml.split(/\r?\n/)) {
    let m = line.match(/^    name: (.+)$/);
    if (m) {
      subject = { name: m[1].trim(), topics: [] };
      out.push(subject);
      continue;
    }
    m = line.match(/^        name: (.+)$/);
    if (m && subject) subject.topics.push(m[1].trim());
  }
  return out;
}

// Flex banner, 3 m x 2 m.
function flex() {
  const sw = 12;
  const b = [];
  b.push(`<circle cx="2620" cy="330" r="260" fill="${C.red}" stroke="${C.ink}" stroke-width="${sw}"/>`);
  b.push(`<rect x="-10" y="1640" width="700" height="370" fill="${C.blue}" stroke="${C.ink}" stroke-width="${sw}"/>`);
  b.push(`<polygon points="2050,2010 2400,1560 2750,2010" fill="${C.yellow}" stroke="${C.ink}" stroke-width="${sw}"/>`);
  b.push(lamp(150, 150, 300, C.red, false, sw));
  b.push(text(500, 360, 150, "HeyMey"));
  b.push(text(150, 720, 210, "Light up your"));
  b.push(text(150, 950, 210, "TNPSC syllabus."));
  b.push(
    `<rect x="150" y="1060" width="1560" height="190" fill="${C.yellow}" stroke="${C.ink}" stroke-width="${sw}"/>`,
  );
  b.push(text(190, 1195, 110, "Try it free. No install."));
  b.push(text(150, 1450, 110, "Group 4 · Group 2/2A", { w: 800 }));
  b.push(`<rect x="2340" y="700" width="420" height="140" fill="${C.ink}"/>`);
  b.push(text(2550, 805, 100, "BETA", { anchor: "middle", fill: C.paper }));
  b.push(qr(2200, 900, 420, TRY + "flex"));
  b.push(text(2410, 1430, 70, "Scan to try", { anchor: "middle" }));
  b.push(text(2410, 1510, 50, "heymey.app/try", { anchor: "middle", w: 800 }));
  return doc("HeyMey flex banner", 3000, 2000, 10, b.join("\n"));
}

// A3 take-away poster.
function poster() {
  const sw = 1.2;
  const b = [];
  b.push(`<rect x="-3" y="-3" width="303" height="62" fill="${C.blue}"/>`);
  b.push(text(14, 30, 18, "Group 4 syllabus checklist", { fill: C.white }));
  b.push(text(14, 46, 8, "Colour a lamp when you can explain the topic without notes.", { fill: C.white, w: 700 }));
  const colours = [C.red, C.yellow, C.blue];
  let y = 70;
  topics().forEach((s, i) => {
    const col = colours[i % 3];
    b.push(`<rect x="14" y="${y}" width="6" height="6" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`);
    b.push(text(24, y + 6, 7.5, s.name));
    y += 10;
    const per = 5;
    const cell = 53.8;
    s.topics.forEach((t, j) => {
      const cx = 14 + (j % per) * cell;
      const cy = y + Math.floor(j / per) * 30;
      b.push(lamp(cx + cell / 2 - 9, cy, 18, col, true, sw));
      const lines = [];
      let cur = "";
      for (const w of t.split(" ")) {
        if ((cur + " " + w).trim().length > 22) {
          lines.push(cur);
          cur = w;
        } else cur = (cur + " " + w).trim();
      }
      lines.push(cur);
      lines
        .slice(0, 2)
        .forEach((l, k) => b.push(text(cx + cell / 2, cy + 23 + k * 4, 3.4, l, { anchor: "middle", w: 700 })));
    });
    y += Math.ceil(s.topics.length / per) * 30 + 4;
  });
  b.push(qr(222, 340, 62, TRY + "poster"));
  b.push(text(14, 356, 10, "Track every lamp in the app."));
  b.push(text(14, 370, 7, "Scan to try HeyMey in your browser. Free, no install.", { w: 700 }));
  b.push(text(14, 382, 5.5, "HeyMey is in beta and still being built.", { w: 700 }));
  b.push(
    text(
      14,
      398,
      4.2,
      "A starting set of topics from the HeyMey Study Map. The full official syllabus is at tnpsc.gov.in.",
      { w: 600 },
    ),
  );
  b.push(text(14, 410, 5, "heymey.app/try", { w: 800 }));
  return doc("HeyMey A3 Group 4 checklist poster", 297, 420, 3, b.join("\n"));
}

// A5 table tent, one face. Print two faces, or slot one into an A5 acrylic stand.
function tent() {
  const sw = 1.5;
  const b = [];
  b.push(text(74, 26, 13, "Light your first lamp", { anchor: "middle" }));
  const steps = [
    ["Scan", C.red, "circle"],
    ["Play 60 seconds", C.yellow, "tri"],
    ["Get a sticker", C.blue, "square"],
  ];
  steps.forEach(([label, col, shape], i) => {
    const y = 40 + i * 30;
    if (shape === "circle")
      b.push(`<circle cx="24" cy="${y + 10}" r="10" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`);
    if (shape === "tri")
      b.push(
        `<polygon points="24,${y} 35,${y + 20} 13,${y + 20}" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`,
      );
    if (shape === "square")
      b.push(`<rect x="14" y="${y}" width="20" height="20" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`);
    b.push(text(42, y + 14, 11, `${i + 1}. ${label}`));
  });
  b.push(qr(39, 132, 70, TRY + "table"));
  b.push(
    text(74, 208, 4.2, "Stickers are for visitors who light a lamp in the app. HeyMey is in beta.", {
      anchor: "middle",
      w: 700,
    }),
  );
  return doc("HeyMey A5 table tent face", 148, 210, 3, b.join("\n"));
}

// 5 cm round sticker. Die cut on the 50 mm circle; 2 mm bleed.
function sticker(name, l1, l2, shape, col) {
  const sw = 1.2;
  const b = [];
  b.push(`<circle cx="25" cy="25" r="23.5" fill="${C.paper}" stroke="${C.ink}" stroke-width="${sw * 1.5}"/>`);
  if (shape === "circle")
    b.push(`<circle cx="25" cy="19" r="10" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`);
  if (shape === "tri")
    b.push(`<polygon points="25,6 37,28 13,28" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`);
  if (shape === "square")
    b.push(`<rect x="15" y="9" width="20" height="20" fill="${col}" stroke="${C.ink}" stroke-width="${sw}"/>`);
  b.push(text(25, 37, 4.6, l1, { anchor: "middle" }));
  b.push(text(25, 42.5, 4.6, l2, { anchor: "middle" }));
  b.push(
    `<g id="die-cut" display="none"><circle cx="25" cy="25" r="25" fill="none" stroke="#EC008C" stroke-width="0.3"/></g>`,
  );
  return doc(`HeyMey sticker: ${name}`, 50, 50, 2, b.join("\n"));
}

const files = {
  "flex-banner-3000x2000.svg": flex(),
  "poster-a3-group4-checklist.svg": poster(),
  "table-tent-a5.svg": tent(),
  "sticker-first-lamp.svg": sticker("I lit my first lamp", "I lit my", "first lamp", "circle", C.red),
  "sticker-group4-lamplighter.svg": sticker("Group 4 Lamplighter", "Group 4", "Lamplighter", "tri", C.yellow),
  "sticker-exam-hall-survivor.svg": sticker("Exam Hall survivor", "Exam Hall", "survivor", "square", C.blue),
};
// Standalone QR files (30 mm, quiet zone included) for any piece that needs one, including the sticker sheet.
for (const src of ["flex", "poster", "table", "sticker"])
  files[`qr-${src}.svg`] = doc(`HeyMey QR ${src}`, 30, 30, 0, qr(0, 0, 30, TRY + src));
for (const [f, svg] of Object.entries(files)) writeFileSync(join(here, f), svg);
console.log(Object.keys(files).join("\n"));
