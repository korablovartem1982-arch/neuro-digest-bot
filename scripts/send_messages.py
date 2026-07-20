import asyncio
from telethon import TelegramClient

api_id = "ТВОЙ_API_ID"
api_hash = "ТВОЙ_API_HASH"
phone = "ТВОЙ_НОМЕР"

client = TelegramClient('session', api_id, api_hash)

async def main():
    await client.start(phone=phone)
    
    with open("telegram_users.txt", "r") as f:
        users = [line.strip() for line in f if line.strip()]
    
    message = """Привет! Я делаю ежедневный дайджест новостей о нейросетях.
Приходит в Telegram в 8:00.
7 дней бесплатно, потом 50 €/мес.
Интересно? Напиши "да" """ 

    for user in users[:10]:  # Ограничиваем 10 сообщений в день
        try:
            await client.send_message(user, message)
            print(f"✅ Отправлено {user}")
            await asyncio.sleep(10)  # Пауза между сообщениями
        except Exception as e:
            print(f"❌ Ошибка {user}: {e}")

asyncio.run(main())
