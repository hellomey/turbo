# HeyMey Desk: Flutter web build served as static files on port 4569. CI builds apps/desk/build/web first.
# Pin = CADDY_IMAGE in infra/compose/images.env
FROM caddy:2.11.7-alpine@sha256:d8542f48d34a9cf4e4c11a478865229840e87e4c96ea3f439101f31a5d35f75f
COPY apps/desk/build/web /srv
COPY infra/docker/desk.Caddyfile /etc/caddy/Caddyfile
EXPOSE 4569
