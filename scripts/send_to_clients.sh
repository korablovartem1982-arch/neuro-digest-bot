#!/bin/bash
# ===== НАСТРОЙКИ =====
TOKEN="8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA"
CONFIG="$HOME/projects/money_bot/config/clients.conf"
LOG_DIR="$HOME/projects/money_bot/logs"
LOG_FILE="$LOG_DIR/send_$(date +%Y-%m-%d).log"
mkdir -p "$LOG_DIR"

# Функция логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Функция отправки одному клиенту
send_to_client() {
    CHAT_ID="$1"
    TOPIC="$2"
    
    # Скачиваем RSS
    curl -s --max-time 5 "https://habr.com/ru/rss/search/?q=$TOPIC&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru" > /tmp/rss_${CHAT_ID}.xml 2>/dev/null
    
    # Создаём отчёт
    echo "=== 🤖 ДАЙДЖЕСТ ПО ТЕМЕ: $TOPIC $(date '+%d.%m.%Y %H:%M') ===" > /tmp/report_${CHAT_ID}.txt
    echo "" >> /tmp/report_${CHAT_ID}.txt
    echo "📌 ХАБР ($TOPIC):" >> /tmp/report_${CHAT_ID}.txt
    
    # Заголовки
    grep '<title>' /tmp/rss_${CHAT_ID}.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5 | while read title; do
        echo "  • $title" >> /tmp/report_${CHAT_ID}.txt
    done
    
    echo "" >> /tmp/report_${CHAT_ID}.txt
    echo "📌 ПОЛЕЗНЫЕ ССЫЛКИ:" >> /tmp/report_${CHAT_ID}.txt
    
    # Ссылки
    grep '<link>' /tmp/rss_${CHAT_ID}.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//' | while read link; do
        echo "  • $link" >> /tmp/report_${CHAT_ID}.txt
    done
    
    echo "" >> /tmp/report_${CHAT_ID}.txt
    echo "📅 $(date '+%H:%M %d.%m.%Y')" >> /tmp/report_${CHAT_ID}.txt
    
    # Отправка в Telegram
    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$(cat /tmp/report_${CHAT_ID}.txt)" \
        -d parse_mode="HTML")
    
    if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
        log "✅ Отправлено клиенту $CHAT_ID (тема: $TOPIC)"
        echo "✅ Отправлено клиенту $CHAT_ID"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.description // "неизвестная ошибка"')
        log "❌ Ошибка клиенту $CHAT_ID: $ERROR"
        echo "❌ Ошибка клиенту $CHAT_ID: $ERROR"
    fi
}

# Читаем файл с клиентами
while IFS='|' read -r CHAT_ID TIME TOPIC; do
    # Пропускаем пустые строки и комментарии
    [[ -z "$CHAT_ID" || "$CHAT_ID" =~ ^# ]] && continue
    
    # Если запуск с параметром "now" — отправляем всем без проверки времени
    if [[ "$1" == "now" ]] || [[ "$(date +%H:%M)" == "$TIME" ]]; then
        log "Запуск для клиента $CHAT_ID (тема: $TOPIC)"
        send_to_client "$CHAT_ID" "$TOPIC"
    fi
done < "$CONFIG"
