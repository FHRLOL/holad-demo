#!/usr/bin/env bash
set -e

# Запуск Navidrome в фоне
/opt/navidrome/navidrome \
  --datafolder "$ND_DATAFOLDER" \
  --musicfolder "$ND_MUSICFOLDER" \
  --address 127.0.0.1 \
  --port 4533 &
NAVI_PID=$!

# Ожидание готовности сервера
until curl -s -f http://127.0.0.1:4533/ping > /dev/null 2>&1; do
  sleep 0.5
done

USER="${NAVIDROME_USER:-demo_visitor}"
PASS="${NAVIDROME_PASS:-DemoVisitorPass2026!}"

# Создание начального пользователя
curl -s -X POST http://127.0.0.1:4533/auth/createAdmin \
  -H "Content-Type: application/json" \
  -d "{\"userName\":\"${USER}\",\"name\":\"Demo Visitor\",\"password\":\"${PASS}\"}" || true

# Запуск и ожидание полного сканирования библиотеки
curl -s "http://127.0.0.1:4533/rest/startScan.view?u=${USER}&p=${PASS}&v=1.16.1&c=init&f=json" > /dev/null 2>&1 || true

echo "Scanning music library..."
while true; do
  SCAN_STATUS=$(curl -s "http://127.0.0.1:4533/rest/getScanStatus.view?u=${USER}&p=${PASS}&v=1.16.1&c=init&f=json" || true)
  if echo "$SCAN_STATUS" | grep -q '"scanning":false'; then
    COUNT=$(echo "$SCAN_STATUS" | grep -o '"count":[0-9]*' | cut -d: -f2 || echo "0")
    if [ "${COUNT:-0}" -gt 0 ]; then
      echo "Scan finished. Total tracks indexed: $COUNT"
      break
    fi
  fi
  sleep 1
done

# Корректная остановка перед передачей управления supervisord
kill "$NAVI_PID"
wait "$NAVI_PID" 2>/dev/null || true

# Запуск основного стека
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf