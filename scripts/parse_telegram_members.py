import asyncio
from telethon import TelegramClient

# ===== НАСТРОЙКИ =====
api_id = "ТВОЙ_API_ID"        # Получить на my.telegram.org
api_hash = "ТВОЙ_API_HASH"
phone = "ТВОЙ_НОМЕР_ТЕЛЕФОНА"
# ======================

client = TelegramClient('session', api_id, api_hash)

async def main():
    await client.start(phone=phone)
    
    # Список каналов (можно читать из файла)
    channels = [
        "https://t.me/neural_network_chat",
        "https://t.me/it_chat_ru",
    ]
    
    all_users = []
    
    for channel_url in channels:
        try:
            entity = await client.get_entity(channel_url)
            participants = await client.get_participants(entity)
            
            for user in participants:
                if user.username:
                    all_users.append(f"@{user.username}")
                    print(f"@{user.username}")
                    
        except Exception as e:
            print(f"Ошибка {channel_url}: {e}")
    
    # Сохраняем в файл
    with open("telegram_users.txt", "w") as f:
        f.write("\n".join(all_users))
    
    print(f"✅ Собрано {len(all_users)} пользователей")

asyncio.run(main())
