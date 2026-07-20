#!/usr/bin/env python3

import asyncio
import os
import re
from telethon import TelegramClient
from telethon.errors import FloodWaitError

# ===== НАСТРОЙКИ ИЗ ПЕРЕМЕННЫХ ОКРУЖЕНИЯ =====
API_ID = int(os.getenv("TELEGRAM_API_ID", 33964006))
API_HASH = os.getenv("TELEGRAM_API_HASH", "df6f088bafbfac004bf641be8e8b2a4a")
PHONE = os.getenv("TELEGRAM_PHONE", "+38669846579")

# ===== ФАЙЛЫ =====
GROUPS_FILE = "config/groups.txt"
OUTPUT_FILE = "collected_users.txt"
SENT_FILE = "sent_users.txt"

# ===== ЧТЕНИЕ ГРУПП =====
def load_groups():
    try:
        with open(GROUPS_FILE, "r") as f:
            groups = [line.strip() for line in f if line.strip() and not line.startswith("#")]
        return groups
    except FileNotFoundError:
        print(f"❌ Файл {GROUPS_FILE} не найден")
        return []

# ===== ЧТЕНИЕ УЖЕ ОТПРАВЛЕННЫХ =====
def load_sent():
    try:
        with open(SENT_FILE, "r") as f:
            return set([line.strip() for line in f if line.strip()])
    except FileNotFoundError:
        return set()

# ===== СОХРАНЕНИЕ НОВЫХ КОНТАКТОВ =====
def save_new_users(users):
    with open(OUTPUT_FILE, "a") as f:
        for user in users:
            f.write(user + "\n")
    print(f"✅ Добавлено {len(users)} новых пользователей")

def save_sent(users):
    with open(SENT_FILE, "a") as f:
        for user in users:
            f.write(user + "\n")

# ===== ОСНОВНАЯ ФУНКЦИЯ =====
async def main():
    print("🚀 Запуск сбора контактов из Telegram-групп...")
    
    client = TelegramClient('session', API_ID, API_HASH)
    await client.start(phone=PHONE)
    
    groups = load_groups()
    sent_users = load_sent()
    new_users = []
    
    for group in groups:
        print(f"📂 Обработка группы: {group}")
        try:
            entity = await client.get_entity(group)
            participants = await client.get_participants(entity)
            
            for user in participants:
                if user.username:
                    username = f"@{user.username}"
                    if username not in sent_users:
                        new_users.append(username)
                        print(f"  ✅ {username}")
                        
        except FloodWaitError as e:
            print(f"⏳ Ожидание {e.seconds} секунд...")
            await asyncio.sleep(e.seconds)
        except Exception as e:
            print(f"❌ Ошибка {group}: {e}")
    
    if new_users:
        save_new_users(new_users)
        save_sent(new_users)
        print(f"✅ Всего собрано: {len(new_users)} новых контактов")
    else:
        print("ℹ️ Новых контактов не найдено")
    
    await client.disconnect()

if __name__ == "__main__":
    asyncio.run(main())
