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
echo "Waiting for Navidrome ping..."
until curl -s -f http://127.0.0.1:4533/ping > /dev/null 2>&1; do
  sleep 0.5
done

# Создание администратора с гарантированными значениями полей
echo "Creating admin user..."
curl -s -X POST http://127.0.0.1:4533/auth/createAdmin \
  -H "Content-Type: application/json" \
  -d '{"username":"demo_visitor","name":"Demo Visitor","password":"DemoVisitorPass2026!"}' || true

# Ожидание 10 секунд для первичного сканирования 52 треков
echo "Waiting for music indexing..."
sleep 10

# Корректная остановка фонового процесса
kill "$NAVI_PID"
wait "$NAVI_PID" 2>/dev/null || true

echo "Navidrome initialized. Launching supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf