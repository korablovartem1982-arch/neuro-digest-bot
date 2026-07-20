#!/bin/bash
echo "=== НОВОСТИ О НЕЙРОСЕТЯХ $(date) ===" > report.txt
echo "" >> report.txt
echo "СВЕЖИЕ СТАТЬИ:" >> report.txt
echo "" >> report.txt
grep '<title>' rss.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -10 | while read title; do
    echo "- $title" >> report.txt
done
echo "" >> report.txt
echo "ССЫЛКИ:" >> report.txt
echo "" >> report.txt
grep '<link>' rss.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -10 | sed 's/?utm_source.*//' | while read link; do
    echo "- $link" >> report.txt
done
cat report.txt
