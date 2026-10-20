# Incident response

1. **Declare**: open `aidlc/operations/incidents/INC-xxxx.md` from the template. Pick a commander (founder by default).
2. **Stabilise** first:
   - Games misbehaving or a fairness doubt → emergency switch "pause games" / "games practice only" (Desk or app with 2FA).
   - Store/payment issue → "pause store". Never leave users charged without access; entitlements can be granted manually by Support with an audit entry.
   - Bad deploy → `deploy.sh production <previous-sha>`.
3. **Personal data breach?** Follow the DPDP breach plan: contain, assess, notify as the Rules require. Founder decides; log every step.
4. **Communicate** in simple English (in-app banner via liveops, status message).
5. **Close**: root cause, actions → new intents/bolts. Sev-1/2 get a review within 3 days.
