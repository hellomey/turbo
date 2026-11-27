// Read-only checks of the live stall URLs. Run: node tools/stall/check-live.mjs   (exit 1 if any check fails)
// Sends only GET and OPTIONS requests; creates nothing.
const API = process.env.API_URL || "https://api.heymey.app";
const APP = "https://app.heymey.app";
const DESK = "https://desk.heymey.app";
const TRY = "https://www.heymey.app/try";

const preflight = (origin) => ({
  method: "OPTIONS",
  headers: {
    Origin: origin,
    "Access-Control-Request-Method": "POST",
    "Access-Control-Request-Headers": "authorization,content-type,idempotency-key",
  },
});
const allows = (origin) => (r) =>
  r.status < 300 && r.headers.get("access-control-allow-origin") === origin
    ? ""
    : `allow-origin=${r.headers.get("access-control-allow-origin")}`;
const ok = (r) => (r.ok ? "" : `HTTP ${r.status}`);
const type = (want) => (r) =>
  r.ok && (r.headers.get("content-type") || "").includes(want)
    ? ""
    : `HTTP ${r.status} ${r.headers.get("content-type")}`;

const checks = [
  ["API health", `${API}/v1/health`, {}, ok],
  ["API exams", `${API}/v1/exams`, {}, async (r) => ok(r) || ((await r.json()).items?.length ? "" : "no exams")],
  ["App index", `${APP}/`, {}, type("text/html")],
  ["App sqlite3.wasm", `${APP}/sqlite3.wasm`, {}, type("application/wasm")],
  ["App drift_worker.js", `${APP}/drift_worker.js`, {}, type("javascript")],
  ["App manifest.json", `${APP}/manifest.json`, {}, ok],
  ["Desk index", `${DESK}/`, {}, type("text/html")],
  ["CORS preflight from app", `${API}/v1/auth/guest`, preflight(APP), allows(APP)],
  ["CORS preflight from desk", `${API}/v1/auth/guest`, preflight(DESK), allows(DESK)],
  ["Try page", `${TRY}?src=check`, {}, type("text/html")],
];

const rows = [];
for (const [name, url, init, test] of checks) {
  const t = performance.now();
  let status = "",
    problem;
  try {
    const r = await fetch(url, { ...init, redirect: "follow", signal: AbortSignal.timeout(15000) });
    status = String(r.status);
    problem = await test(r);
  } catch (e) {
    problem = e.message;
  }
  rows.push({
    check: name,
    result: problem ? "FAIL" : "ok",
    status,
    ms: Math.round(performance.now() - t),
    note: problem || "",
  });
}
console.table(rows);
process.exitCode = rows.some((r) => r.result === "FAIL") ? 1 : 0;
