require File.expand_path('../../telegram/quiz', __dir__)

class User < ApplicationRecord
  has_many :documents
  has_many :setting

  enum step: {
    start: 0,
    need_to_select_document: 1,
    need_to_select_number_of_words: 2,
    ready: 3,
    daily_quiz: 4,
    playing_quiz: 5,
    finished_play_quiz: 6,
  }

  def time_to_play_quiz?
    setting = Setting.find(current_setting_id)
    planning_time = setting.planning_time.strftime("%H:%M")
    planning_day = setting.planning_day

    planning_day.include?(Time.now.wday) && Time.now.strftime("%H:%M") == planning_time
  end

  def register_quiz_for_user(bot)
    @quiz ||= Quiz.new(user: self, bot: bot)
  end

  def quiz
    @quiz
  end
end
