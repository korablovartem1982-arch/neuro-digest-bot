#!/bin/bash

# ===== ЛОГИРОВАНИЕ =====
LOG_DIR="$HOME/projects/money_bot/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/parser_$(date +%Y-%m-%d).log"
# ========================

# ===== НАСТРОЙКИ =====
TOKEN="8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA"
CHAT_ID="8321244612"
# ======================

# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 1. ПАРСЕР ХАБР (RSS)
parse_habr() {
    echo "📌 ХАБР (Нейросети):"
    curl -s --max-time 5 'https://habr.com/ru/rss/search/?q=%D0%BD%D0%B5%D0%B9%D1%80%D0%BE%D1%81%D0%B5%D1%82%D0%B8&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru' > /tmp/rss.xml 2>/dev/null
    grep '<title>' /tmp/rss.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5 | while read title; do
        echo "  • $title"
    done
    echo ""
}

# 2. ПАРСЕР LENTA.RU (HTML)
parse_lenta() {
    echo "📌 LENTA.RU (Наука):"
    curl -s --max-time 5 'https://lenta.ru/rubrics/science/' > /tmp/lenta.html 2>/dev/null
    grep -o '<span class="card-mini__title">[^<]*</span>' /tmp/lenta.html | sed 's/<[^>]*>//g' | head -5 | while read title; do
        echo "  • $title"
    done
    echo ""
}

# 3. ССЫЛКИ С ХАБР
parse_links() {
    echo "📌 ПОЛЕЗНЫЕ ССЫЛКИ:"
    grep '<link>' /tmp/rss.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//' | while read link; do
        echo "  • $link"
    done
    echo ""
}

# 4. ГЕНЕРАЦИЯ ОТЧЕТА
generate_report() {
    REPORT="/tmp/digest.txt"
    echo "=== 🤖 ДАЙДЖЕСТ НОВОСТЕЙ О НЕЙРОСЕТЯХ $(date '+%d.%m.%Y %H:%M') ===" > $REPORT
    echo "" >> $REPORT
    parse_habr >> $REPORT
    parse_lenta >> $REPORT
    parse_links >> $REPORT
    echo "📅 $(date '+%H:%M %d.%m.%Y')" >> $REPORT
    echo "$REPORT"
}

# 5. ОТПРАВКА В TELEGRAM (с логированием)
send_to_telegram() {
    log_message "Запуск отправки"
    
    REPORT=$(generate_report)
    
    RESPONSE=$(curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$(cat $REPORT)" \
        -d parse_mode="HTML")
    
    if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
        log_message "✅ Отправлено успешно"
        echo "✅ Дайджест отправлен в Telegram!"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.description // "неизвестная ошибка"')
        log_message "❌ Ошибка: $ERROR"
        echo "❌ Ошибка: $ERROR"
    fi
}

# 6. ГЛАВНАЯ ФУНКЦИЯ
main() {
    case "$1" in
        habr)
            parse_habr
            ;;
        lenta)
            parse_lenta
            ;;
        report)
            REPORT=$(generate_report)
            cat $REPORT
            ;;
        send)
            send_to_telegram
            ;;
        all)
            log_message "Запуск полного цикла"
            echo "🔄 Запуск полного парсинга..."
            REPORT=$(generate_report)
            cat $REPORT
            echo ""
            echo "📤 Отправка в Telegram..."
            send_to_telegram
            ;;
        *)
            echo "Использование:"
            echo "  ./all_commands.sh habr   - Только Хабр"
            echo "  ./all_commands.sh lenta  - Только Lenta"
            echo "  ./all_commands.sh report - Показать отчет"
            echo "  ./all_commands.sh send   - Отправить отчет в Telegram"
            echo "  ./all_commands.sh all    - Полный цикл"
            ;;
    esac
}

main "$1"
