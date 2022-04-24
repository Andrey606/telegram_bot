require File.expand_path('../config/environment', __dir__)
require_relative "quiz"
require 'telegram/bot'
require 'open-uri'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new
scheduler.every '5s' do
  User.all.each do |user|
    if user.time_to_play_quiz? && !user.playing_quiz?
      quiz = QuizArray.find { |quiz| quiz.user == user }
      quiz.bot.api.send_message(chat_id: user.chat_id, text: "Time to check words!")
      quiz.start
    end
  end
end

TOKEN = '5254805714:AAHt4EFD3ESvblsIp7lacpyno8lYwpX9e3A'
TELEGAM = Telegram::Bot::Client.new(TOKEN)

QuizArray = []

TELEGAM.run do |bot|
  User.all.each do |user|
    QuizArray.push(Quiz.new(user: user, bot: bot)) unless QuizArray.find { |quiz| quiz.user == user }
    if user.playing_quiz?
      user.ready!
      quiz = QuizArray.find { |quiz| quiz.user == user }
      bot.api.send_message(chat_id: user.chat_id, text: "Smth went wrong :( let's try again!")
      quiz.start
    end
  end

  bot.listen do |message|
    if !User.exists?(telegram_id: message.from.id)
      user = User.create(telegram_id: message.from.id, name: message.from.first_name, chat_id: message.chat.id)
      QuizArray.push(Quiz.new(user: user, bot: bot))
    else
      user = User.find_by(telegram_id: message.from.id)
    end

    unless message.document.nil?
      # find file
      file_info = bot.api.getFile(file_id: message.document.file_id)
      doc = Document.create(file_name: message.document.file_name, mime_type: message.document.mime_type, file_id: message.document.file_id, user_id: user.id)
      link_to_file = "https://api.telegram.org/file/bot#{TOKEN}/#{file_info["result"]["file_path"]}"

      if doc.valid?
        LoadDictionary.perform_later(link_to_file, doc.id)
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
    when '/cat'
      bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new('images/cat.jpeg', 'image/jpeg'))
    else
      if user.need_to_select_document?
        doc = user.documents.find_by(file_name: message.text)
        if !doc.nil?
          Setting.create(user_id: user.id, document_id: doc.id) unless Setting.find_by(user_id: user.id, document_id: doc.id)
          setting = Setting.find_by(user_id: user.id, document_id: doc.id)
          setting.update(planning_day: [0,1,2,3,4,5,6], planning_time: '13:00')

          user.update(current_setting_id: setting.id)
          bot.api.send_message(chat_id: message.chat.id, text: "You have selected: #{doc.file_name}! Enter number of words you want to study per week.", reply_markup: markup)
          user.need_to_select_number_of_words!
        end
      elsif user.need_to_select_number_of_words?

        user_setting = Setting.find(user.current_setting_id)
        user_setting.update(words_per_week: message.text.to_i)

        if !user_setting.words_per_week.zero?
          setting = Setting.find(user.current_setting_id)
          planning_time = setting.planning_time.strftime("%H:%M")
          planning_day = setting.planning_day

          answer = "Great! We starting on #{planning_day.map{|day| Date::ABBR_DAYNAMES[day.to_i] }.join(", ")} at #{planning_time}"
          bot.api.send_message(chat_id: message.chat.id, text: answer)
        end

        user.ready!
      elsif user.ready?

      elsif user.playing_quiz?
        quiz = QuizArray.find { |quiz| quiz.user == user }
        quiz.check_word(message.text)
      elsif user.finished_play_quiz?
        # finished to play qiuz
        user.ready!
      end
    end
  end
end


