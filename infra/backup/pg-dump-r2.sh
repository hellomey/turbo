#!/usr/bin/env bash
# pg_dump (custom format) of the Supabase database via DIRECT_URL -> age-encrypted -> Cloudflare R2 (BOLT-0023).
#   pg-dump-r2 once   one backup now (deploy.sh runs this before every production migration)
#   pg-dump-r2 loop   nightly at BACKUP_AT_IST (default 02:30 Asia/Kolkata), forever (compose service `backup`)
# Env (from the stack's SOPS secrets): DIRECT_URL, BACKUP_AGE_RECIPIENT (public key only; the private key is kept
# OFF the server by the founder), BACKUP_S3_ENDPOINT, BACKUP_S3_BUCKET, BACKUP_S3_ACCESS_KEY, BACKUP_S3_SECRET_KEY,
# STACK. Retention: the R2 bucket lifecycle rule (35 days), set once in the runbook. Restore: docs/runbooks/restore.md.
# Never prints the URL or keys.
set -euo pipefail

: "${DIRECT_URL:?}" "${BACKUP_AGE_RECIPIENT:?}" "${BACKUP_S3_ENDPOINT:?}" "${BACKUP_S3_BUCKET:?}"
: "${BACKUP_S3_ACCESS_KEY:?}" "${BACKUP_S3_SECRET_KEY:?}"
STACK="${STACK:-production}"

export RCLONE_CONFIG_R2_TYPE=s3 RCLONE_CONFIG_R2_PROVIDER=Cloudflare RCLONE_CONFIG_R2_REGION=auto \
  RCLONE_CONFIG_R2_ENDPOINT="$BACKUP_S3_ENDPOINT" RCLONE_CONFIG_R2_ACCESS_KEY_ID="$BACKUP_S3_ACCESS_KEY" \
  RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$BACKUP_S3_SECRET_KEY" RCLONE_CONFIG_R2_NO_CHECK_BUCKET=true

once() {
  local key="pg/${STACK}/$(TZ=Asia/Kolkata date +%Y/%m/%d/%H%M%S).dump.age"
  # Only the public schemas the app owns; Supabase-managed schemas (auth, storage, ...) are not ours.
  pg_dump --dbname="$DIRECT_URL" --format=custom --no-owner --no-privileges --schema=public \
    | age -r "$BACKUP_AGE_RECIPIENT" \
    | rclone rcat "r2:${BACKUP_S3_BUCKET}/${key}"
  echo "backup ok: ${key}"
}

loop() {
  local at="${BACKUP_AT_IST:-02:30}"
  while true; do
    local now next
    now=$(date +%s)
    next=$(TZ=Asia/Kolkata date -d "today ${at}" +%s)
    [ "$next" -le "$now" ] && next=$(TZ=Asia/Kolkata date -d "tomorrow ${at}" +%s)
    sleep $((next - now))
    once || echo "backup FAILED (alert: Loki rule 'backup FAILED')" >&2
  done
}

"${1:-loop}"
