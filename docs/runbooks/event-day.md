# Event day: State Mock Sunday (and other live events)

The peak load of the month (blueprint §25).

**Week before**
- [ ] k6 State Mock Sunday scenario at **5×** expected users starting in the same minute (qa). Results in the event's intent.
- [ ] Decide extra capacity: raise api/realtime replicas or add a temporary app server for the weekend.
- [ ] Mock content verified; answer key ready; feature flags set; games quiet during the mock window.

**Day of**
- [ ] Watch Grafana: api p95, 5xx, Valkey memory, Postgres connections (Supabase → Reports → Database; pooler 6543 client count), queue depth.
- [ ] Support on standby for payment issues (4-hour target).
- [ ] Statewide rank computed by the worker after the window closes; spot-check before publishing.

**After**
- [ ] Scale back down. Note peak numbers for next time.
