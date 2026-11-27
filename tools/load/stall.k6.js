// Stall load test: a visitor starts a guest session, lists exams, opens the Group 4 Study Map and starts practice.
// Run against STAGING only:  k6 run -e BASE_URL=https://<staging-api-host> tools/load/stall.k6.js
// The script refuses the production API unless ALLOW_PROD=yes, which nobody should set during stall hours.
import http from "k6/http";
import { check, sleep } from "k6";
import { uuidv4 } from "https://jslib.k6.io/k6-utils/1.4.0/index.js";

const BASE = __ENV.BASE_URL;
const EXAM = __ENV.EXAM_CODE || "tnpsc-group-4";
if (!BASE) throw new Error("Set BASE_URL to the staging API, e.g. -e BASE_URL=https://staging-api.example");
if (/api\.heymey\.app/.test(BASE) && __ENV.ALLOW_PROD !== "yes") throw new Error("Refusing to load-test production.");

export const options = {
  stages: [
    { duration: "2m", target: 150 },
    { duration: "5m", target: 150 },
    { duration: "30s", target: 0 },
  ],
  thresholds: {
    http_req_duration: ["p(95)<800"],
    http_req_failed: ["rate<0.01"],
  },
};

const json = (token) => ({
  headers: {
    "Content-Type": "application/json",
    Origin: "https://app.heymey.app",
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  },
});

export default function () {
  const guest = http.post(
    `${BASE}/v1/auth/guest`,
    JSON.stringify({ deviceId: uuidv4(), platform: "web", ageConfirmed18: true }),
    { headers: { ...json().headers, "Idempotency-Key": uuidv4() }, tags: { step: "guest" } },
  );
  check(guest, { "guest 200": (r) => r.status === 200 });
  const token = guest.json("tokens.accessToken");
  if (!token) return;
  sleep(1);

  check(http.get(`${BASE}/v1/exams`, { ...json(token), tags: { step: "exams" } }), {
    "exams 200": (r) => r.status === 200,
  });
  sleep(2);

  const map = http.get(`${BASE}/v1/exams/${EXAM}/study-map`, { ...json(token), tags: { step: "study_map" } });
  check(map, { "study map 200": (r) => r.status === 200 });
  sleep(3);

  const practice = http.post(
    `${BASE}/v1/practice/sessions`,
    JSON.stringify({ mode: "practice", examCode: EXAM, size: 10 }),
    { headers: { ...json(token).headers, "Idempotency-Key": uuidv4() }, tags: { step: "practice" } },
  );
  check(practice, { "practice 2xx": (r) => r.status >= 200 && r.status < 300 });
  sleep(5);
}
