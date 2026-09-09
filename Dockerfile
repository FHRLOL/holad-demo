FROM ghcr.io/fhrha/holad:latest

USER root

# Ставим зависимости: supervisor, curl, tar
RUN apt-get update && apt-get install -y --no-install-recommends supervisor curl tar ca-certificates && rm -rf /var/lib/apt/lists/*

# Ставим нативный Linux x86_64 бинарник Navidrome
RUN mkdir -p /opt/navidrome \
    && curl -fsSL https://github.com/navidrome/navidrome/releases/download/v0.54.5/navidrome_0.54.5_linux_amd64.tar.gz | tar -xvz -C /opt/navidrome/ \
    && chmod +x /opt/navidrome/navidrome

RUN mkdir -p /data/navidrome /music /data/holad /etc/supervisor/conf.d \
    && chmod -R 777 /data /music /tmp /opt/navidrome

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

ENTRYPOINT []

CMD ["/bin/sh", "-c", "/opt/navidrome/navidrome user create --datafolder /data/navidrome -u demo_visitor -p 'DemoVisitorPass2026!' --admin=false 2>/dev/null || true; exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]