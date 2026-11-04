# Nightly logical backup of the Supabase database to Cloudflare R2 (BOLT-0023, ADR-0014; blueprint §20.3).
# pg_dump 17 (matches Supabase Postgres 17) + rclone (S3/R2 upload) + age (client-side encryption).
# Multi-arch (amd64 + arm64 for the Oracle Ampere VM). Pin = POSTGRES_IMAGE in infra/compose/images.env.
FROM postgres:17.11-bookworm@sha256:3645570cccdfa447589da9f57dd740faa29b30938e861289a5574b6ca6b03826
RUN apt-get update \
 && apt-get install -y --no-install-recommends rclone age procps ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/*
COPY infra/backup/pg-dump-r2.sh /usr/local/bin/pg-dump-r2
RUN chmod 755 /usr/local/bin/pg-dump-r2
USER postgres
ENTRYPOINT ["/usr/local/bin/pg-dump-r2"]
CMD ["loop"]
