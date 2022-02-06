class User < ApplicationRecord
  has_many :documents

  # has_many :user_words
  # has_many :dictionary, through: :user_words, -> { order url: :desc }

  enum step: {
    start: 0,
    need_to_select_document: 1,
    need_to_select_number_of_words: 2
  }

  scope :current_list, ->(user) { Document.find(user.document_id).dictionaries.sort_by { |word| word.word.capitalize  }.map {|word| word.word }[0..user.words_per_week-1] }
end
