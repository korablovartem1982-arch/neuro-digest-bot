#!/bin/bash
echo "🧹 Очистка временных файлов..."
rm -rf ~/projects/money_bot/temp/* 2>/dev/null
rm -rf ~/projects/money_bot/logs/* 2>/dev/null
echo "✅ Готово!"
