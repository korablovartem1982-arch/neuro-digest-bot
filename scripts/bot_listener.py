#!/usr/bin/env python3
import telebot
import time
import logging
import os

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/home/artem/projects/money_bot/logs/bot.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Токен бота
TOKEN = "8065533225:AAEBrrrE8pjzQlJX-82ylZYupIPp5_iWKAA"
ADMIN_CHAT_ID = 8321244612  # Ваш личный ID

# Инициализация бота
bot = telebot.TeleBot(TOKEN)

# Обработчик команды /start
@bot.message_handler(commands=['start'])
def handle_start(message):
    user = message.from_user
    logger.info(f"Пользователь @{user.username} (ID: {user.id}) запустил бота")
    
    # Отправляем приветствие пользователю
    bot.send_message(
        message.chat.id,
        f"👋 Привет, {user.first_name}!\n\n"
        "Я бот для сбора новостей. Скоро здесь будет дайджест.\n"
        "А пока можете написать мне любое сообщение — "
        "оно будет передано администратору."
    )
    
    # Пересылаем уведомление админу
    bot.send_message(
        ADMIN_CHAT_ID,
        f"🆕 Новый пользователь!\n"
        f"Имя: {user.first_name}\n"
        f"Юзернейм: @{user.username if user.username else 'нет'}\n"
        f"ID: {user.id}\n"
        f"Ссылка: tg://user?id={user.id}"
    )

# Обработчик всех текстовых сообщений
@bot.message_handler(func=lambda message: True)
def handle_all_messages(message):
    user = message.from_user
    
    # Игнорируем сообщения от самого админа (чтобы не было цикла)
    if user.id == ADMIN_CHAT_ID:
        return
    
    logger.info(f"Сообщение от @{user.username} (ID: {user.id}): {message.text[:50]}...")
    
    # Пересылаем сообщение админу
    try:
        # Пересылаем само сообщение
        bot.forward_message(ADMIN_CHAT_ID, message.chat.id, message.message_id)
        
        # Дополнительно отправляем информацию о пользователе
        bot.send_message(
            ADMIN_CHAT_ID,
            f"✉️ От: {user.first_name} (@{user.username if user.username else 'нет'})\n"
            f"ID: {user.id}\n"
            f"Текст: {message.text if message.text else '[не текст]'}"
        )
        
        # Отвечаем пользователю
        bot.reply_to(
            message,
            "✅ Сообщение передано администратору!\n"
            "Ответ придёт в ближайшее время."
        )
        
    except Exception as e:
        logger.error(f"Ошибка при пересылке: {e}")
        bot.reply_to(message, "⚠️ Произошла ошибка. Попробуйте позже.")

# Обработчик ошибок
@bot.message_handler(content_types=['photo', 'document', 'video', 'audio', 'sticker'])
def handle_media(message):
    user = message.from_user
    
    if user.id == ADMIN_CHAT_ID:
        return
    
    # Пересылаем медиа админу
    try:
        bot.forward_message(ADMIN_CHAT_ID, message.chat.id, message.message_id)
        bot.send_message(
            ADMIN_CHAT_ID,
            f"📎 Медиа от @{user.username if user.username else 'нет'} (ID: {user.id})"
        )
        bot.reply_to(message, "✅ Медиа передано администратору!")
    except Exception as e:
        logger.error(f"Ошибка при пересылке медиа: {e}")

if __name__ == "__main__":
    logger.info("🚀 Бот запущен! Начинаю слушать сообщения...")
    logger.info(f"Админ: {ADMIN_CHAT_ID}")
    
    # Бесконечный цикл с обработкой ошибок
    while True:
        try:
            bot.polling(none_stop=True, timeout=60)
        except Exception as e:
            logger.error(f"Ошибка в polling: {e}")
            time.sleep(10)
