# Load tests

`stall.k6.js` models a stall visitor: guest session, exam list, Group 4 Study Map, start a 10-question practice
session, with short think times. 150 virtual users ramp up over 2 minutes and hold for 5 minutes. The run fails if
p95 latency is 800 ms or more, or if more than 1% of requests fail.

## Run it (staging only)

Install [k6](https://grafana.com/docs/k6/latest/set-up/install-k6/), then from the repo root:

```sh
k6 run -e BASE_URL=https://<staging-api-host> tools/load/stall.k6.js
```

Optional: `-e EXAM_CODE=tnpsc-group-2`.

**Never point it at production** (`api.heymey.app`). The script refuses that host. Each iteration creates a real guest
account, and 150 users for 7 minutes would fill production with test users and could trip Supabase Free limits.

## Before you run

- Tell the team in the stand-up; Vercel and Supabase dashboards will show the spike.
- Per-IP rate limits on `/v1/auth/guest` will throttle a single load generator. Either raise the staging limit for the
  run or read 429s as a rate-limit result, not a capacity result.
- Afterwards, delete the test guests on staging (they have no email and were created in the run window).
- Write the summary (p95 per step, error rate, Supabase pooler connections) into the PR or the stand-up.
