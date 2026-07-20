#!/bin/bash
REPORT="report_fast.txt"

echo "=== СВОДКА НОВОСТЕЙ О НЕЙРОСЕТЯХ И ТЕХНОЛОГИЯХ $(date) ===" > $REPORT
echo "" >> $REPORT

# 1. Хабр (с таймаутом 5 секунд)
echo "--- ХАБР (Нейросети) ---" >> $REPORT
curl -s --max-time 5 'https://habr.com/ru/rss/search/?q=%D0%BD%D0%B5%D0%B9%D1%80%D0%BE%D1%81%D0%B5%D1%82%D0%B8&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru' > rss.xml 2>/dev/null
if [ -s rss.xml ]; then
    grep '<title>' rss.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5 | while read title; do
        echo "  • $title" >> $REPORT
    done
else
    echo "  • (нет данных)" >> $REPORT
fi
echo "" >> $REPORT

# 2. Lenta.ru (с таймаутом 5 секунд)
echo "--- LENTA.RU (Наука) ---" >> $REPORT
curl -s --max-time 5 'https://lenta.ru/rubrics/science/' > lenta.html 2>/dev/null
if [ -s lenta.html ]; then
    grep -o '<span class="card-mini__title">[^<]*</span>' lenta.html | sed 's/<[^>]*>//g' | head -5 | while read title; do
        echo "  • $title" >> $REPORT
    done
else
    echo "  • (нет данных)" >> $REPORT
fi
echo "" >> $REPORT

# 3. RBC (с таймаутом 5 секунд) - ЗАКОММЕНТИРОВАН, т.к. может тормозить
echo "--- RBC (Технологии) ---" >> $REPORT
echo "  • (пропущено для скорости)" >> $REPORT
echo "" >> $REPORT

# 4. Полезные ссылки (Хабр)
echo "--- ПОЛЕЗНЫЕ ССЫЛКИ (Хабр) ---" >> $REPORT
if [ -s rss.xml ]; then
    grep '<link>' rss.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//' | while read link; do
        echo "  • $link" >> $REPORT
    done
else
    echo "  • (нет данных)" >> $REPORT
fi

cat $REPORT
