require File.expand_path('../config/environment', __dir__)

require 'telegram/bot'
require 'open-uri'

TOKEN = '5254805714:AAHt4EFD3ESvblsIp7lacpyno8lYwpX9e3A'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    if !User.exists?(telegram_id: message.from.id)
      user = User.create(telegram_id: message.from.id, name: message.from.first_name, chat_id: message.chat.id)
    else
      user = User.find_by(telegram_id: message.from.id)
    end

    unless message.document.nil?
      # find file
      file_info = bot.api.getFile(file_id: message.document.file_id)
      doc = Document.create(file_name: message.document.file_name, mime_type: message.document.mime_type, file_id: message.document.file_id, user_id: user.id)
      link_to_file = "https://api.telegram.org/file/bot#{TOKEN}/#{file_info["result"]["file_path"]}"

      if doc.valid?
        LoadDictionary.perform_now(link_to_file, doc.id)
        bot.api.send_message(chat_id: message.chat.id, text: "File loading started. Enter /select_new_list to strat)")
      end
    end

    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. Upload PDF file with english words please.")
    when '/select_new_list'
      kb = []
      user.documents.each { |doc| kb.push doc.file_name }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: "Choose a list which you want to study.", reply_markup: markup)
      user.need_to_select_document!
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    when '/photo'
      bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new('images/cat.jpeg', 'image/jpeg'))
    else
      if user.need_to_select_document?
        doc = user.documents.find_by(file_name: message.text)
        if !doc.nil?
          user.update(document_id: doc.id)
          bot.api.send_message(chat_id: message.chat.id, text: "You have selected: #{doc.file_name}! It has #{doc.dictionaries.count} words. Enter number of words you want to study per week.", reply_markup: markup)
          user.need_to_select_number_of_words!
        end
      end

      if user.need_to_select_number_of_words?
        user.update(words_per_week: message.text.to_i)
        if !user.words_per_week.zero?
          answer = "Great! So you need to study following words: \n#{User.current_list(user).join(", \n")}"
          bot.api.send_message(chat_id: message.chat.id, text: answer, reply_markup: markup)
        end
      end
    end
  end
end

