ARG CADDY_VERSION=2.11.3

FROM caddy:${CADDY_VERSION}-builder AS builder

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
RUN xcaddy build \
    --with github.com/corazawaf/coraza-caddy \
    --replace github.com/go-jose/go-jose/v3=github.com/go-jose/go-jose/v3@v3.0.5

FROM caddy:${CADDY_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
