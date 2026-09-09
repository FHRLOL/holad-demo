FROM deluan/navidrome:latest AS navidrome_bin
FROM ghcr.io/fhrha/holad:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends supervisor && rm -rf /var/lib/apt/lists/*

COPY --from=navidrome_bin /app/navidrome /app/navidrome

RUN mkdir -p /data/navidrome /music /data/holad /etc/supervisor/conf.d \
    && chmod -R 777 /data /music /tmp

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV PORT=10000
ENV BASE_PATH=/
ENV DEMO_MODE=true
ENV DEMO_POOL_SIZE=25
ENV DEMO_SESSION_MINUTES=30
ENV NAVIDROME_URL=http://127.0.0.1:4533
ENV NAVIDROME_USER=demo_visitor
ENV NAVIDROME_PASS=DemoVisitorPass2026!
ENV ND_DATAFOLDER=/data/navidrome
ENV ND_MUSICFOLDER=/music
ENV ND_SCANSCHEDULE=0
ENV ND_ENABLELEGACYENDPOINTS=true

EXPOSE 10000

# Сбрасываем родной entrypoint Holad, чтобы контроль перешел supervisord
ENTRYPOINT []

CMD ["/bin/sh", "-c", "/app/navidrome user create --datafolder /data/navidrome -u demo_visitor -p 'DemoVisitorPass2026!' --admin=false 2>/dev/null || true; exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]