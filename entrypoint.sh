#!/usr/bin/env bash
set -e

# Запуск Navidrome в фоне для создания базы и пользователя
/opt/navidrome/navidrome \
  --datafolder "$ND_DATAFOLDER" \
  --musicfolder "$ND_MUSICFOLDER" \
  --address 127.0.0.1 \
  --port 4533 &
NAVI_PID=$!

# Ожидание готовности
until curl -s -f http://127.0.0.1:4533/ping > /dev/null 2>&1; do
  sleep 0.5
done

# Создание админа demo_visitor
curl -s -X POST http://127.0.0.1:4533/auth/createAdmin \
  -H "Content-Type: application/json" \
  -d '{
    "userName": "'"${NAVIDROME_USER:-demo_visitor}"'",
    "name": "Demo Visitor",
    "password": "'"${NAVIDROME_PASS:-DemoVisitorPass2026!}"'"
  }' || true
  
# Остановка временного процесса
kill "$NAVI_PID"
wait "$NAVI_PID" 2>/dev/null || true

# Передача управления supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf