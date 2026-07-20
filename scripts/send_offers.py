#!/usr/bin/env python3

import asyncio
import os
from telethon import TelegramClient
from telethon.errors import FloodWaitError

# ===== НАСТРОЙКИ =====
API_ID = int(os.getenv("TELEGRAM_API_ID", 33964006))
API_HASH = os.getenv("TELEGRAM_API_HASH", "df6f088bafbfac004bf641be8e8b2a4a")
PHONE = os.getenv("TELEGRAM_PHONE", "+386")

USERS_FILE = "collected_users.txt"
SENT_FILE = "sent_users.txt"
MAX_PER_DAY = 10

MESSAGE = """Привет! Я делаю ежедневный дайджест новостей о нейросетях и технологиях.

❌ ПРОБЛЕМА:
Вы тратите часы на поиск полезной информации. Новостей сотни, но 90% — мусор. Трудно отделить важное от второстепенного. Легко упустить тренд, который мог бы дать конкурентное преимущество.

✅ РЕШЕНИЕ:
Каждое утро в 8:00 я присылаю вам дайджест в Telegram:
• 5 свежих статей с Хабра по вашей теме
• Главные новости технологий и ИИ
• Прямые ссылки на источники
• Никакой воды — только полезное

💡 ЧТО ЭТО ДАЁТ ВАМ:
• Экономия 2+ часов в день на поиске информации
• Быть в курсе трендов без усилий
• Готовый контент для постов, статей, идей
• Уверенность, что вы ничего не упустили
• Возможность быстро реагировать на изменения рынка

🎯 КОМУ ПОДХОДИТ:
• IT-специалистам — знать новые технологии
• Маркетологам — идеи для контента
• Предпринимателям — быть в тренде
• Инвесторам — отслеживать рынок
• Блогерам — готовые темы для постов
• Всем, кто хочет быть в курсе

🔥 7 ДНЕЙ БЕСПЛАТНО!
Потом 50 €/месяц. Можно отменить в любой момент.

Хотите попробовать? Просто напишите "да" — и завтра в 8:00 получите первый дайджест!"""

async def main():
    print("🚀 Запуск рассылки предложений...")
    
    client = TelegramClient('session', API_ID, API_HASH)
    await client.start(phone=PHONE)
    
    try:
        with open(USERS_FILE, "r") as f:
            users = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print("❌ Файл с пользователями не найден")
        return
    
    try:
        with open(SENT_FILE, "r") as f:
            sent = set([line.strip() for line in f if line.strip()])
    except FileNotFoundError:
        sent = set()
    
    new_users = [u for u in users if u not in sent][:MAX_PER_DAY]
    
    if not new_users:
        print("ℹ️ Нет новых пользователей для рассылки")
        return
    
    print(f"📤 Отправка {len(new_users)} сообщений...")
    
    for user in new_users:
        try:
            await client.send_message(user, MESSAGE)
            print(f"✅ Отправлено {user}")
            
            with open(SENT_FILE, "a") as f:
                f.write(user + "\n")
            
            await asyncio.sleep(15)
            
        except FloodWaitError as e:
            print(f"⏳ Ожидание {e.seconds} секунд...")
            await asyncio.sleep(e.seconds)
        except Exception as e:
            print(f"❌ Ошибка {user}: {e}")
    
    await client.disconnect()
    print("✅ Рассылка завершена")

if __name__ == "__main__":
    asyncio.run(main())
