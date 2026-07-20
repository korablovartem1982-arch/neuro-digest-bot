#!/bin/bash
REPORT="report_full.txt"

echo "=== СВОДКА НОВОСТЕЙ О НЕЙРОСЕТЯХ И ТЕХНОЛОГИЯХ $(date) ===" > $REPORT
echo "" >> $REPORT

# 1. Хабр (нейросети)
echo "=== ХАБР (Нейросети) ===" >> $REPORT
curl -s 'https://habr.com/ru/rss/search/?q=%D0%BD%D0%B5%D0%B9%D1%80%D0%BE%D1%81%D0%B5%D1%82%D0%B8&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru' > rss.xml
grep '<title>' rss.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5 | while read title; do
    echo "  • $title" >> $REPORT
done
echo "" >> $REPORT

# 2. Lenta.ru (наука и технологии)
echo "=== LENTA.RU (Наука и технологии) ===" >> $REPORT
curl -s 'https://lenta.ru/rubrics/science/' > lenta.html
grep -o '<span class="card-mini__title">[^<]*</span>' lenta.html | sed 's/<[^>]*>//g' | head -5 | while read title; do
    echo "  • $title" >> $REPORT
done
echo "" >> $REPORT

# 3. Ссылки из Хабра
echo "=== ПОЛЕЗНЫЕ ССЫЛКИ ===" >> $REPORT
grep '<link>' rss.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//' | while read link; do
    echo "  • $link" >> $REPORT
done

cat $REPORT
