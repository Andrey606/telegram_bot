class Quiz
  attr_accessor :user
  attr_accessor :bot

  def initialize(bot:, user:)
    @bot = bot
    @user = user
  end

  def check_word(translation)
    if @word_list.nil?
      @user.playing_quiz!
      reload

      @bot.api.send_message(chat_id: @user.chat_id, text: "Smth went wrong :( let's try again!")
      send_next_word
    end

    @bot.api.send_message(chat_id: @user.chat_id, text: 'Mistake') unless Dictionary.translate(@word).include?(translation)
    send_next_word
  end

  def start
    unless @user.playing_quiz?
      @user.playing_quiz!
      reload
    end
    send_next_word
  end

  private

  def reload
    setting = Setting.find(@user.reload.current_setting_id)
    weeks = weeks_since(setting.created_at)
    words_per_week = setting.words_per_week
    weekly_word_list = Document.word_list(@user)[weeks*words_per_week, (weeks*words_per_week)+words_per_week] # 30 words

    @word_list = weekly_word_list
    @word_list.shuffle!

    # byebug
    #
    # words_per_day = (weekly_word_list.count / setting.planning_day.count).ceil
    # days = setting.planning_day.index(Time.now.wday)
    # @word_list = weekly_word_list[days*words_per_day, (days*words_per_day)+words_per_day]
    # @word_list = @word_list + <previos failed words>

    # @word_list.shuffle!
  end

  def send_next_word
    @word = @word_list.shift

    if @word.nil? || @word.empty?
      @bot.api.send_message(chat_id: @user.chat_id, text: 'Great! Enough for today')

      @user.finished_play_quiz!
      @user.ready!
      return
    end

    @bot.api.send_message(chat_id: @user.chat_id, text: @word)
  end

  def weeks_since(date_string)
    (Time.now - date_string).seconds.in_weeks.to_i.abs
  end
end