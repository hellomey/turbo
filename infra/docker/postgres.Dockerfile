# PostgreSQL 17 + pgBackRest in the same container so archive_command can push WAL off-site (blueprint §20.3).
# Pin = POSTGRES_IMAGE in infra/compose/images.env
FROM postgres:17.11-bookworm@sha256:3645570cccdfa447589da9f57dd740faa29b30938e861289a5574b6ca6b03826
RUN apt-get update \
 && apt-get install -y --no-install-recommends pgbackrest ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/log/pgbackrest /var/spool/pgbackrest \
 && chown -R postgres:postgres /var/log/pgbackrest /var/spool/pgbackrest
