require File.expand_path('../config/environment', __dir__)

require 'telegram/bot'

token = '5254805714:AAHt4EFD3ESvblsIp7lacpyno8lYwpX9e3A'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    # byebug
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    end
  end
end