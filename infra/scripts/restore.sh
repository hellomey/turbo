#!/usr/bin/env bash
# Restore a nightly pg_dump from R2 into a Supabase database (BOLT-0023; blueprint §20.3, §25).
#   restore.sh <stack-to-restore-INTO> <age-identity-file> [r2-key]
#     RESTORE_TARGET_URL=<throwaway db> restore.sh drill ~/backup-age.key   monthly drill into a throwaway Supabase project
#     restore.sh production ~/backup-age.key pg/production/2026/11/01/023000.dump.age
# The age PRIVATE key never lives on the server: bring it for the restore, delete it after (shred -u).
# Target is that stack's DIRECT_URL. The app services of that stack are stopped during the restore.
# Practised EVERY MONTH into staging with synthetic-data rules (docs/runbooks/restore.md). Target: online in 1 hour.
# Staging never receives real personal data: the drill ("drill") restores into a throwaway Supabase project given
# as RESTORE_TARGET_URL, checks it, then deletes that project. No app services are touched for a drill.
set -euo pipefail

STACK="${1:?production|drill}"
case "$STACK" in production|drill) ;; *) echo "only production or drill (staging never gets real data)"; exit 2;; esac
IDENTITY="${2:?age identity (private key) file}"
KEY="${3:-}"
ROOT=/srv/heymey
cd "$ROOT/infra/compose"
dc() { docker compose -p heymey --env-file ports.env --env-file images.env -f compose.yml "$@"; }

set -a; source "../secrets/production.env"; set +a   # BACKUP_S3_* live in production secrets
BACKUP_ENV=(BACKUP_S3_ENDPOINT BACKUP_S3_BUCKET BACKUP_S3_ACCESS_KEY BACKUP_S3_SECRET_KEY)
if [ "$STACK" = drill ]; then TARGET_URL="${RESTORE_TARGET_URL:?set RESTORE_TARGET_URL for a drill}"; else TARGET_URL="$DIRECT_URL"; fi
export TARGET_URL KEY

[ "$STACK" = production ] && dc stop api realtime worker scheduler
docker run --rm -i --entrypoint bash -e TARGET_URL -e KEY $(printf -- '-e %s ' "${BACKUP_ENV[@]}") \
  -v "$(realpath "$IDENTITY")":/run/age.key:ro "ghcr.io/heymey/backup:$(cat "$ROOT/.deployed-production")" -c '
  set -euo pipefail
  export RCLONE_CONFIG_R2_TYPE=s3 RCLONE_CONFIG_R2_PROVIDER=Cloudflare RCLONE_CONFIG_R2_REGION=auto \
    RCLONE_CONFIG_R2_ENDPOINT="$BACKUP_S3_ENDPOINT" RCLONE_CONFIG_R2_ACCESS_KEY_ID="$BACKUP_S3_ACCESS_KEY" \
    RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$BACKUP_S3_SECRET_KEY"
  [ -n "$KEY" ] || KEY=$(rclone lsf -R --files-only "r2:${BACKUP_S3_BUCKET}/pg/production" | sort | tail -1 | sed "s|^|pg/production/|")
  echo "restoring ${KEY}"
  rclone cat "r2:${BACKUP_S3_BUCKET}/${KEY}" | age -d -i /run/age.key \
    | pg_restore --dbname="$TARGET_URL" --clean --if-exists --no-owner --no-privileges --single-transaction
'
[ "$STACK" = production ] && dc up -d --wait api realtime worker scheduler
echo "restore complete - verify with docs/runbooks/restore.md checklist"
