#!/usr/bin/env bash
# Restore PostgreSQL from the off-site pgBackRest repository (blueprint §25 single-VPS failure plan).
#   restore.sh                      latest consistent point
#   restore.sh "2026-10-20 13:00+05:30"   point-in-time
# Practised EVERY MONTH on staging (docs/runbooks/restore.md). Target: back online within 1 hour.
set -euo pipefail

TARGET_TIME="${1:-}"
cd /srv/heymey/infra/compose
dc() { docker compose -p heymey --env-file ports.env --env-file images.env -f compose.yml "$@"; }

dc stop api realtime worker scheduler pgbouncer
dc stop postgres

ARGS=(--stanza=heymey --delta)
[ -n "$TARGET_TIME" ] && ARGS+=(--type=time "--target=${TARGET_TIME}" --target-action=promote)

dc run --rm --no-deps --entrypoint pgbackrest postgres "${ARGS[@]}" restore
dc up -d postgres pgbouncer
dc up -d --wait api realtime worker scheduler
echo "restore complete - verify with docs/runbooks/restore.md checklist"
