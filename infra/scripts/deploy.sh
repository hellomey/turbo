#!/usr/bin/env bash
# Deploy one stack on the VPS (blueprint §42). Called by GitHub Actions over SSH.
#   deploy.sh staging    <git-sha>
#   deploy.sh production <git-sha>     (only after the manual "Promote" approval)
# Steps: decrypt secrets -> (prod) pgBackRest snapshot -> pull images -> migrate (expand-only)
#        -> rolling restart one replica at a time -> health checks -> automatic rollback on failure.
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
# Migrations connect to Postgres directly (not pgbouncer: transaction pooling breaks DDL sessions).
export DATABASE_URL="postgresql://heymey:${POSTGRES_PASSWORD}@postgres:5432/heymey"

dc() { docker compose -p "$PROJECT" --env-file ports.env --env-file images.env "${FILES[@]}" "$@"; }

PREVIOUS=$(cat "$ROOT/.deployed-$STACK" 2>/dev/null || echo "")

# 2. Production only: a backup before any migration.
if [ "$STACK" = production ]; then
  dc exec -T postgres pgbackrest --stanza=heymey --type=incr backup
fi

# 3. Images + migrations (migrations must be backward compatible: expand -> migrate -> contract).
dc pull api realtime worker scheduler desk marketing
docker run --rm --network "${PROJECT}_internal" -e DATABASE_URL "ghcr.io/heymey/migrator:${VERSION}"

# 4. Rolling restart, one service at a time, waiting for health.
rollback() {
  echo "health check failed - rolling back to ${PREVIOUS:-<none>}"
  if [ -n "$PREVIOUS" ]; then APP_VERSION="$PREVIOUS" dc up -d --no-deps api realtime worker scheduler desk marketing; fi
  exit 1
}
for svc in api realtime worker scheduler desk marketing; do
  dc up -d --no-deps --wait --wait-timeout 120 "$svc" || rollback
done

echo "$VERSION" > "$ROOT/.deployed-$STACK"
echo "deployed $STACK @ $VERSION"
