#!/bin/bash

# ===== НАСТРОЙКИ =====
TOKEN="${TELEGRAM_TOKEN:-8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA}"
CONFIG_FILE="$HOME/projects/money_bot/config/clients.conf"
LOG_DIR="$HOME/projects/money_bot/logs"
LOG_FILE="$LOG_DIR/send_to_clients.log"
mkdir -p "$LOG_DIR"
# ======================

# Функция логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Функция отправки одному клиенту
send_to_client() {
    CHAT_ID="$1"
    TOPIC="$2"
    
    log "Отправка клиенту $CHAT_ID (тема: $TOPIC)"
    
    # Скачиваем RSS
    curl -s --max-time 10 "https://habr.com/ru/rss/search/?q=$TOPIC&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru" > /tmp/rss_${CHAT_ID}.xml 2>/dev/null
    
    # Создаём отчёт
    {
        echo "=== 🤖 ДАЙДЖЕСТ ПО ТЕМЕ: $TOPIC $(date '+%d.%m.%Y %H:%M') ==="
        echo ""
        echo "📌 ХАБР ($TOPIC):"
        grep '<title>' /tmp/rss_${CHAT_ID}.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5 | while read title; do
            echo "  • $title"
        done
        echo ""
        echo "📌 ПОЛЕЗНЫЕ ССЫЛКИ:"
        grep '<link>' /tmp/rss_${CHAT_ID}.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//' | while read link; do
            echo "  • $link"
        done
        echo ""
        echo "📅 $(date '+%H:%M %d.%m.%Y')"
    } > /tmp/report_${CHAT_ID}.txt
    
    # Отправка в Telegram
    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$(cat /tmp/report_${CHAT_ID}.txt)" \
        -d parse_mode="HTML")
    
    if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
        log "✅ Отправлено клиенту $CHAT_ID"
        echo "✅ Отправлено клиенту $CHAT_ID"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.description // "неизвестная ошибка"')
        log "❌ Ошибка клиенту $CHAT_ID: $ERROR"
        echo "❌ Ошибка клиенту $CHAT_ID: $ERROR"
    fi
}

# Основной цикл: читаем файл config/clients.conf
log "===== ЗАПУСК ОТПРАВКИ ====="

while IFS='|' read -r CHAT_ID TIME TOPIC; do
    # Пропускаем пустые строки и комментарии
    [[ -z "$CHAT_ID" || "$CHAT_ID" =~ ^# ]] && continue
    
    # Убираем пробелы
    CHAT_ID=$(echo "$CHAT_ID" | xargs)
    TIME=$(echo "$TIME" | xargs)
    TOPIC=$(echo "$TOPIC" | xargs)
    
    # Если передан аргумент "now" — отправляем всем без проверки времени
    if [[ "$1" == "now" ]] || [[ "$(date +%H:%M)" == "$TIME" ]]; then
        send_to_client "$CHAT_ID" "$TOPIC"
    fi
done < "$CONFIG_FILE"

log "===== ОТПРАВКА ЗАВЕРШЕНА ====="
