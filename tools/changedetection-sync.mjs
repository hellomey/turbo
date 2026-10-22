#!/usr/bin/env node
// Seeds/updates changedetection.io watches from infra/changedetection/watches.json (BOLT-0015, blueprint §17.5, §20.2).
// Each watch notifies the api over the stack's internal Docker network (never the internet):
//   POST http://api:<API_PORT>/v1/webhooks/changedetection   header x-heymey-webhook-secret: $CHANGEDETECTION_WEBHOOK_SECRET
// Body = SiteChangeWebhookBody (@heymey/contracts). The api stores a PENDING change; nothing reaches users.
//
// Run ON THE SERVER (secrets decrypted there only), production stack only:
//   CHANGEDETECTION_URL=http://127.0.0.1:4596 CHANGEDETECTION_API_KEY=... CHANGEDETECTION_WEBHOOK_SECRET=... \
//     node tools/changedetection-sync.mjs [--dry-run]
// The API key is in changedetection Settings -> API. Secrets are read from env and never printed.
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const ports = JSON.parse(readFileSync(`${root}packages/config/ports.json`, "utf8"));
const apiPort = ports.services.find((s) => s.key === "API").port;
const cfg = JSON.parse(readFileSync(`${root}infra/changedetection/watches.json`, "utf8"));
const dryRun = process.argv.includes("--dry-run");

const base = process.env.CHANGEDETECTION_URL ?? "http://127.0.0.1:4596";
const apiKey = process.env.CHANGEDETECTION_API_KEY;
const secret = process.env.CHANGEDETECTION_WEBHOOK_SECRET;
if (!dryRun && (!apiKey || !secret || secret.length < 32)) {
  console.error("Set CHANGEDETECTION_API_KEY and CHANGEDETECTION_WEBHOOK_SECRET (>= 32 chars).");
  process.exit(1);
}

// changedetection's apprise "post://" handler sends the body as-is with "+header" query params as headers.
const notifyUrl = (s) =>
  `post://api:${apiPort}/v1/webhooks/changedetection?+x-heymey-webhook-secret=${encodeURIComponent(s)}&+content-type=application/json`;
// Jinja body -> SiteChangeWebhookBody. changeId = UTC timestamp of the notification (unique per watch per change).
const body = [
  "{",
  '"watchUuid": "{{ watch_uuid }}",',
  '"watchUrl": {{ watch_url | tojson }},',
  '"title": {{ (watch_title or "") | truncate(290) | tojson }},',
  "\"changeId\": \"{% now 'utc', '%Y%m%dT%H%M%S' %}\",",
  '"diffSummary": {{ diff | truncate(19000) | tojson }}',
  "}",
].join("");

const headers = { "x-api-key": apiKey ?? "", "content-type": "application/json" };
const existing = dryRun ? {} : await (await fetch(`${base}/api/v1/watch`, { headers })).json();
const byUrl = new Map(Object.entries(existing).map(([uuid, w]) => [w.url, uuid]));

for (const w of cfg.watches) {
  const payload = {
    url: w.url,
    title: w.title,
    tag: w.tag,
    time_between_check: { hours: cfg.checkIntervalHours },
    notification_urls: [notifyUrl(secret ?? "<secret>")],
    notification_title: "site change",
    notification_body: body,
    notification_format: "Text",
  };
  const uuid = byUrl.get(w.url);
  if (dryRun) {
    console.log(`${uuid ? "update" : "create"} ${w.url}`);
    continue;
  }
  const res = await fetch(uuid ? `${base}/api/v1/watch/${uuid}` : `${base}/api/v1/watch`, {
    method: uuid ? "PUT" : "POST",
    headers,
    body: JSON.stringify(payload),
  });
  console.log(`${uuid ? "update" : "create"} ${w.url} -> ${res.status}`);
  if (!res.ok) process.exitCode = 1;
}
