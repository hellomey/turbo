#!/usr/bin/env bash
# Deploy one stack on the VPS (blueprint §42). Called by GitHub Actions over SSH.
#   deploy.sh staging    <git-sha>
#   deploy.sh production <git-sha>     (only after the manual "Promote" approval)
# Steps: decrypt secrets -> (prod) pg_dump of Supabase to R2 -> pull images -> migrate (expand-only, DIRECT_URL)
#        -> rolling restart one service at a time -> health checks -> automatic rollback on failure.
# BOLT-0023: Postgres is Supabase, storage is R2, desk/marketing deploy from CI to Firebase/Cloudflare (not here).
set -euo pipefail

STACK="${1:?staging|production}"
VERSION="${2:?image tag (git sha)}"
ROOT=/srv/heymey
COMPOSE_DIR="$ROOT/infra/compose"
PROJECT=$([ "$STACK" = production ] && echo heymey || echo heymey-staging)
FILES=(-f compose.yml)
[ "$STACK" = staging ] && FILES+=(-f compose.staging.yml)

cd "$COMPOSE_DIR"
export STACK APP_VERSION="$VERSION" SOPS_AGE_KEY_FILE="$ROOT/.age/key.txt"

# 1. Secrets: decrypted only on the server, only into a root-readable file.
sops --decrypt "../secrets/${STACK}.enc.env" > "../secrets/${STACK}.env"
chmod 600 "../secrets/${STACK}.env"
set -a; source "../secrets/${STACK}.env"; set +a
# Migrations use DIRECT_URL (Supabase session/direct): transaction pooling (:6543) breaks DDL + advisory locks.
: "${DIRECT_URL:?set DIRECT_URL in ${STACK}.enc.env}"

dc() { docker compose -p "$PROJECT" --env-file ports.env --env-file images.env "${FILES[@]}" "$@"; }

PREVIOUS=$(cat "$ROOT/.deployed-$STACK" 2>/dev/null || echo "")

APPS=(api realtime worker scheduler)
[ "$STACK" = production ] && APPS+=(backup)

# 2. Images first (the backup image is needed for step 3).
dc pull "${APPS[@]}"

# 3. Production only: an encrypted pg_dump to R2 before any migration (fails the deploy if it fails).
if [ "$STACK" = production ]; then
  dc run --rm --no-deps backup once
fi

# 4. Migrations (backward compatible: expand -> migrate -> contract). prisma.config.ts prefers DIRECT_URL; values
#    pass by name (-e VAR), never on the command line. Needs internet (Supabase): default bridge network.
docker run --rm -e DIRECT_URL -e DATABASE_URL "ghcr.io/heymey/migrator:${VERSION}"

# 5. Rolling restart, one service at a time, waiting for health.
rollback() {
  echo "health check failed - rolling back to ${PREVIOUS:-<none>}"
  if [ -n "$PREVIOUS" ]; then APP_VERSION="$PREVIOUS" dc up -d --no-deps "${APPS[@]}"; fi
  exit 1
}
dc up -d --wait valkey
[ "$STACK" = production ] && dc up -d changedetection
for svc in "${APPS[@]}"; do
  dc up -d --no-deps --wait --wait-timeout 120 "$svc" || rollback
done

echo "$VERSION" > "$ROOT/.deployed-$STACK"
echo "deployed $STACK @ $VERSION"
