# Rebuild the VPS (single-VPS failure plan, blueprint §25)

Target: **back online within 1 hour**. Practised monthly on a throwaway VPS.

1. Create a new VPS (same size, Indian data centre, Ubuntu 24.04).
2. `bash infra/scripts/provision.sh <deploy-user> <ssh-port>` (Docker, UFW 80/443 only, CrowdSec, edge network).
3. Clone the repo to `/srv/heymey`; place the age key at `/srv/heymey/.age/key.txt` (from the founder's offline backup).
4. Start Postgres only, then `infra/scripts/restore.sh` from the off-site pgBackRest repository.
5. `docker compose -p heymey-edge --env-file infra/compose/images.env -f infra/compose/compose.edge.yml up -d`; `infra/scripts/deploy.sh production <last-good-sha>`.
6. Bring up monitoring (`compose.monitoring.yml`).
7. Point Cloudflare DNS A records to the new IP. Verify the external uptime check turns green.
8. Write the incident report.
