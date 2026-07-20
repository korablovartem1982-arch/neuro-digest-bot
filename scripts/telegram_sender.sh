#!/bin/bash

# ===== НАСТРОЙКИ =====
TOKEN="${TELEGRAM_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"
# =====================

REPORT="digest.txt"

echo "=== 🤖 ДАЙДЖЕСТ НОВОСТЕЙ О НЕЙРОСЕТЯХ $(date '+%d.%m.%Y %H:%M') ===" > $REPORT
echo "" >> $REPORT

# 1. Хабр
echo "📌 ХАБР (Нейросети):" >> $REPORT
curl -s --max-time 5 'https://habr.com/ru/rss/search/?q=%D0%BD%D0%B5%D0%B9%D1%80%D0%BE%D1%81%D0%B5%D1%82%D0%B8&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru' > rss.xml 2>/dev/null
grep '<title>' rss.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5 | while read title; do
    echo "  • $title" >> $REPORT
done
echo "" >> $REPORT

# 2. Lenta.ru
echo "📌 LENTA.RU (Наука):" >> $REPORT
curl -s --max-time 5 'https://lenta.ru/rubrics/science/' > lenta.html 2>/dev/null
grep -o '<span class="card-mini__title">[^<]*</span>' lenta.html | sed 's/<[^>]*>//g' | head -5 | while read title; do
    echo "  • $title" >> $REPORT
done
echo "" >> $REPORT

# 3. Ссылки
echo "📌 ПОЛЕЗНЫЕ ССЫЛКИ:" >> $REPORT
grep '<link>' rss.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//' | while read link; do
    echo "  • $link" >> $REPORT
done

echo "" >> $REPORT
echo "📅 $(date '+%H:%M %d.%m.%Y')" >> $REPORT

# Отправка в Telegram
RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$(cat $REPORT)" \
    -d parse_mode="HTML")

if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
    echo "✅ Дайджест отправлен в Telegram!"
else
    ERROR=$(echo "$RESPONSE" | jq -r '.description // "неизвестная ошибка"')
    echo "❌ Ошибка: $ERROR"
fi
