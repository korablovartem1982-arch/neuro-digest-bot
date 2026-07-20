# 🔧 ВСЕ КОМАНДЫ ДЛЯ РАБОТЫ

## 1. ПАРСИНГ

### Скачать RSS с Хабра
curl -s 'https://habr.com/ru/rss/search/?q=%D0%BD%D0%B5%D0%B9%D1%80%D0%BE%D1%81%D0%B5%D1%82%D0%B8&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru' > rss.xml

### Скачать страницу Lenta
curl -s 'https://lenta.ru/rubrics/science/' > lenta.html

### Вытащить заголовки с Хабра
grep '<title>' rss.xml | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5

### Вытащить заголовки с Lenta
grep -o '<span class="card-mini__title">[^<]*</span>' lenta.html | sed 's/<[^>]*>//g' | head -5

### Вытащить ссылки с Хабра
grep '<link>' rss.xml | grep -v '/ru/$' | sed 's/<link>//g' | sed 's/<\/link>//g' | grep 'articles\|news' | head -5 | sed 's/?utm_source.*//'

## 2. TELEGRAM

### Проверка бота
curl -s "https://api.telegram.org/bot8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA/getMe" | jq .

### Отправка сообщения
curl -s -X POST "https://api.telegram.org/bot8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA/sendMessage" -d chat_id="8321244612" -d text="Тест"

### Отправка отчета в Telegram
curl -s -X POST "https://api.telegram.org/bot8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA/sendMessage" -d chat_id="8321244612" -d text="$(cat report.txt)"

## 3. ЗАПУСК СКРИПТОВ

### Полный цикл
~/projects/money_bot/scripts/all_commands.sh all

### Только отчет
~/projects/money_bot/scripts/all_commands.sh report

### Отправить в Telegram
~/projects/money_bot/scripts/all_commands.sh send

## 4. CRON

### Добавить задачу в cron
crontab -e
### Строка для ежедневного запуска в 8:00
0 8 * * * /home/artem/projects/money_bot/scripts/all_commands.sh all > /dev/null 2>&1

### Посмотреть задачи cron
crontab -l

## 5. ПОЛЕЗНЫЕ КОМАНДЫ

### Просмотр структуры проекта
tree ~/projects/money_bot

### Быстрый парсинг Хабра (одна строка)
curl -s 'https://habr.com/ru/rss/search/?q=%D0%BD%D0%B5%D0%B9%D1%80%D0%BE%D1%81%D0%B5%D1%82%D0%B8&order_by=relevance&target_type=posts&hl=ru&fl=ru&fl=ru' | grep '<title>' | grep -v 'Результаты поиска' | grep -v 'Хабр' | sed 's/<title>//g' | sed 's/<\/title>//g' | sed 's/<!\[CDATA\[//g' | sed 's/\]\]>//g' | head -5

### Быстрый парсинг Lenta (одна строка)
curl -s 'https://lenta.ru/rubrics/science/' | grep -o '<span class="card-mini__title">[^<]*</span>' | sed 's/<[^>]*>//g' | head -5

## 6. ВАЖНЫЕ ПЕРЕМЕННЫЕ
TOKEN=8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA
CHAT_ID=8321244612
БОТ=@neuro_digest_2026_bot
