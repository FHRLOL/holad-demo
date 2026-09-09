FROM ghcr.io/fhrha/holad:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends supervisor curl tar ca-certificates ffmpeg && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/navidrome \
    && curl -fsSL https://github.com/navidrome/navidrome/releases/download/v0.54.5/navidrome_0.54.5_linux_amd64.tar.gz | tar -xvz -C /opt/navidrome/ \
    && chmod +x /opt/navidrome/navidrome

RUN mkdir -p /data/navidrome /music /data/holad /etc/supervisor/conf.d \
    && chmod -R 777 /data /music /tmp /opt/navidrome

COPY music/ /music/
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
ENV ND_SCANSCHEDULE=1h
ENV ND_ENABLELEGACYENDPOINTS=true
ENV ND_ENABLETRANSCODINGCONFIG=true

EXPOSE 10000

ENTRYPOINT []

CMD ["/bin/sh", "-c", "(\n  until curl -s http://127.0.0.1:4533/ping >/dev/null; do sleep 1; done\n  /opt/navidrome/navidrome user add -c /opt/navidrome/navidrome.toml --datafolder /data/navidrome -u demo_visitor -p 'DemoVisitorPass2026!' -a=false 2>/dev/null || /opt/navidrome/navidrome user update --datafolder /data/navidrome -u demo_visitor -p 'DemoVisitorPass2026!' 2>/dev/null || true\n  curl -s -X POST 'http://127.0.0.1:4533/rest/startScan.view?u=demo_visitor&p=DemoVisitorPass2026!&v=1.16.1&c=cli&f=json' >/dev/null || true\n) &\nexec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]