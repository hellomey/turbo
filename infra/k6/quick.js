// Quick post-deploy load check against staging (deploy.yml). The State Mock Sunday 5x scenario is added in INT-004.
import http from "k6/http";
import { check } from "k6";

export const options = {
  vus: 20,
  duration: "30s",
  thresholds: { http_req_duration: ["p(95)<300"], http_req_failed: ["rate<0.01"] },
};

export default function () {
  // Staging is ops-allowlist-only; the deploy pipeline passes the edge key (infra/caddy/Caddyfile staging_only).
  const headers = __ENV.STAGING_ACCESS_KEY ? { "X-HeyMey-Staging-Key": __ENV.STAGING_ACCESS_KEY } : {};
  const res = http.get(`${__ENV.BASE_URL}/v1/health`, { headers });
  check(res, { "status 200": (r) => r.status === 200 });
}
